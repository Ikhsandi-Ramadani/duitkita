<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ContributeGoalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount'           => ['required', 'integer', 'min:1'],
            'source_wallet_id' => ['required', 'integer', 'exists:wallets,id'],
        ];
    }
}
