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
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
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
            'phone'        => $request->phone,
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
            'phone'        => $request->phone,
            'password'     => $request->password,
            'household_id' => $household->id,
            'role'         => 'member',
        ]);

        $token = $user->createToken('mobile')->plainTextToken;

        NotificationService::create(
            $household->id,
            'member_join',
            'Anggota Baru',
            $user->name . ' bergabung ke keluarga',
            ['user_id' => $user->id],
        );

        return response()->json([
            'token'     => $token,
            'user'      => new UserResource($user),
            'household' => new HouseholdResource($household->load('members')),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $identifier = $request->identifier;
        $isEmail    = str_contains($identifier, '@');

        $user = $isEmail
            ? User::where('email', $identifier)->first()
            : User::where('phone', $identifier)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'identifier' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => new UserResource($user),
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'identifier' => ['required', 'string'],
        ]);

        $identifier = $request->identifier;
        $isEmail    = str_contains($identifier, '@');

        $user = $isEmail
            ? User::where('email', $identifier)->first()
            : User::where('phone', $identifier)->first();

        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan.'], 404);
        }

        $otp      = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $cacheKey = 'otp_reset_' . $user->id;

        Cache::put($cacheKey, $otp, now()->addMinutes(10));

        // DEV MODE: OTP returned in response. Replace with mail/SMS in production.
        return response()->json([
            'message' => 'Kode reset dikirim',
            'otp'     => $otp,
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'identifier'            => ['required', 'string'],
            'otp'                   => ['required', 'string', 'size:6'],
            'password'              => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $identifier = $request->identifier;
        $isEmail    = str_contains($identifier, '@');

        $user = $isEmail
            ? User::where('email', $identifier)->first()
            : User::where('phone', $identifier)->first();

        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan.'], 404);
        }

        $cacheKey   = 'otp_reset_' . $user->id;
        $storedOtp  = Cache::get($cacheKey);

        if ($storedOtp === null || $storedOtp !== $request->otp) {
            return response()->json(['message' => 'Kode OTP tidak valid atau sudah kadaluarsa.'], 422);
        }

        $user->update(['password' => Hash::make($request->password)]);

        Cache::forget($cacheKey);

        return response()->json(['message' => 'Password berhasil diubah.']);
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
        $user = $request->user();

        $data = $request->only(['name', 'phone', 'email', 'avatar_hue']);

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json(new UserResource($user->fresh()));
    }

    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => 'required|image|max:15360', // 15 MB — phone camera photos routinely exceed 5 MB
        ]);

        $user = $request->user();

        // Delete old avatar if one is already stored
        if ($user->avatar_path) {
            $oldRelative = ltrim(str_replace('/storage/', '', $user->avatar_path), '/');
            Storage::disk('public')->delete($oldRelative);
        }

        $path = $request->file('avatar')->store('avatars', 'public');
        $user->update(['avatar_path' => '/storage/' . $path]);

        return response()->json([
            'avatar_path' => $user->avatar_path,
        ]);
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

    public function removeMember(Request $request, int $userId): JsonResponse
    {
        $owner = $request->user();

        if ($owner->role !== 'owner') {
            return response()->json(['message' => 'Hanya pemilik household yang dapat menghapus anggota.'], 403);
        }

        if ($owner->id === $userId) {
            return response()->json(['message' => 'Pemilik tidak dapat menghapus diri sendiri.'], 422);
        }

        $householdId = $owner->household_id;

        $target = User::where('id', $userId)
            ->where('household_id', $householdId)
            ->first();

        if (!$target) {
            return response()->json(['message' => 'Anggota tidak ditemukan dalam household ini.'], 404);
        }

        DB::transaction(function () use ($target) {
            $target->update([
                'household_id' => null,
                'role'         => 'member',
            ]);
            // Without this the removed member keeps a live session and can
            // keep hitting every authenticated endpoint as if nothing happened.
            $target->tokens()->delete();
        });

        return response()->json(['message' => 'Anggota berhasil dihapus']);
    }

    private function generateUniqueInviteCode(): string
    {
        do {
            $code = strtoupper(Str::random(6));
        } while (Household::where('invite_code', $code)->exists());

        return $code;
    }
}
