<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RecurringRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type'          => ['required', 'in:income,expense'],
            'wallet_id'     => ['required', 'integer', 'exists:wallets,id'],
            'category_id'   => ['required', 'integer', 'exists:categories,id'],
            'amount'        => ['required', 'integer', 'min:1'],
            'freq'          => ['required', 'in:daily,weekly,monthly,yearly'],
            'next_run_date' => ['required', 'date'],
            'end_date'      => ['nullable', 'date', 'after:next_run_date'],
            'auto_create'   => ['nullable', 'boolean'],
            'note'          => ['nullable', 'string', 'max:500'],
        ];
    }
}
