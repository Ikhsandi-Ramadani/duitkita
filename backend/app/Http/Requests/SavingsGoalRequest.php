<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SavingsGoalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'scope'         => ['required', 'in:family,personal'],
            'name'          => ['required', 'string', 'max:255'],
            'target_amount' => ['required', 'integer', 'min:1'],
            'target_date'   => ['nullable', 'date'],
            'wallet_id'     => ['required', 'integer', 'exists:wallets,id'],
            'icon'          => ['required', 'string', 'max:50'],
            'hue'           => ['required', 'integer', 'min:0', 'max:360'],
        ];
    }
}
