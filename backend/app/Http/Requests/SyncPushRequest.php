<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SyncPushRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'transactions'                  => ['required', 'array'],
            'transactions.*.client_id'      => ['required', 'uuid'],
            'transactions.*.type'           => ['required', Rule::in(['income', 'expense', 'transfer', 'adjustment'])],
            'transactions.*.wallet_id'      => ['required', 'integer', 'exists:wallets,id'],
            'transactions.*.target_wallet_id' => ['nullable', 'integer', 'exists:wallets,id'],
            'transactions.*.category_id'    => ['nullable', 'integer', 'exists:categories,id'],
            'transactions.*.amount'         => ['required', 'integer', 'not_in:0'],
            'transactions.*.date'           => ['required', 'date'],
            'transactions.*.note'           => ['nullable', 'string', 'max:500'],
            'transactions.*.spent_by'       => ['nullable', 'integer', 'exists:users,id'],
        ];
    }
}
