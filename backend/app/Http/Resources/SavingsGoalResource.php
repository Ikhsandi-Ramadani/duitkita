<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SavingsGoalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'household_id'   => $this->household_id,
            'scope'          => $this->scope,
            'owner_user_id'  => $this->owner_user_id,
            'name'           => $this->name,
            'target_amount'  => $this->target_amount,
            'current_amount' => $this->current_amount,
            'target_date'    => $this->target_date?->toDateString(),
            'wallet_id'      => $this->wallet_id,
            'icon'           => $this->icon,
            'hue'            => $this->hue,
            'created_at'     => $this->created_at?->toISOString(),
            'updated_at'     => $this->updated_at?->toISOString(),
            'deleted_at'     => $this->deleted_at?->toISOString(),
        ];
    }
}
