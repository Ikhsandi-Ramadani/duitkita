<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'client_id'        => $this->client_id,
            'household_id'     => $this->household_id,
            'type'             => $this->type,
            'wallet_id'        => $this->wallet_id,
            'target_wallet_id' => $this->target_wallet_id,
            'category_id'      => $this->category_id,
            'category'         => new CategoryResource($this->whenLoaded('category')),
            'amount'           => $this->amount,
            'date'             => $this->date?->toISOString(),
            'note'             => $this->note,
            'recorded_by'      => $this->recorded_by,
            'spent_by'         => $this->spent_by,
            'receipt_path'     => $this->receipt_path,
            'created_at'       => $this->created_at?->toISOString(),
            'updated_at'       => $this->updated_at?->toISOString(),
            'deleted_at'       => $this->deleted_at?->toISOString(),
        ];
    }
}
