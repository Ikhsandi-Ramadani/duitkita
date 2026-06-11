<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class SavingsGoal extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'household_id',
        'scope',
        'owner_user_id',
        'name',
        'target_amount',
        'current_amount',
        'target_date',
        'wallet_id',
        'icon',
        'hue',
    ];

    protected function casts(): array
    {
        return [
            'target_amount'  => 'integer',
            'current_amount' => 'integer',
            'hue'            => 'integer',
            'target_date'    => 'date',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Null for family-scope goals */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    /** The wallet acting as storage for this goal */
    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }
}
