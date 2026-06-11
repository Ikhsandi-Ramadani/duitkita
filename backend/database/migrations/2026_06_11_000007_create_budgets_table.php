<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            $table->enum('scope', ['family', 'personal'])->default('family');
            // Null when scope=family; points to user when scope=personal
            $table->foreignId('owner_user_id')
                  ->nullable()
                  ->constrained('users')
                  ->cascadeOnDelete();
            $table->foreignId('category_id')->constrained()->cascadeOnDelete();
            $table->bigInteger('amount');
            // Format: 'YYYY-MM' e.g. '2026-06'
            $table->string('period_month', 7);
            $table->timestamps();

            // One budget per category per scope/owner per month within a household
            $table->unique(['household_id', 'scope', 'owner_user_id', 'category_id', 'period_month'], 'budgets_scope_period_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};

