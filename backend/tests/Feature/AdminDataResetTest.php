<?php

namespace Tests\Feature;

use App\Models\AppSetting;
use App\Models\Category;
use App\Models\Household;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminDataResetTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutVite();
    }

    public function test_super_admin_can_open_data_reset_page(): void
    {
        $admin = User::factory()->create(['is_super_admin' => true]);

        $this->actingAs($admin)
            ->get(route('admin.settings.data-reset'))
            ->assertOk()
            ->assertInertia(fn ($page) => $page
                ->component('Admin/Settings/DataReset')
                ->has('counts')
                ->where('confirmationPhrase', 'RESET DATA'));
    }

    public function test_reset_requires_correct_password_and_confirmation_phrase(): void
    {
        $admin = User::factory()->create([
            'password' => 'correct-password',
            'is_super_admin' => true,
        ]);
        $member = User::factory()->create(['is_super_admin' => false]);

        $this->actingAs($admin)
            ->from(route('admin.settings.data-reset'))
            ->delete(route('admin.settings.data-reset.destroy'), [
                'current_password' => 'wrong-password',
                'confirmation' => 'RESET',
            ])
            ->assertRedirect(route('admin.settings.data-reset'))
            ->assertSessionHasErrors(['current_password', 'confirmation']);

        $this->assertDatabaseHas('users', ['id' => $member->id]);
    }

    public function test_reset_deletes_application_data_but_preserves_super_admins_and_settings(): void
    {
        $admin = User::factory()->create([
            'password' => 'admin-password',
            'is_super_admin' => true,
            'avatar_path' => '/storage/avatars/admin.jpg',
        ]);
        $otherAdmin = User::factory()->create(['is_super_admin' => true]);
        $household = Household::create([
            'name' => 'Testing Household',
            'invite_code' => 'TEST01',
        ]);
        $member = User::factory()->create([
            'household_id' => $household->id,
            'is_super_admin' => false,
            'avatar_path' => '/storage/avatars/member.jpg',
        ]);
        $household->update(['owner_id' => $member->id]);
        Wallet::create([
            'household_id' => $household->id,
            'scope' => 'shared',
            'name' => 'Testing Wallet',
            'type' => 'cash',
            'initial_balance' => 100000,
            'current_balance' => 100000,
        ]);
        Category::create([
            'household_id' => $household->id,
            'name' => 'Testing Category',
            'type' => 'expense',
            'icon' => 'test',
            'hue' => 120,
        ]);
        AppSetting::set('app_version', '9.9.9');
        Storage::fake('public');
        Storage::disk('public')->put('avatars/admin.jpg', 'admin-avatar');
        Storage::disk('public')->put('avatars/member.jpg', 'member-avatar');

        $this->actingAs($admin)
            ->delete(route('admin.settings.data-reset.destroy'), [
                'current_password' => 'admin-password',
                'confirmation' => 'RESET DATA',
            ])
            ->assertRedirect(route('admin.settings.data-reset'))
            ->assertSessionHas('success');

        $this->assertDatabaseMissing('users', ['id' => $member->id]);
        $this->assertDatabaseMissing('households', ['id' => $household->id]);
        $this->assertDatabaseCount('wallets', 0);
        $this->assertDatabaseCount('categories', 0);
        $this->assertDatabaseHas('users', ['id' => $admin->id]);
        $this->assertDatabaseHas('users', ['id' => $otherAdmin->id]);
        $this->assertDatabaseHas('app_settings', [
            'key' => 'app_version',
            'value' => '9.9.9',
        ]);
        $this->assertAuthenticatedAs($admin);
        Storage::disk('public')->assertMissing('avatars/member.jpg');
        Storage::disk('public')->assertExists('avatars/admin.jpg');
    }

    public function test_non_admin_cannot_reset_data(): void
    {
        $member = User::factory()->create([
            'password' => 'member-password',
            'is_super_admin' => false,
        ]);

        $this->actingAs($member)
            ->delete(route('admin.settings.data-reset.destroy'), [
                'current_password' => 'member-password',
                'confirmation' => 'RESET DATA',
            ])
            ->assertRedirect(route('admin.login'));

        $this->assertDatabaseHas('users', ['id' => $member->id]);
    }
}
