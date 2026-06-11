<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            $table->enum('scope', ['personal', 'shared']);
            // Required when scope = personal; null when scope = shared
            $table->foreignId('owner_user_id')
                  ->nullable()
                  ->constrained('users')
                  ->nullOnDelete();
            $table->string('name');
            $table->enum('type', ['cash', 'bank', 'ewallet']);
            $table->string('icon')->nullable();
            $table->string('color')->nullable();
            // All monetary values stored as bigInt IDR (no decimals)
            $table->bigInteger('initial_balance')->default(0);
            $table->bigInteger('current_balance')->default(0);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallets');
    }
};
