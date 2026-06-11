<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RecurringResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'household_id'  => $this->household_id,
            'type'          => $this->type,
            'wallet_id'     => $this->wallet_id,
            'category_id'   => $this->category_id,
            'amount'        => $this->amount,
            'freq'          => $this->freq,
            'next_run_date' => $this->next_run_date?->toDateString(),
            'end_date'      => $this->end_date?->toDateString(),
            'auto_create'   => $this->auto_create,
            'note'          => $this->note,
            'created_by'    => $this->created_by,
            'created_at'    => $this->created_at?->toISOString(),
            'updated_at'    => $this->updated_at?->toISOString(),
        ];
    }
}
