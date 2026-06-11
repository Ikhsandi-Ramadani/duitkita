<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('debts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            // Null = family/shared scope debt
            $table->foreignId('owner_user_id')
                  ->nullable()
                  ->constrained('users')
                  ->nullOnDelete();
            $table->enum('type', ['payable', 'receivable']);
            $table->string('party_name');
            $table->bigInteger('amount');
            $table->bigInteger('paid')->default(0);
            $table->date('date');
            $table->date('due_date')->nullable();
            $table->enum('status', ['ongoing', 'paid'])->default('ongoing');
            $table->string('note')->nullable();
            // Wallet associated with this debt (disbursement/repayment wallet); nullable
            $table->foreignId('wallet_id')
                  ->nullable()
                  ->constrained()
                  ->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('debts');
    }
};
