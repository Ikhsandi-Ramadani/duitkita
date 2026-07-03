<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SyncPushRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Budget;
use App\Models\Category;
use App\Models\Debt;
use App\Models\Notification;
use App\Models\Recurring;
use App\Models\SavingsGoal;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Services\BalanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SyncController extends Controller
{
    public function __construct(private readonly BalanceService $balanceService)
    {
    }

    public function pull(Request $request): JsonResponse
    {
        $householdId = $request->user()->household_id;
        $since       = $request->input('since', '0');

        // Accept unix ms timestamp (int) or ISO8601 string
        $sinceDate = is_numeric($since)
            ? \Illuminate\Support\Carbon::createFromTimestampMs((int) $since)
            : \Illuminate\Support\Carbon::parse($since);

        // withTrashed() queries below rely on Eloquent's deleted_at timestamp,
        // but the raw model JSON has no `deleted` boolean — the mobile app's
        // sync consumer reads a `deleted` key specifically, so without this it
        // always defaults to false and resurrects anything deleted on the
        // very next pull. Append the computed flag before serializing.
        $withDeletedFlag = fn ($collection) => $collection->map(
            fn ($m) => [...$m->toArray(), 'deleted' => $m->deleted_at !== null]
        );

        $wallets = $withDeletedFlag(Wallet::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get());

        $categories = $withDeletedFlag(Category::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get());

        $transactions = $withDeletedFlag(Transaction::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->with('splits.user:id,name,avatar_hue')
            ->get());

        $budgets = Budget::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $savingsGoals = $withDeletedFlag(SavingsGoal::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get());

        $debts = $withDeletedFlag(Debt::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get());

        $recurrings = Recurring::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $members = User::where('household_id', $householdId)
            ->get(['id', 'name', 'email', 'phone', 'role', 'avatar_hue', 'avatar_path']);

        $notifications = Notification::where('household_id', $householdId)
            ->where('updated_at', '>', $sinceDate)
            ->latest()
            ->take(50)
            ->get();

        return response()->json([
            'server_time'   => now()->toISOString(),
            'members'       => $members,
            'wallets'       => $wallets,
            'categories'    => $categories,
            'transactions'  => $transactions,
            'budgets'       => $budgets,
            'savings_goals' => $savingsGoals,
            'debts'         => $debts,
            'recurrings'    => $recurrings,
            'notifications' => $notifications,
        ]);
    }

    public function push(SyncPushRequest $request): JsonResponse
    {
        $householdId = $request->user()->household_id;
        $items       = $request->input('transactions');
        $results     = [];

        foreach ($items as $item) {
            $clientId = $item['client_id'];

            // Mobile pre-signs amount (negative for expense/transfer) before
            // pushing, but BalanceService::apply() applies its own sign via
            // increment()/decrement() based on type for these three types —
            // storing the pre-signed value made decrement() subtract a
            // negative number, i.e. add instead of subtract. Adjustment is
            // the exception: its amount is a genuine signed delta consumed
            // via increment(), so it must stay untouched.
            $normalizeAmount = fn ($type, $amount) => in_array($type, ['income', 'expense', 'transfer'], true)
                ? abs($amount)
                : $amount;

            // client_id is the one thing mobile never regenerates for a given
            // logical transaction — a re-push of the same client_id means
            // either the user deleted it, edited it, or the app is just
            // retrying an unconfirmed earlier push (nothing actually changed).
            // All three must be handled here, not just deletion, or edits and
            // retries silently do nothing while mobile believes they synced.
            $existing = Transaction::withTrashed()->where('client_id', $clientId)->first();
            if ($existing) {
                $deleted = (bool) ($item['deleted'] ?? false);

                if ($deleted && !$existing->trashed()) {
                    DB::transaction(function () use ($existing) {
                        $this->balanceService->reverse($existing);
                        $existing->delete();
                    });
                    $results[] = ['client_id' => $clientId, 'status' => 'deleted', 'id' => $existing->id];
                    continue;
                }

                if (!$deleted && !$existing->trashed()) {
                    $incomingAmount = $normalizeAmount($item['type'], $item['amount']);
                    $unchanged = $existing->type === $item['type']
                        && (int) $existing->wallet_id === (int) $item['wallet_id']
                        && $existing->target_wallet_id === ($item['target_wallet_id'] ?? null)
                        && $existing->category_id === ($item['category_id'] ?? null)
                        && (int) $existing->amount === (int) $incomingAmount
                        && (string) $existing->note === (string) ($item['note'] ?? null)
                        && $existing->spent_by === ($item['spent_by'] ?? null);
                        // date deliberately excluded: Carbon's cast round-trip vs a
                        // freshly-parsed string is too precision/timezone-fragile to
                        // compare reliably, and date-only edits don't affect balance.

                    if ($unchanged) {
                        $results[] = ['client_id' => $clientId, 'status' => 'skipped', 'id' => $existing->id];
                        continue;
                    }

                    DB::transaction(function () use ($existing, $item, $incomingAmount) {
                        $this->balanceService->reverse($existing);
                        $existing->update([
                            'type'             => $item['type'],
                            'wallet_id'        => $item['wallet_id'],
                            'target_wallet_id' => $item['target_wallet_id'] ?? null,
                            'category_id'      => $item['category_id'] ?? null,
                            'amount'           => $incomingAmount,
                            'date'             => $item['date'],
                            'note'             => $item['note'] ?? null,
                            'spent_by'         => $item['spent_by'] ?? null,
                        ]);
                        $this->balanceService->apply($existing);
                    });
                    $results[] = ['client_id' => $clientId, 'status' => 'updated', 'id' => $existing->id];
                    continue;
                }

                // Already deleted server-side and nothing new to apply.
                $results[] = ['client_id' => $clientId, 'status' => 'skipped', 'id' => $existing->id];
                continue;
            }

            // Created and deleted offline before its first-ever sync — record
            // it (so a retry of this client_id is still idempotent) but skip
            // the balance effect entirely, since it never should have had one.
            $alreadyDeleted = (bool) ($item['deleted'] ?? false);

            $transaction = DB::transaction(function () use ($item, $normalizeAmount, $clientId, $householdId, $request, $alreadyDeleted) {
                $transaction = Transaction::create([
                    'client_id'        => $clientId,
                    'household_id'     => $householdId,
                    'type'             => $item['type'],
                    'wallet_id'        => $item['wallet_id'],
                    'target_wallet_id' => $item['target_wallet_id'] ?? null,
                    'category_id'      => $item['category_id'] ?? null,
                    'amount'           => $normalizeAmount($item['type'], $item['amount']),
                    'date'             => $item['date'],
                    'note'             => $item['note'] ?? null,
                    'recorded_by'      => $request->user()->id,
                    'spent_by'         => $item['spent_by'] ?? null,
                ]);

                if ($alreadyDeleted) {
                    $transaction->delete();
                } else {
                    $this->balanceService->apply($transaction);
                }

                return $transaction;
            });

            $results[] = [
                'client_id' => $clientId,
                'status'    => 'created',
                'id'        => $transaction->id,
            ];
        }

        return response()->json(['results' => $results]);
    }
}
