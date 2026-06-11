<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Recurring extends Model
{
    protected $fillable = [
        'household_id',
        'type',
        'wallet_id',
        'category_id',
        'amount',
        'freq',
        'next_run_date',
        'end_date',
        'auto_create',
        'note',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'amount'        => 'integer',
            'next_run_date' => 'date',
            'end_date'      => 'date',
            // When true, the scheduler auto-generates a transaction on next_run_date
            'auto_create'   => 'boolean',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
