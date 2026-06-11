<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Debt extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'household_id',
        'owner_user_id',
        'type',
        'party_name',
        'amount',
        'paid',
        'date',
        'due_date',
        'status',
        'note',
        'wallet_id',
    ];

    protected function casts(): array
    {
        return [
            'amount'   => 'integer',
            'paid'     => 'integer',
            'date'     => 'date',
            'due_date' => 'date',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Null for family/shared-scope debts */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    /** Wallet used for disbursement or repayment tracking; nullable */
    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }
}
