<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Category extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'household_id',
        'name',
        'type',
        'icon',
        'hue',
        'parent_id',
    ];

    protected function casts(): array
    {
        return [
            'hue' => 'integer',
        ];
    }

    // Relations

    public function household(): BelongsTo
    {
        return $this->belongsTo(Household::class);
    }

    /** Parent category (null = root) */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'parent_id');
    }

    /** Direct children subcategories */
    public function children(): HasMany
    {
        return $this->hasMany(Category::class, 'parent_id');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    public function budgets(): HasMany
    {
        return $this->hasMany(Budget::class);
    }

    public function recurrings(): HasMany
    {
        return $this->hasMany(Recurring::class);
    }
}
