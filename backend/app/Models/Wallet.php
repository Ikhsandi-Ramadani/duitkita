<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Wallet extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'household_id',
        'scope',
        'owner_user_id',
        'name',
        'type',
        'icon',
        'color',
        'initial_balance',
        'current_balance',
    ];

    protected function casts(): array
    {
        return [
            // Stored as bigint IDR — cast to int for arithmetic safety in PHP
            'initial_balance' => 'integer',
            'current_balance' => 'integer',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Null for shared wallets */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    /** Incoming transfers targeting this wallet */
    public function incomingTransfers(): HasMany
    {
        return $this->hasMany(Transaction::class, 'target_wallet_id');
    }

    public function savingsGoals(): HasMany
    {
        return $this->hasMany(SavingsGoal::class);
    }

    public function debts(): HasMany
    {
        return $this->hasMany(Debt::class);
    }

    public function recurrings(): HasMany
    {
        return $this->hasMany(Recurring::class);
    }
}
