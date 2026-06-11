<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ContributeGoalRequest;
use App\Http\Requests\SavingsGoalRequest;
use App\Http\Resources\SavingsGoalResource;
use App\Http\Resources\TransactionResource;
use App\Models\SavingsGoal;
use App\Models\Transaction;
use App\Services\BalanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SavingsGoalController extends Controller
{
    public function __construct(private readonly BalanceService $balanceService)
    {
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $goals = SavingsGoal::where('household_id', $request->user()->household_id)->get();

        return SavingsGoalResource::collection($goals);
    }

    public function store(SavingsGoalRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id'] = $request->user()->household_id;

        if ($data['scope'] === 'personal') {
            $data['owner_user_id'] = $request->user()->id;
        }

        $goal = SavingsGoal::create($data);

        return response()->json(new SavingsGoalResource($goal), 201);
    }

    public function show(Request $request, SavingsGoal $savingsGoal): JsonResponse
    {
        $this->authorize($request, $savingsGoal);

        return response()->json(new SavingsGoalResource($savingsGoal));
    }

    public function update(SavingsGoalRequest $request, SavingsGoal $savingsGoal): JsonResponse
    {
        $this->authorize($request, $savingsGoal);

        $savingsGoal->update($request->validated());

        return response()->json(new SavingsGoalResource($savingsGoal->fresh()));
    }

    public function destroy(Request $request, SavingsGoal $savingsGoal): JsonResponse
    {
        $this->authorize($request, $savingsGoal);

        $savingsGoal->delete();

        return response()->json(null, 204);
    }

    public function contribute(ContributeGoalRequest $request, SavingsGoal $savingsGoal): JsonResponse
    {
        $this->authorize($request, $savingsGoal);

        $amount         = $request->amount;
        $sourceWalletId = $request->source_wallet_id;
        $householdId    = $request->user()->household_id;

        $result = DB::transaction(function () use ($savingsGoal, $amount, $sourceWalletId, $householdId, $request) {
            $savingsGoal->increment('current_amount', $amount);

            $transaction = null;

            // If source wallet differs from goal's wallet → create a transfer transaction
            if ($sourceWalletId !== $savingsGoal->wallet_id) {
                $transaction = Transaction::create([
                    'client_id'        => (string) Str::uuid(),
                    'household_id'     => $householdId,
                    'type'             => 'transfer',
                    'wallet_id'        => $sourceWalletId,
                    'target_wallet_id' => $savingsGoal->wallet_id,
                    'category_id'      => null,
                    'amount'           => $amount,
                    'date'             => now(),
                    'note'             => 'Tabungan: ' . $savingsGoal->name,
                    'recorded_by'      => $request->user()->id,
                ]);

                $this->balanceService->apply($transaction);
            }
            // Same wallet → earmark only, no transaction (balance not moved)

            return $transaction;
        });

        return response()->json([
            'goal'        => new SavingsGoalResource($savingsGoal->fresh()),
            'transaction' => $result ? new TransactionResource($result) : null,
        ]);
    }

    private function authorize(Request $request, SavingsGoal $goal): void
    {
        if ($goal->household_id !== $request->user()->household_id) {
            abort(403);
        }
    }
}
