<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recurrings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['income', 'expense']);
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->cascadeOnDelete();
            $table->bigInteger('amount');
            $table->enum('freq', ['daily', 'weekly', 'monthly', 'yearly'])->default('monthly');
            $table->date('next_run_date');
            $table->date('end_date')->nullable();
            // When true, scheduler auto-creates a transaction on next_run_date
            $table->boolean('auto_create')->default(false);
            $table->string('note')->nullable();
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recurrings');
    }
};
