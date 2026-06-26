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
        $userId = $this->user()->id;

        return [
            'name'       => ['sometimes', 'string', 'max:255'],
            'phone'      => ['sometimes', 'nullable', 'string', 'max:20', "unique:users,phone,{$userId}"],
            'email'      => ['sometimes', 'email', "unique:users,email,{$userId}"],
            'password'   => ['sometimes', 'string', 'min:8', 'confirmed'],
            'avatar_hue' => ['sometimes', 'integer', 'min:0', 'max:360'],
        ];
    }
}
