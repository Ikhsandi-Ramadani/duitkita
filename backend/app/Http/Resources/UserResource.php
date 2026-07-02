<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'name'         => $this->name,
            'email'        => $this->email,
            'phone'        => $this->phone,
            'role'         => $this->role,
            'avatar_hue'   => $this->avatar_hue,
            'avatar_path'  => $this->avatar_path,
            'household_id' => $this->household_id,
            'has_pin'      => !empty($this->pin),
            'created_at'   => $this->created_at?->toISOString(),
        ];
    }
}
