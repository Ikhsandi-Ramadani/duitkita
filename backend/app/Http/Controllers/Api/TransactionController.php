<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\TransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Services\BalanceService;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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

        NotificationService::create(
            $transaction->household_id,
            'transaction',
            'Transaksi Baru',
            $request->user()->name . ' menambah transaksi Rp' . number_format($transaction->amount, 0, ',', '.'),
            ['transaction_id' => $transaction->id],
        );

        return response()->json(new TransactionResource($transaction->load('category')), 201);
    }

    public function show(Request $request, Transaction $transaction): JsonResponse
    {
        $this->authorizeHousehold($request, $transaction->household_id);

        return response()->json(new TransactionResource(
            $transaction->load(['category', 'splits.user:id,name,avatar_hue'])
        ));
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

    public function updateSplits(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'splits'            => 'required|array|min:1',
            'splits.*.user_id' => 'required|integer|exists:users,id',
            'splits.*.amount'  => 'required|integer|min:1',
        ]);

        $transaction = Transaction::where('id', $id)
            ->where('household_id', $request->user()->household_id)
            ->firstOrFail();

        // Validate total splits <= transaction amount
        $total = collect($request->splits)->sum('amount');
        if ($total > $transaction->amount) {
            return response()->json(['message' => 'Total split melebihi jumlah transaksi'], 422);
        }

        // Validate all user_ids belong to same household
        $householdUserIds = User::where('household_id', $request->user()->household_id)
            ->pluck('id')
            ->toArray();

        foreach ($request->splits as $split) {
            if (!in_array($split['user_id'], $householdUserIds)) {
                return response()->json(['message' => 'User tidak ditemukan dalam household'], 422);
            }
        }

        DB::transaction(function () use ($transaction, $request) {
            $transaction->splits()->delete();
            $transaction->splits()->createMany($request->splits);
        });

        return response()->json([
            'splits' => $transaction->splits()->with('user:id,name,avatar_hue')->get(),
        ]);
    }

    public function uploadReceipt(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'receipt' => 'required|image|max:5120', // 5 MB
        ]);

        $transaction = Transaction::where('id', $id)
            ->where('household_id', $request->user()->household_id)
            ->firstOrFail();

        // Delete old receipt if one is already stored
        if ($transaction->receipt_path) {
            Storage::disk('public')->delete($transaction->receipt_path);
        }

        $path = $request->file('receipt')->store('receipts', 'public');

        $transaction->update(['receipt_path' => $path]);

        return response()->json([
            'receipt_path' => $transaction->receipt_path,
            'receipt_url'  => Storage::disk('public')->url($path),
        ]);
    }

    private function authorizeHousehold(Request $request, int $householdId): void
    {
        if ($request->user()->household_id !== $householdId) {
            abort(403);
        }
    }
}
