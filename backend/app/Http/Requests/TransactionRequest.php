<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class TransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'client_id'        => ['nullable', 'uuid'],
            'type'             => ['required', Rule::in(['income', 'expense', 'transfer', 'adjustment'])],
            'wallet_id'        => ['required', 'integer', 'exists:wallets,id'],
            'target_wallet_id' => ['nullable', 'integer', 'exists:wallets,id', 'different:wallet_id'],
            'category_id'      => ['nullable', 'integer', 'exists:categories,id'],
            'amount'           => ['required', 'integer', 'not_in:0'],
            'date'             => ['required', 'date'],
            'note'             => ['nullable', 'string', 'max:500'],
            'spent_by'         => ['nullable', 'integer', 'exists:users,id'],
            'receipt_path'     => ['nullable', 'string', 'max:500'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($v) {
            $type = $this->input('type');

            if ($type === 'transfer' && !$this->input('target_wallet_id')) {
                $v->errors()->add('target_wallet_id', 'target_wallet_id is required for transfer type.');
            }

            if (in_array($type, ['income', 'expense']) && !$this->input('category_id')) {
                // Allow null category_id only if debt_payment flag is set
                if (!$this->input('debt_payment')) {
                    $v->errors()->add('category_id', 'category_id is required for income/expense transactions.');
                }
            }
        });
    }
}
