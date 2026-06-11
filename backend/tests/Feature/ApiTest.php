<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Household;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class ApiTest extends TestCase
{
    use RefreshDatabase;

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    private function registerUser(array $overrides = []): array
    {
        $response = $this->postJson('/api/auth/register', array_merge([
            'name'        => 'Test Owner',
            'family_name' => 'Test Family',
            'email'       => 'owner@example.com',
            'password'    => 'password123',
        ], $overrides));

        $response->assertStatus(201);

        return $response->json();
    }

    private function makeUserWithHousehold(): array
    {
        $data  = $this->registerUser();
        $token = $data['token'];
        $user  = User::find($data['user']['id']);

        return [$user, $token];
    }

    private function makeWallet(User $user, string $token, array $overrides = []): array
    {
        $response = $this->withToken($token)->postJson('/api/wallets', array_merge([
            'scope'           => 'personal',
            'name'            => 'Cash',
            'type'            => 'cash',
            'initial_balance' => 100000,
        ], $overrides));

        $response->assertStatus(201);

        return $response->json();
    }

    private function makeCategory(User $user, string $token, array $overrides = []): array
    {
        $response = $this->withToken($token)->postJson('/api/categories', array_merge([
            'name' => 'Food',
            'type' => 'expense',
            'icon' => 'food',
            'hue'  => 120,
        ], $overrides));

        $response->assertStatus(201);

        return $response->json();
    }

    // ---------------------------------------------------------------------------
    // Auth: Register / Join / Login
    // ---------------------------------------------------------------------------

    public function test_register_creates_household_and_returns_token(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name'        => 'Ikhsan',
            'family_name' => 'Ramadani Family',
            'email'       => 'ikhsan@test.com',
            'password'    => 'secret123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'token',
                'user'      => ['id', 'name', 'email', 'role', 'household_id'],
                'household' => ['id', 'name', 'invite_code'],
            ]);

        $this->assertEquals('owner', $response->json('user.role'));
        $this->assertNotNull($response->json('household.invite_code'));
        $this->assertEquals(6, strlen($response->json('household.invite_code')));
    }

    public function test_register_fails_duplicate_email(): void
    {
        $this->postJson('/api/auth/register', [
            'name'        => 'Ikhsan',
            'family_name' => 'Family',
            'email'       => 'dup@test.com',
            'password'    => 'password123',
        ])->assertStatus(201);

        $this->postJson('/api/auth/register', [
            'name'        => 'Other',
            'family_name' => 'Family2',
            'email'       => 'dup@test.com',
            'password'    => 'password123',
        ])->assertStatus(422);
    }

    public function test_join_household_with_invite_code(): void
    {
        // Create household via register
        $ownerData   = $this->registerUser(['email' => 'owner2@test.com']);
        $inviteCode  = $ownerData['household']['invite_code'];

        $response = $this->postJson('/api/auth/join', [
            'invite_code' => $inviteCode,
            'name'        => 'Member',
            'email'       => 'member@test.com',
            'password'    => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['token', 'user', 'household']);

        $this->assertEquals('member', $response->json('user.role'));
        $this->assertEquals($ownerData['household']['id'], $response->json('household.id'));
    }

    public function test_join_fails_invalid_invite_code(): void
    {
        $this->postJson('/api/auth/join', [
            'invite_code' => 'XXXXXX',
            'name'        => 'Member',
            'email'       => 'member2@test.com',
            'password'    => 'password123',
        ])->assertStatus(404);
    }

    public function test_login_returns_token(): void
    {
        $this->registerUser(['email' => 'login@test.com', 'password' => 'mypassword']);

        $response = $this->postJson('/api/auth/login', [
            'email'    => 'login@test.com',
            'password' => 'mypassword',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['token', 'user']);
    }

    public function test_login_fails_wrong_password(): void
    {
        $this->registerUser(['email' => 'badlogin@test.com', 'password' => 'correctpass']);

        $this->postJson('/api/auth/login', [
            'email'    => 'badlogin@test.com',
            'password' => 'wrongpass',
        ])->assertStatus(422);
    }

    // ---------------------------------------------------------------------------
    // Transaction: store mutates balance
    // ---------------------------------------------------------------------------

    public function test_transaction_store_income_increments_wallet_balance(): void
    {
        [$user, $token] = $this->makeUserWithHousehold();
        $wallet         = $this->makeWallet($user, $token, ['initial_balance' => 0]);
        $category       = $this->makeCategory($user, $token, ['type' => 'income']);

        $this->withToken($token)->postJson('/api/transactions', [
            'type'        => 'income',
            'wallet_id'   => $wallet['id'],
            'category_id' => $category['id'],
            'amount'      => 50000,
            'date'        => now()->toISOString(),
        ])->assertStatus(201);

        $this->assertDatabaseHas('wallets', [
            'id'              => $wallet['id'],
            'current_balance' => 50000,
        ]);
    }

    public function test_transaction_store_expense_decrements_wallet_balance(): void
    {
        [$user, $token] = $this->makeUserWithHousehold();
        $wallet         = $this->makeWallet($user, $token, ['initial_balance' => 100000]);
        $category       = $this->makeCategory($user, $token);

        $this->withToken($token)->postJson('/api/transactions', [
            'type'        => 'expense',
            'wallet_id'   => $wallet['id'],
            'category_id' => $category['id'],
            'amount'      => 30000,
            'date'        => now()->toISOString(),
        ])->assertStatus(201);

        $this->assertDatabaseHas('wallets', [
            'id'              => $wallet['id'],
            'current_balance' => 70000,
        ]);
    }

    // ---------------------------------------------------------------------------
    // Transaction: edit by non-recorder gets 403
    // ---------------------------------------------------------------------------

    public function test_transaction_update_by_non_recorder_returns_403(): void
    {
        [$owner, $ownerToken] = $this->makeUserWithHousehold();
        $wallet               = $this->makeWallet($owner, $ownerToken, ['scope' => 'shared']);
        $category             = $this->makeCategory($owner, $ownerToken);

        // Create transaction as owner
        $tx = $this->withToken($ownerToken)->postJson('/api/transactions', [
            'type'        => 'expense',
            'wallet_id'   => $wallet['id'],
            'category_id' => $category['id'],
            'amount'      => 10000,
            'date'        => now()->toISOString(),
        ])->assertStatus(201)->json();

        // Member joins the same household
        $household = Household::find($owner->household_id);
        $this->postJson('/api/auth/join', [
            'invite_code' => $household->invite_code,
            'name'        => 'Member',
            'email'       => 'member403@test.com',
            'password'    => 'password123',
        ])->assertStatus(201);

        $member = User::where('email', 'member403@test.com')->firstOrFail();

        // Flush cached auth guard so actingAs works fresh
        $this->app['auth']->forgetGuards();

        // Member tries to edit owner's transaction
        $this->actingAs($member, 'sanctum')->putJson('/api/transactions/' . $tx['id'], [
            'type'        => 'expense',
            'wallet_id'   => $wallet['id'],
            'category_id' => $category['id'],
            'amount'      => 5000,
            'date'        => now()->toISOString(),
        ])->assertStatus(403);
    }

    // ---------------------------------------------------------------------------
    // Transfer mutates both wallets
    // ---------------------------------------------------------------------------

    public function test_transfer_transaction_mutates_both_wallets(): void
    {
        [$user, $token] = $this->makeUserWithHousehold();

        $source = $this->makeWallet($user, $token, [
            'scope'           => 'personal',
            'name'            => 'Source',
            'initial_balance' => 200000,
        ]);
        $target = $this->makeWallet($user, $token, [
            'scope'           => 'shared',
            'name'            => 'Target',
            'initial_balance' => 50000,
        ]);

        $this->withToken($token)->postJson('/api/transactions', [
            'type'             => 'transfer',
            'wallet_id'        => $source['id'],
            'target_wallet_id' => $target['id'],
            'amount'           => 75000,
            'date'             => now()->toISOString(),
        ])->assertStatus(201);

        $this->assertDatabaseHas('wallets', [
            'id'              => $source['id'],
            'current_balance' => 125000,
        ]);
        $this->assertDatabaseHas('wallets', [
            'id'              => $target['id'],
            'current_balance' => 125000,
        ]);
    }

    // ---------------------------------------------------------------------------
    // Sync push idempotency: same client_id twice → one transaction
    // ---------------------------------------------------------------------------

    public function test_sync_push_idempotent_by_client_id(): void
    {
        [$user, $token] = $this->makeUserWithHousehold();
        $wallet         = $this->makeWallet($user, $token, ['initial_balance' => 0, 'scope' => 'shared']);
        $category       = $this->makeCategory($user, $token, ['type' => 'income']);

        $clientId = (string) Str::uuid();

        $payload = [
            'transactions' => [[
                'client_id'   => $clientId,
                'type'        => 'income',
                'wallet_id'   => $wallet['id'],
                'category_id' => $category['id'],
                'amount'      => 20000,
                'date'        => now()->toISOString(),
            ]],
        ];

        // First push
        $resp1 = $this->withToken($token)->postJson('/api/sync/transactions', $payload);
        $resp1->assertStatus(200);
        $this->assertEquals('created', $resp1->json('results.0.status'));

        // Second push (same client_id)
        $resp2 = $this->withToken($token)->postJson('/api/sync/transactions', $payload);
        $resp2->assertStatus(200);
        $this->assertEquals('skipped', $resp2->json('results.0.status'));

        // Only one transaction in DB
        $this->assertDatabaseCount('transactions', 1);

        // Wallet balance should only be incremented once
        $this->assertDatabaseHas('wallets', [
            'id'              => $wallet['id'],
            'current_balance' => 20000,
        ]);
    }
}
