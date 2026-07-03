<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Mobile's local pseudo-id (device timestamp based) stays stable
        // across retries of the same create call, unlike Transaction which
        // has a real client-generated UUID. Reusing it here as an
        // idempotency key prevents a retried/duplicated POST from creating
        // a second permanent row for one user action.
        Schema::table('debts', function (Blueprint $table) {
            $table->unsignedBigInteger('client_ref')->nullable()->after('household_id');
            $table->unique(['household_id', 'client_ref']);
        });

        Schema::table('recurrings', function (Blueprint $table) {
            $table->unsignedBigInteger('client_ref')->nullable()->after('household_id');
            $table->unique(['household_id', 'client_ref']);
        });
    }

    public function down(): void
    {
        Schema::table('debts', function (Blueprint $table) {
            $table->dropUnique(['household_id', 'client_ref']);
            $table->dropColumn('client_ref');
        });

        Schema::table('recurrings', function (Blueprint $table) {
            $table->dropUnique(['household_id', 'client_ref']);
            $table->dropColumn('client_ref');
        });
    }
};
