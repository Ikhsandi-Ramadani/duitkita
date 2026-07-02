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

        $categories = Category::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

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
            ->where('created_at', '>', $sinceDate)
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

            // Idempotency: skip if already exists
            $existing = Transaction::where('client_id', $clientId)->first();
            if ($existing) {
                $results[] = [
                    'client_id' => $clientId,
                    'status'    => 'skipped',
                    'id'        => $existing->id,
                ];
                continue;
            }

            // Mobile pre-signs amount (negative for expense/transfer) before
            // pushing, but BalanceService::apply() applies its own sign via
            // increment()/decrement() based on type for these three types —
            // storing the pre-signed value made decrement() subtract a
            // negative number, i.e. add instead of subtract. Adjustment is
            // the exception: its amount is a genuine signed delta consumed
            // via increment(), so it must stay untouched.
            $amount = in_array($item['type'], ['income', 'expense', 'transfer'], true)
                ? abs($item['amount'])
                : $item['amount'];

            $transaction = DB::transaction(function () use ($item, $amount, $clientId, $householdId, $request) {
                $transaction = Transaction::create([
                    'client_id'        => $clientId,
                    'household_id'     => $householdId,
                    'type'             => $item['type'],
                    'wallet_id'        => $item['wallet_id'],
                    'target_wallet_id' => $item['target_wallet_id'] ?? null,
                    'category_id'      => $item['category_id'] ?? null,
                    'amount'           => $amount,
                    'date'             => $item['date'],
                    'note'             => $item['note'] ?? null,
                    'recorded_by'      => $request->user()->id,
                    'spent_by'         => $item['spent_by'] ?? null,
                ]);

                $this->balanceService->apply($transaction);

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
