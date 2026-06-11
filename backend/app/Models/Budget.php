<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Budget extends Model
{
    protected $fillable = [
        'household_id',
        'scope',
        'owner_user_id',
        'category_id',
        'amount',
        'period_month',
    ];

    protected function casts(): array
    {
        return [
            // Stored as bigint IDR
            'amount' => 'integer',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Null for family-scope budgets */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
