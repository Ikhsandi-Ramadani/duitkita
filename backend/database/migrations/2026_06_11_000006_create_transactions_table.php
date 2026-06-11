<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            // UUID for client-side idempotency during sync (offline-first)
            $table->uuid('client_id')->unique();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['income', 'expense', 'transfer', 'adjustment']);
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            // Only populated for type=transfer
            $table->foreignId('target_wallet_id')
                  ->nullable()
                  ->constrained('wallets')
                  ->nullOnDelete();
            // Null for transfer and adjustment types
            $table->foreignId('category_id')
                  ->nullable()
                  ->constrained()
                  ->nullOnDelete();
            // Signed bigint: positive for income/expense/transfer, negative allowed for adjustment
            $table->bigInteger('amount');
            $table->dateTime('date');
            $table->string('note')->nullable();
            $table->foreignId('recorded_by')->constrained('users')->cascadeOnDelete();
            // Who made the expense (person tracking); nullable for income/transfer
            $table->foreignId('spent_by')
                  ->nullable()
                  ->constrained('users')
                  ->nullOnDelete();
            $table->string('receipt_path')->nullable();
            $table->timestamps();
            $table->softDeletes();

            // Query performance indexes
            $table->index(['household_id', 'date']);
            $table->index('wallet_id');
            $table->index('recorded_by');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
