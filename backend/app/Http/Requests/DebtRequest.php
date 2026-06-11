<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DebtRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type'       => ['required', 'in:payable,receivable'],
            'party_name' => ['required', 'string', 'max:255'],
            'amount'     => ['required', 'integer', 'min:1'],
            'date'       => ['required', 'date'],
            'due_date'   => ['nullable', 'date'],
            'note'       => ['nullable', 'string', 'max:500'],
            'wallet_id'  => ['nullable', 'integer', 'exists:wallets,id'],
        ];
    }
}
