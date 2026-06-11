<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HouseholdResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'invite_code' => $this->invite_code,
            'owner_id'    => $this->owner_id,
            'members'     => UserResource::collection($this->whenLoaded('members')),
            'created_at'  => $this->created_at?->toISOString(),
        ];
    }
}
