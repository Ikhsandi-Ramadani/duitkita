<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BudgetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'household_id'  => $this->household_id,
            'scope'         => $this->scope,
            'owner_user_id' => $this->owner_user_id,
            'category_id'   => $this->category_id,
            'category'      => new CategoryResource($this->whenLoaded('category')),
            'amount'        => $this->amount,
            'period_month'  => $this->period_month,
            'created_at'    => $this->created_at?->toISOString(),
            'updated_at'    => $this->updated_at?->toISOString(),
        ];
    }
}
