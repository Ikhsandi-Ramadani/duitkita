<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'household_id'    => $this->household_id,
            'scope'           => $this->scope,
            'owner_user_id'   => $this->owner_user_id,
            'name'            => $this->name,
            'type'            => $this->type,
            'icon'            => $this->icon,
            'color'           => $this->color,
            'initial_balance' => $this->initial_balance,
            'current_balance' => $this->current_balance,
            'created_at'      => $this->created_at?->toISOString(),
            'updated_at'      => $this->updated_at?->toISOString(),
            'deleted_at'      => $this->deleted_at?->toISOString(),
        ];
    }
}
