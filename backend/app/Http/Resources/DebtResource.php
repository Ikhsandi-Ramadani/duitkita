<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DebtResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'household_id'  => $this->household_id,
            'owner_user_id' => $this->owner_user_id,
            'type'          => $this->type,
            'party_name'    => $this->party_name,
            'amount'        => $this->amount,
            'paid'          => $this->paid,
            'date'          => $this->date?->toDateString(),
            'due_date'      => $this->due_date?->toDateString(),
            'status'        => $this->status,
            'note'          => $this->note,
            'wallet_id'     => $this->wallet_id,
            'created_at'    => $this->created_at?->toISOString(),
            'updated_at'    => $this->updated_at?->toISOString(),
            'deleted_at'    => $this->deleted_at?->toISOString(),
        ];
    }
}
