<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\JoinRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\UpdatePinRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\VerifyPinRequest;
use App\Http\Resources\HouseholdResource;
use App\Http\Resources\UserResource;
use App\Models\Household;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $inviteCode = $this->generateUniqueInviteCode();

        $household = Household::create([
            'name'        => $request->family_name,
            'invite_code' => $inviteCode,
        ]);

        $user = User::create([
            'name'         => $request->name,
            'email'        => $request->email,
            'password'     => $request->password,
            'household_id' => $household->id,
            'role'         => 'owner',
        ]);

        $household->update(['owner_id' => $user->id]);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token'     => $token,
            'user'      => new UserResource($user),
            'household' => new HouseholdResource($household->load('members')),
        ], 201);
    }

    public function join(JoinRequest $request): JsonResponse
    {
        $household = Household::where('invite_code', strtoupper($request->invite_code))->firstOrFail();

        $user = User::create([
            'name'         => $request->name,
            'email'        => $request->email,
            'password'     => $request->password,
            'household_id' => $household->id,
            'role'         => 'member',
        ]);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token'     => $token,
            'user'      => new UserResource($user),
            'household' => new HouseholdResource($household->load('members')),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => new UserResource($user),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request): JsonResponse
    {
        $user      = $request->user()->load('household.members');
        $household = $user->household;

        return response()->json([
            'user'      => new UserResource($user),
            'household' => new HouseholdResource($household),
            'members'   => UserResource::collection($household->members),
        ]);
    }

    public function updateMe(UpdateProfileRequest $request): JsonResponse
    {
        $request->user()->update($request->only(['name', 'avatar_hue']));

        return response()->json(new UserResource($request->user()->fresh()));
    }

    public function updatePin(UpdatePinRequest $request): JsonResponse
    {
        $request->user()->update(['pin' => $request->pin]);

        return response()->json(['message' => 'PIN updated.']);
    }

    public function verifyPin(VerifyPinRequest $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->pin || !Hash::check($request->pin, $user->pin)) {
            return response()->json(['message' => 'Invalid PIN.'], 401);
        }

        return response()->json(['verified' => true]);
    }

    private function generateUniqueInviteCode(): string
    {
        do {
            $code = strtoupper(Str::random(6));
        } while (Household::where('invite_code', $code)->exists());

        return $code;
    }
}
