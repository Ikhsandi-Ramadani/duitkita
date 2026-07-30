<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class DataResetController extends Controller
{
    private const DATA_TABLES = [
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

    public function index(): Response
    {
        $counts = collect(self::DATA_TABLES)
            ->mapWithKeys(fn (string $table, string $key) => [
                $key => $table === 'users'
                    ? User::query()->where('is_super_admin', false)->count()
                    : DB::table($table)->count(),
            ]);

        return Inertia::render('Admin/Settings/DataReset', [
            'counts' => $counts,
            'confirmationPhrase' => 'RESET DATA',
        ]);
    }

    public function destroy(Request $request): RedirectResponse
    {
        $request->validate([
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
            $memberUserIds = User::query()
                ->where('is_super_admin', false)
                ->select('id');

            DB::table('personal_access_tokens')
                ->where('tokenable_type', User::class)
                ->whereIn('tokenable_id', clone $memberUserIds)
                ->delete();

            DB::table('sessions')
                ->whereIn('user_id', clone $memberUserIds)
                ->delete();

            DB::table('password_reset_tokens')
                ->whereIn(
                    'email',
                    User::query()->where('is_super_admin', false)->select('email')
                )
                ->delete();

            // Deleting households permanently removes all related financial data,
            // including rows that were previously soft-deleted.
            DB::table('households')->delete();

            User::query()
                ->where('is_super_admin', false)
                ->delete();
        });

        Storage::disk('public')->delete(
            $avatarPaths->merge($receiptPaths)->unique()->values()->all()
        );

        return redirect()->route('admin.settings.data-reset')
            ->with('success', 'Data aplikasi berhasil direset. Akun super admin dan pengaturan aplikasi tetap tersimpan.');
    }
}
