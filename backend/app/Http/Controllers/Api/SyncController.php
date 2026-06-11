<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SyncPushRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Budget;
use App\Models\Category;
use App\Models\Debt;
use App\Models\Recurring;
use App\Models\SavingsGoal;
use App\Models\Transaction;
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
        $request->validate([
            'since' => ['required', 'string'],
        ]);

        $householdId = $request->user()->household_id;
        $since       = $request->input('since');

        // Parse the ISO8601 timestamp
        $sinceDate = \Illuminate\Support\Carbon::parse($since);

        $wallets = Wallet::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $categories = Category::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $transactions = Transaction::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $budgets = Budget::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $savingsGoals = SavingsGoal::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $debts = Debt::withTrashed()
            ->where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        $recurrings = Recurring::where('household_id', $householdId)
            ->where('updated_at', '>=', $sinceDate)
            ->get();

        return response()->json([
            'server_time'   => now()->toISOString(),
            'wallets'       => $wallets,
            'categories'    => $categories,
            'transactions'  => $transactions,
            'budgets'       => $budgets,
            'savings_goals' => $savingsGoals,
            'debts'         => $debts,
            'recurrings'    => $recurrings,
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

            $transaction = DB::transaction(function () use ($item, $clientId, $householdId, $request) {
                $transaction = Transaction::create([
                    'client_id'        => $clientId,
                    'household_id'     => $householdId,
                    'type'             => $item['type'],
                    'wallet_id'        => $item['wallet_id'],
                    'target_wallet_id' => $item['target_wallet_id'] ?? null,
                    'category_id'      => $item['category_id'] ?? null,
                    'amount'           => $item['amount'],
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
