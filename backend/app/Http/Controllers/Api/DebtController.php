<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\DebtRequest;
use App\Http\Requests\PayDebtRequest;
use App\Http\Resources\DebtResource;
use App\Http\Resources\TransactionResource;
use App\Models\Debt;
use App\Models\Transaction;
use App\Services\BalanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class DebtController extends Controller
{
    public function __construct(private readonly BalanceService $balanceService)
    {
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $debts = Debt::where('household_id', $request->user()->household_id)->get();

        return DebtResource::collection($debts);
    }

    public function store(DebtRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id']   = $request->user()->household_id;
        $data['owner_user_id']  = $request->user()->id;

        $debt = Debt::create($data);

        return response()->json(new DebtResource($debt), 201);
    }

    public function show(Request $request, Debt $debt): JsonResponse
    {
        $this->authorize($request, $debt);

        return response()->json(new DebtResource($debt));
    }

    public function update(DebtRequest $request, Debt $debt): JsonResponse
    {
        $this->authorize($request, $debt);

        $debt->update($request->validated());

        return response()->json(new DebtResource($debt->fresh()));
    }

    public function destroy(Request $request, Debt $debt): JsonResponse
    {
        $this->authorize($request, $debt);

        $debt->delete();

        return response()->json(null, 204);
    }

    public function pay(PayDebtRequest $request, Debt $debt): JsonResponse
    {
        $this->authorize($request, $debt);

        $amount      = $request->amount;
        $walletId    = $request->wallet_id;
        $householdId = $request->user()->household_id;

        $result = DB::transaction(function () use ($debt, $amount, $walletId, $householdId, $request) {
            // payable = we owe → expense; receivable = owed to us → income
            $type = $debt->type === 'payable' ? 'expense' : 'income';

            $transaction = Transaction::create([
                'client_id'    => (string) Str::uuid(),
                'household_id' => $householdId,
                'type'         => $type,
                'wallet_id'    => $walletId,
                'category_id'  => null, // Allowed for debt payments
                'amount'       => $amount,
                'date'         => now(),
                'note'         => 'Pembayaran utang: ' . $debt->party_name,
                'recorded_by'  => $request->user()->id,
            ]);

            $this->balanceService->apply($transaction);

            $newPaid = $debt->paid + $amount;
            $debt->update([
                'paid'   => $newPaid,
                'status' => $newPaid >= $debt->amount ? 'paid' : 'ongoing',
            ]);

            return $transaction;
        });

        return response()->json([
            'debt'        => new DebtResource($debt->fresh()),
            'transaction' => new TransactionResource($result),
        ]);
    }

    private function authorize(Request $request, Debt $debt): void
    {
        if ($debt->household_id !== $request->user()->household_id) {
            abort(403);
        }
    }
}
