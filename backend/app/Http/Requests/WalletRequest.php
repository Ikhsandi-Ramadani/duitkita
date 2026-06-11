<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class WalletRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'scope'           => ['required', 'in:personal,shared'],
            'name'            => ['required', 'string', 'max:255'],
            'type'            => ['required', 'in:cash,bank,ewallet'],
            'icon'            => ['nullable', 'string', 'max:50'],
            'color'           => ['nullable', 'string', 'max:20'],
            'initial_balance' => ['nullable', 'integer'],
        ];
    }
}
