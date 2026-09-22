<?php

namespace App\Livewire\Admin;

use Illuminate\Support\Facades\Auth;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.admin-auth')]
class Login extends Component
{
    public string $email = '';

    public string $password = '';

    public bool $remember = false;

    public function authenticate()
    {
        $credentials = $this->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials, $this->remember)) {
            $this->addError('email', 'Email atau password salah.');
            $this->reset('password');

            return null;
        }

        if (! auth()->user()->is_super_admin) {
            Auth::logout();
            session()->invalidate();
            session()->regenerateToken();
            $this->addError('email', 'Akun tidak memiliki akses admin.');
            $this->reset('password');

            return null;
        }

        session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    public function render()
    {
        return view('livewire.admin.login');
    }
}
