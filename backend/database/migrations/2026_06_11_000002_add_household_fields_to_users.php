<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('household_id')
                  ->nullable()
                  ->after('remember_token')
                  ->constrained('households')
                  ->nullOnDelete();
            $table->enum('role', ['owner', 'member'])->default('member')->after('household_id');
            $table->smallInteger('avatar_hue')->default(0)->after('role');
            // hashed 6-digit app-lock PIN, nullable (PIN not required)
            $table->string('pin')->nullable()->after('avatar_hue');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['household_id']);
            $table->dropColumn(['household_id', 'role', 'avatar_hue', 'pin']);
        });
    }
};
