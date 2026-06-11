<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'household_id' => $this->household_id,
            'name'         => $this->name,
            'type'         => $this->type,
            'icon'         => $this->icon,
            'hue'          => $this->hue,
            'parent_id'    => $this->parent_id,
            'created_at'   => $this->created_at?->toISOString(),
            'updated_at'   => $this->updated_at?->toISOString(),
        ];
    }
}
