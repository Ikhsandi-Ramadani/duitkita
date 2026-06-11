<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add owner_id FK after users table has household_id column.
     * Circular dependency: households.owner_id → users, users.household_id → households.
     * Solved by deferring this FK to a separate migration that runs after both tables exist.
     */
    public function up(): void
    {
        Schema::table('households', function (Blueprint $table) {
            $table->foreign('owner_id')
                  ->references('id')
                  ->on('users')
                  ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('households', function (Blueprint $table) {
            $table->dropForeign(['owner_id']);
        });
    }
};
