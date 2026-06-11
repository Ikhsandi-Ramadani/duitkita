<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RecurringRequest;
use App\Http\Resources\RecurringResource;
use App\Http\Resources\TransactionResource;
use App\Models\Recurring;
use App\Models\Transaction;
use App\Services\BalanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class RecurringController extends Controller
{
    public function __construct(private readonly BalanceService $balanceService)
    {
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $recurrings = Recurring::where('household_id', $request->user()->household_id)->get();

        return RecurringResource::collection($recurrings);
    }

    public function store(RecurringRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id'] = $request->user()->household_id;
        $data['created_by']   = $request->user()->id;

        $recurring = Recurring::create($data);

        return response()->json(new RecurringResource($recurring), 201);
    }

    public function show(Request $request, Recurring $recurring): JsonResponse
    {
        $this->authorize($request, $recurring);

        return response()->json(new RecurringResource($recurring));
    }

    public function update(RecurringRequest $request, Recurring $recurring): JsonResponse
    {
        $this->authorize($request, $recurring);

        $recurring->update($request->validated());

        return response()->json(new RecurringResource($recurring->fresh()));
    }

    public function destroy(Request $request, Recurring $recurring): JsonResponse
    {
        $this->authorize($request, $recurring);

        $recurring->delete();

        return response()->json(null, 204);
    }

    public function run(Request $request, Recurring $recurring): JsonResponse
    {
        $this->authorize($request, $recurring);

        $result = DB::transaction(function () use ($recurring, $request) {
            $transaction = Transaction::create([
                'client_id'    => (string) Str::uuid(),
                'household_id' => $recurring->household_id,
                'type'         => $recurring->type,
                'wallet_id'    => $recurring->wallet_id,
                'category_id'  => $recurring->category_id,
                'amount'       => $recurring->amount,
                'date'         => now(),
                'note'         => $recurring->note ?? 'Recurring: ' . $recurring->id,
                'recorded_by'  => $request->user()->id,
            ]);

            $this->balanceService->apply($transaction);

            // Advance next_run_date by frequency
            $next = $this->advanceDate(Carbon::parse($recurring->next_run_date), $recurring->freq);
            $recurring->update(['next_run_date' => $next]);

            return $transaction;
        });

        return response()->json([
            'recurring'   => new RecurringResource($recurring->fresh()),
            'transaction' => new TransactionResource($result),
        ]);
    }

    private function advanceDate(Carbon $date, string $freq): Carbon
    {
        return match ($freq) {
            'daily'   => $date->addDay(),
            'weekly'  => $date->addWeek(),
            'monthly' => $date->addMonth(),
            'yearly'  => $date->addYear(),
            default   => $date->addMonth(),
        };
    }

    private function authorize(Request $request, Recurring $recurring): void
    {
        if ($recurring->household_id !== $request->user()->household_id) {
            abort(403);
        }
    }
}
