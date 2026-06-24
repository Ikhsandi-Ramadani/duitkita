<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaction_splits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained();
            $table->unsignedBigInteger('amount'); // in rupiah
            $table->timestamps();
            $table->unique(['transaction_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaction_splits');
    }
};
