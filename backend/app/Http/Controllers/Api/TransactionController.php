<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\TransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Services\BalanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    public function __construct(private readonly BalanceService $balanceService)
    {
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $transactions = Transaction::where('household_id', $request->user()->household_id)
            ->with('category')
            ->latest('date')
            ->paginate(50);

        return TransactionResource::collection($transactions);
    }

    public function store(TransactionRequest $request): JsonResponse
    {
        $data = $request->validated();
        $householdId = $request->user()->household_id;

        // Scope-check: wallet must belong to this household
        $wallet = Wallet::where('id', $data['wallet_id'])
            ->where('household_id', $householdId)
            ->firstOrFail();

        // Writing to another member's personal wallet is forbidden
        if ($wallet->scope === 'personal' && $wallet->owner_user_id !== $request->user()->id) {
            abort(403, 'Cannot record transaction on another member\'s personal wallet.');
        }

        if (!empty($data['target_wallet_id'])) {
            Wallet::where('id', $data['target_wallet_id'])
                ->where('household_id', $householdId)
                ->firstOrFail();
        }

        $transaction = DB::transaction(function () use ($data, $householdId, $request) {
            $transaction = Transaction::create([
                'client_id'        => $data['client_id'] ?? (string) Str::uuid(),
                'household_id'     => $householdId,
                'type'             => $data['type'],
                'wallet_id'        => $data['wallet_id'],
                'target_wallet_id' => $data['target_wallet_id'] ?? null,
                'category_id'      => $data['category_id'] ?? null,
                'amount'           => $data['amount'],
                'date'             => $data['date'],
                'note'             => $data['note'] ?? null,
                'recorded_by'      => $request->user()->id,
                'spent_by'         => $data['spent_by'] ?? null,
                'receipt_path'     => $data['receipt_path'] ?? null,
            ]);

            $this->balanceService->apply($transaction);

            return $transaction;
        });

        return response()->json(new TransactionResource($transaction->load('category')), 201);
    }

    public function show(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeHousehold($request, $transaction->household_id);

        return response()->json(new TransactionResource($transaction->load('category')));
    }

    public function update(TransactionRequest $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeHousehold($request, $transaction->household_id);

        if ((int) $transaction->recorded_by !== (int) $request->user()->id) {
            abort(403, 'Only the recorder can edit this transaction.');
        }

        $data = $request->validated();
        $householdId = $request->user()->household_id;

        // Validate wallets belong to household
        Wallet::where('id', $data['wallet_id'])->where('household_id', $householdId)->firstOrFail();
        if (!empty($data['target_wallet_id'])) {
            Wallet::where('id', $data['target_wallet_id'])->where('household_id', $householdId)->firstOrFail();
        }

        $updated = DB::transaction(function () use ($transaction, $data, $request) {
            // Reverse old effect
            $this->balanceService->reverse($transaction);

            // Update transaction
            $transaction->update([
                'type'             => $data['type'],
                'wallet_id'        => $data['wallet_id'],
                'target_wallet_id' => $data['target_wallet_id'] ?? null,
                'category_id'      => $data['category_id'] ?? null,
                'amount'           => $data['amount'],
                'date'             => $data['date'],
                'note'             => $data['note'] ?? null,
                'spent_by'         => $data['spent_by'] ?? null,
                'receipt_path'     => $data['receipt_path'] ?? null,
            ]);

            $transaction->refresh();

            // Apply new effect
            $this->balanceService->apply($transaction);

            return $transaction;
        });

        return response()->json(new TransactionResource($updated->load('category')));
    }

    public function destroy(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeHousehold($request, $transaction->household_id);

        if ((int) $transaction->recorded_by !== (int) $request->user()->id) {
            abort(403, 'Only the recorder can delete this transaction.');
        }

        DB::transaction(function () use ($transaction) {
            $this->balanceService->reverse($transaction);
            $transaction->delete();
        });

        return response()->json(null, 204);
    }

    private function authorizeHousehold(Request $request, int $householdId): void
    {
        if ($request->user()->household_id !== $householdId) {
            abort(403);
        }
    }
}
