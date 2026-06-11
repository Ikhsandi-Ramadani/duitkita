<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\BudgetRequest;
use App\Http\Resources\BudgetResource;
use App\Models\Budget;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class BudgetController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $budgets = Budget::where('household_id', $request->user()->household_id)
            ->with('category')
            ->get();

        return BudgetResource::collection($budgets);
    }

    public function store(BudgetRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id'] = $request->user()->household_id;

        if ($data['scope'] === 'personal') {
            $data['owner_user_id'] = $request->user()->id;
        }

        $budget = Budget::create($data);

        return response()->json(new BudgetResource($budget->load('category')), 201);
    }

    public function show(Request $request, Budget $budget): JsonResponse
    {
        $this->authorize($request, $budget);

        return response()->json(new BudgetResource($budget->load('category')));
    }

    public function update(BudgetRequest $request, Budget $budget): JsonResponse
    {
        $this->authorize($request, $budget);

        $data = $request->validated();
        unset($data['scope']); // Scope cannot change after creation

        $budget->update($data);

        return response()->json(new BudgetResource($budget->fresh()->load('category')));
    }

    public function destroy(Request $request, Budget $budget): JsonResponse
    {
        $this->authorize($request, $budget);

        $budget->delete();

        return response()->json(null, 204);
    }

    private function authorize(Request $request, Budget $budget): void
    {
        if ($budget->household_id !== $request->user()->household_id) {
            abort(403);
        }
    }
}
