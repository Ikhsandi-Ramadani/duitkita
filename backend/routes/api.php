<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\DownloadController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DebtController;
use App\Http\Controllers\Api\RecurringController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SavingsGoalController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\VersionController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

// Public version check (no auth required)
Route::get('version', [VersionController::class, 'index']);

// Public APK download (no auth) — used by the in-app update flow.
Route::get('download/apk', [DownloadController::class, 'apk']);

// Public auth routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('join', [AuthController::class, 'join']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('reset-password', [AuthController::class, 'resetPassword']);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {

    // Auth profile
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);
    Route::put('me', [AuthController::class, 'updateMe']);
    Route::put('me/pin', [AuthController::class, 'updatePin']);
    Route::post('me/pin/verify', [AuthController::class, 'verifyPin']);

    // Resources
    Route::apiResource('wallets', WalletController::class);
    Route::apiResource('categories', CategoryController::class);
    Route::apiResource('budgets', BudgetController::class);
    Route::apiResource('transactions', TransactionController::class);
    Route::post('transactions/{id}/receipt', [TransactionController::class, 'uploadReceipt']);
    Route::put('transactions/{id}/splits', [TransactionController::class, 'updateSplits']);

    Route::apiResource('savings-goals', SavingsGoalController::class);
    Route::post('savings-goals/{savings_goal}/contribute', [SavingsGoalController::class, 'contribute']);

    Route::apiResource('debts', DebtController::class);
    Route::post('debts/{debt}/pay', [DebtController::class, 'pay']);

    Route::apiResource('recurrings', RecurringController::class);
    Route::post('recurrings/{recurring}/run', [RecurringController::class, 'run']);

    // Household member management
    Route::delete('household/members/{user_id}', [AuthController::class, 'removeMember']);

    // Reports
    Route::get('reports/monthly', [ReportController::class, 'monthly']);

    // Notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::put('notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::put('notifications/{id}/read', [NotificationController::class, 'markRead']);

    // Sync
    Route::get('sync', [SyncController::class, 'pull']);
    Route::post('sync/transactions', [SyncController::class, 'push']);
});
