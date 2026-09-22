<?php

namespace App\Livewire\Admin\Settings;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.admin')]
class DataReset extends Component
{
    public string $current_password = '';

    public string $confirmation = '';

    public function resetData(): void
    {
        $this->validate([
            'current_password' => ['required', 'current_password'],
            'confirmation' => ['required', Rule::in(['RESET DATA'])],
        ], [
            'current_password.required' => 'Password admin wajib diisi.',
            'current_password.current_password' => 'Password admin tidak sesuai.',
            'confirmation.required' => 'Ketik RESET DATA untuk melanjutkan.',
            'confirmation.in' => 'Teks konfirmasi harus sama persis dengan RESET DATA.',
        ]);

        $avatarPaths = User::query()
            ->where('is_super_admin', false)
            ->whereNotNull('avatar_path')
            ->pluck('avatar_path')
            ->map(fn (string $path) => ltrim(str_replace('/storage/', '', $path), '/'))
            ->filter(fn (string $path) => str_starts_with($path, 'avatars/'));

        $receiptPaths = Transaction::withTrashed()
            ->whereNotNull('receipt_path')
            ->pluck('receipt_path')
            ->map(fn (string $path) => ltrim(str_replace('/storage/', '', $path), '/'))
            ->filter(fn (string $path) => str_starts_with($path, 'receipts/'));

        DB::transaction(function (): void {
            $memberUserIds = User::query()->where('is_super_admin', false)->select('id');

            DB::table('personal_access_tokens')
                ->where('tokenable_type', User::class)
                ->whereIn('tokenable_id', clone $memberUserIds)
                ->delete();
            DB::table('sessions')->whereIn('user_id', clone $memberUserIds)->delete();
            DB::table('password_reset_tokens')
                ->whereIn('email', User::query()->where('is_super_admin', false)->select('email'))
                ->delete();

            DB::table('households')->delete();
            User::query()->where('is_super_admin', false)->delete();
        });

        Storage::disk('public')->delete($avatarPaths->merge($receiptPaths)->unique()->values()->all());
        $this->reset(['current_password', 'confirmation']);
        session()->flash('success', 'Data aplikasi berhasil direset. Akun super admin dan pengaturan aplikasi tetap tersimpan.');
    }

    public function render(): View
    {
        $tables = [
            'households' => 'households',
            'users' => 'users',
            'wallets' => 'wallets',
            'categories' => 'categories',
            'transactions' => 'transactions',
            'budgets' => 'budgets',
            'savings_goals' => 'savings_goals',
            'debts' => 'debts',
            'recurrings' => 'recurrings',
            'notifications' => 'notifications',
        ];

        $counts = collect($tables)->mapWithKeys(fn (string $table, string $key) => [
            $key => $table === 'users'
                ? User::query()->where('is_super_admin', false)->count()
                : DB::table($table)->count(),
        ]);

        return view('livewire.admin.settings.data-reset', [
            'counts' => $counts,
            'confirmationPhrase' => 'RESET DATA',
        ])->title('Reset data');
    }
}
