<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Transaction extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'client_id',
        'household_id',
        'type',
        'wallet_id',
        'target_wallet_id',
        'category_id',
        'amount',
        'date',
        'note',
        'recorded_by',
        'spent_by',
        'receipt_path',
    ];

    protected function casts(): array
    {
        return [
            // Signed bigint IDR — negative allowed for adjustment type
            'amount' => 'integer',
            'date'   => 'datetime',
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

    /** Populated only for type=transfer */
    public function targetWallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'target_wallet_id');
    }

    /** Null for transfer and adjustment types */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /** User who created the transaction record */
    public function recorder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }

    /** User who made the actual spend (optional; useful for personal tracking within family) */
    public function spender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'spent_by');
    }

    public function splits(): HasMany
    {
        return $this->hasMany(TransactionSplit::class);
    }
}
