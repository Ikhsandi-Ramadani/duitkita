<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PayDebtRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount'    => ['required', 'integer', 'min:1'],
            'wallet_id' => ['required', 'integer', 'exists:wallets,id'],
        ];
    }
}
