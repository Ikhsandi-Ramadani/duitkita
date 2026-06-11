<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'      => ['required', 'string', 'max:255'],
            'type'      => ['required', 'in:income,expense'],
            'icon'      => ['required', 'string', 'max:50'],
            'hue'       => ['required', 'integer', 'min:0', 'max:360'],
            'parent_id' => ['nullable', 'integer', 'exists:categories,id'],
        ];
    }
}
