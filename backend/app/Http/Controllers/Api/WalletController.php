<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\WalletRequest;
use App\Http\Resources\WalletResource;
use App\Models\Wallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WalletController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $wallets = Wallet::where('household_id', $request->user()->household_id)
            ->get();

        return WalletResource::collection($wallets);
    }

    public function store(WalletRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id']   = $request->user()->household_id;
        $data['current_balance'] = $data['initial_balance'] ?? 0;
        $data['initial_balance'] = $data['initial_balance'] ?? 0;

        if ($data['scope'] === 'personal') {
            $data['owner_user_id'] = $request->user()->id;
        }

        $wallet = Wallet::create($data);

        return response()->json(new WalletResource($wallet), 201);
    }

    public function show(Request $request, Wallet $wallet): JsonResponse
    {
        $this->authorizeHousehold($request, $wallet->household_id);

        return response()->json(new WalletResource($wallet));
    }

    public function update(WalletRequest $request, Wallet $wallet): JsonResponse
    {
        $this->authorizeHousehold($request, $wallet->household_id);
        $this->authorizeWrite($request, $wallet);

        $data = $request->validated();
        unset($data['initial_balance']); // Don't allow changing initial_balance after creation

        $wallet->update($data);

        return response()->json(new WalletResource($wallet->fresh()));
    }

    public function destroy(Request $request, Wallet $wallet): JsonResponse
    {
        $this->authorizeHousehold($request, $wallet->household_id);
        $this->authorizeWrite($request, $wallet);

        $wallet->delete();

        return response()->json(null, 204);
    }

    private function authorizeHousehold(Request $request, int $householdId): void
    {
        if ($request->user()->household_id !== $householdId) {
            abort(403);
        }
    }

    /** Only owner of personal wallet or any member for shared wallets can write */
    private function authorizeWrite(Request $request, Wallet $wallet): void
    {
        if ($wallet->scope === 'personal' && $wallet->owner_user_id !== $request->user()->id) {
            abort(403, 'Cannot modify another member\'s personal wallet.');
        }
    }
}
