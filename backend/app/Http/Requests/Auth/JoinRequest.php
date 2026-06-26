<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class JoinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'invite_code' => ['required', 'string', 'size:6'],
            'name'        => ['required', 'string', 'max:255'],
            'email'       => ['required', 'email', 'unique:users,email'],
            'phone'       => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'password'    => ['required', 'string', 'min:8'],
        ];
    }
}
