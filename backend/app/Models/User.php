<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'household_id',
        'role',
        'is_super_admin',
        'avatar_hue',
        'pin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'pin', // PIN is a security credential — never serialize to JSON
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
            'pin'               => 'hashed',
            'avatar_hue'        => 'integer',
            'is_super_admin'    => 'boolean',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Households this user owns */
    public function ownedHousehold(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Household::class, 'owner_id');
    }

    public function wallets(): HasMany
    {
        return $this->hasMany(Wallet::class, 'owner_user_id');
    }

    /** Transactions recorded by this user */
    public function recordedTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'recorded_by');
    }

    /** Transactions spent by this user */
    public function spentTransactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'spent_by');
    }

    public function budgets(): HasMany
    {
        return $this->hasMany(Budget::class, 'owner_user_id');
    }

    public function savingsGoals(): HasMany
    {
        return $this->hasMany(SavingsGoal::class, 'owner_user_id');
    }

    public function debts(): HasMany
    {
        return $this->hasMany(Debt::class, 'owner_user_id');
    }

    public function createdRecurrings(): HasMany
    {
        return $this->hasMany(Recurring::class, 'created_by');
    }
}
