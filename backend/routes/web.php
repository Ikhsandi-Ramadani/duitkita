<?php

use App\Livewire\Admin\Budgets\Index as BudgetsIndex;
use App\Livewire\Admin\Categories\Index as CategoriesIndex;
use App\Livewire\Admin\Dashboard;
use App\Livewire\Admin\Households\Index as HouseholdsIndex;
use App\Livewire\Admin\Login;
use App\Livewire\Admin\Settings\AppVersion;
use App\Livewire\Admin\Settings\DataReset;
use App\Livewire\Admin\Transactions\Index as TransactionsIndex;
use App\Livewire\Admin\Users\Index as UsersIndex;
use App\Livewire\Admin\Users\Show as UserShow;
use App\Livewire\Admin\Wallets\Index as WalletsIndex;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => auth()->check()
    ? redirect()->route('admin.dashboard')
    : redirect()->route('admin.login'));

Route::prefix('admin')->name('admin.')->group(function (): void {
    Route::middleware('guest')->group(function (): void {
        Route::get('login', Login::class)->name('login');
    });

    Route::post('logout', function () {
        Auth::logout();
        request()->session()->invalidate();
        request()->session()->regenerateToken();

        return redirect()->route('admin.login');
    })->middleware('auth')->name('logout');

    Route::middleware(['auth', 'super_admin'])->group(function (): void {
        Route::get('/', Dashboard::class)->name('dashboard');

        Route::get('users', UsersIndex::class)->name('users.index');
        Route::get('users/{user}', UserShow::class)->name('users.show');
        Route::get('households', HouseholdsIndex::class)->name('households.index');
        Route::get('transactions', TransactionsIndex::class)->name('transactions.index');
        Route::get('categories', CategoriesIndex::class)->name('categories.index');
        Route::get('wallets', WalletsIndex::class)->name('wallets.index');
        Route::get('budgets', BudgetsIndex::class)->name('budgets.index');
        Route::get('settings/app-version', AppVersion::class)->name('settings.app-version');
        Route::get('settings/data-reset', DataReset::class)->name('settings.data-reset');
    });
});
