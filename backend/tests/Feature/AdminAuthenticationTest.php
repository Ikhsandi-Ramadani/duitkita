<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use App\Livewire\Admin\Login;
use Tests\TestCase;

class AdminAuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_visiting_root_is_redirected_to_admin_login(): void
    {
        $this->get('/')
            ->assertRedirect(route('admin.login'));
    }

    public function test_authenticated_super_admin_visiting_root_is_redirected_to_dashboard(): void
    {
        $admin = User::factory()->create(['is_super_admin' => true]);

        $this->actingAs($admin)
            ->get('/')
            ->assertRedirect(route('admin.dashboard'));
    }

    public function test_authenticated_super_admin_can_open_dashboard(): void
    {
        $this->withoutVite();
        $admin = User::factory()->create(['is_super_admin' => true]);

        $this->actingAs($admin)
            ->get(route('admin.dashboard'))
            ->assertOk()
            ->assertSee('Ringkasan')
            ->assertSee('Arus transaksi enam bulan terakhir');
    }

    public function test_authenticated_super_admin_cannot_revisit_login_page(): void
    {
        $admin = User::factory()->create(['is_super_admin' => true]);

        $this->actingAs($admin)
            ->get(route('admin.login'))
            ->assertRedirect('/admin');
    }

    public function test_non_admin_cannot_log_in_to_admin_panel(): void
    {
        $user = User::factory()->create([
            'email' => 'member@example.com',
            'password' => 'password',
            'is_super_admin' => false,
        ]);

        Livewire::test(Login::class)
            ->set('email', $user->email)
            ->set('password', 'password')
            ->call('authenticate')
            ->assertHasErrors(['email' => 'Akun tidak memiliki akses admin.']);

        $this->assertGuest();
    }

    public function test_authenticated_non_admin_is_logged_out_instead_of_redirect_looping(): void
    {
        $user = User::factory()->create(['is_super_admin' => false]);

        $this->actingAs($user)
            ->get(route('admin.dashboard'))
            ->assertRedirect(route('admin.login'))
            ->assertSessionHas('error', 'Akun tidak memiliki akses admin.');

        $this->assertGuest();
    }

    public function test_super_admin_can_log_in(): void
    {
        $admin = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => 'password',
            'is_super_admin' => true,
        ]);

        Livewire::test(Login::class)
            ->set('email', $admin->email)
            ->set('password', 'password')
            ->call('authenticate')
            ->assertRedirect(route('admin.dashboard'));

        $this->assertAuthenticatedAs($admin);
    }
}
