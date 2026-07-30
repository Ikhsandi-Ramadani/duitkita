<?php

use App\Http\Controllers\Admin\AppVersionController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\BudgetController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DataResetController;
use App\Http\Controllers\Admin\HouseholdController;
use App\Http\Controllers\Admin\TransactionController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\WalletController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => auth()->check()
    ? redirect()->route('admin.dashboard')
    : redirect()->route('admin.login'));

Route::prefix('admin')->name('admin.')->group(function () {
    // Guest only
    Route::middleware('guest')->group(function () {
        Route::get('login', [AuthController::class, 'showLogin'])->name('login');
        Route::post('login', [AuthController::class, 'login']);
    });

    // Logout — auth only, no super_admin required
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

    // Super admin only
    Route::middleware(['auth', 'super_admin'])->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        Route::get('users', [UserController::class, 'index'])->name('users.index');
        Route::get('users/{user}', [UserController::class, 'show'])->name('users.show');
        Route::put('users/{user}', [UserController::class, 'update'])->name('users.update');
        Route::put('users/{user}/reset-password', [UserController::class, 'resetPassword'])->name('users.reset-password');
        Route::delete('users/{user}', [UserController::class, 'destroy'])->name('users.destroy');

        Route::get('households', [HouseholdController::class, 'index'])->name('households.index');
        Route::get('transactions', [TransactionController::class, 'index'])->name('transactions.index');

        Route::get('categories', [CategoryController::class, 'index'])->name('categories.index');
        Route::post('categories', [CategoryController::class, 'store'])->name('categories.store');
        Route::put('categories/{category}', [CategoryController::class, 'update'])->name('categories.update');
        Route::delete('categories/{category}', [CategoryController::class, 'destroy'])->name('categories.destroy');

        Route::get('wallets', [WalletController::class, 'index'])->name('wallets.index');
        Route::put('wallets/{wallet}', [WalletController::class, 'update'])->name('wallets.update');
        Route::delete('wallets/{wallet}', [WalletController::class, 'destroy'])->name('wallets.destroy');

        Route::get('budgets', [BudgetController::class, 'index'])->name('budgets.index');
        Route::post('budgets', [BudgetController::class, 'store'])->name('budgets.store');
        Route::put('budgets/{budget}', [BudgetController::class, 'update'])->name('budgets.update');
        Route::delete('budgets/{budget}', [BudgetController::class, 'destroy'])->name('budgets.destroy');

        Route::get('settings/app-version', [AppVersionController::class, 'index'])->name('settings.app-version');
        Route::post('settings/app-version', [AppVersionController::class, 'update'])->name('settings.app-version.update');
        Route::get('settings/data-reset', [DataResetController::class, 'index'])->name('settings.data-reset');
        Route::delete('settings/data-reset', [DataResetController::class, 'destroy'])->name('settings.data-reset.destroy');
    });
});
