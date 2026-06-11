<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DebtController;
use App\Http\Controllers\Api\RecurringController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SavingsGoalController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

// Public auth routes
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('join', [AuthController::class, 'join']);
    Route::post('login', [AuthController::class, 'login']);
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

    Route::apiResource('savings-goals', SavingsGoalController::class);
    Route::post('savings-goals/{savings_goal}/contribute', [SavingsGoalController::class, 'contribute']);

    Route::apiResource('debts', DebtController::class);
    Route::post('debts/{debt}/pay', [DebtController::class, 'pay']);

    Route::apiResource('recurrings', RecurringController::class);
    Route::post('recurrings/{recurring}/run', [RecurringController::class, 'run']);

    // Reports
    Route::get('reports/monthly', [ReportController::class, 'monthly']);

    // Sync
    Route::get('sync', [SyncController::class, 'pull']);
    Route::post('sync/transactions', [SyncController::class, 'push']);
});
