<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('savings_goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('household_id')->constrained()->cascadeOnDelete();
            $table->enum('scope', ['family', 'personal']);
            $table->foreignId('owner_user_id')
                  ->nullable()
                  ->constrained('users')
                  ->nullOnDelete();
            $table->string('name');
            $table->bigInteger('target_amount');
            $table->bigInteger('current_amount')->default(0);
            $table->date('target_date')->nullable();
            // Dedicated wallet where savings are stored/tracked
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->string('icon');
            $table->smallInteger('hue');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('savings_goals');
    }
};
