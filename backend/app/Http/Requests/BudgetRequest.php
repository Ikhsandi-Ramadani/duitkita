<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class BudgetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'scope'        => ['required', 'in:family,personal'],
            'category_id'  => ['required', 'integer', 'exists:categories,id'],
            'amount'       => ['required', 'integer', 'min:1'],
            'period_month' => ['required', 'string', 'regex:/^\d{4}-\d{2}$/'],
        ];
    }
}
