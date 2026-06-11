<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'       => ['sometimes', 'string', 'max:255'],
            'avatar_hue' => ['sometimes', 'integer', 'min:0', 'max:360'],
        ];
    }
}
