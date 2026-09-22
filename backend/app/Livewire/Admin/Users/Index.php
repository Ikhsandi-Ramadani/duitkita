<?php

namespace App\Livewire\Admin\Users;

use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.admin')]
class Index extends Component
{
    use WithPagination;

    public bool $showEdit = false;

    public bool $showDelete = false;

    public bool $showPassword = false;

    public ?int $selectedId = null;

    public string $selectedName = '';

    public string $name = '';

    public string $email = '';

    public string $role = 'member';

    public string $password = '';

    public string $password_confirmation = '';

    public function edit(int $id): void
    {
        $user = User::findOrFail($id);
        $this->selectedId = $user->id;
        $this->name = $user->name;
        $this->email = $user->email;
        $this->role = $user->role ?? 'member';
        $this->resetValidation();
        $this->showEdit = true;
    }

    public function update(): void
    {
        $data = $this->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', Rule::unique('users', 'email')->ignore($this->selectedId)],
            'role' => ['required', 'in:owner,member'],
        ]);

        User::findOrFail($this->selectedId)->update($data);
        $this->closeModal();
        session()->flash('success', 'Pengguna berhasil diperbarui.');
    }

    public function askDelete(int $id): void
    {
        $user = User::findOrFail($id);
        $this->selectedId = $user->id;
        $this->selectedName = $user->name;
        $this->resetValidation();
        $this->showDelete = true;
    }

    public function delete(): void
    {
        User::findOrFail($this->selectedId)->delete();
        $this->closeModal();
        session()->flash('success', 'Pengguna berhasil dihapus.');
    }

    public function askPasswordReset(int $id): void
    {
        $user = User::findOrFail($id);
        $this->selectedId = $user->id;
        $this->selectedName = $user->name;
        $this->password = '';
        $this->password_confirmation = '';
        $this->resetValidation();
        $this->showPassword = true;
    }

    public function resetPassword(): void
    {
        $data = $this->validate([
            'password' => ['required', 'min:8', 'confirmed'],
        ]);

        User::findOrFail($this->selectedId)->update(['password' => Hash::make($data['password'])]);
        $this->closeModal();
        session()->flash('success', 'Password pengguna berhasil direset.');
    }

    public function closeModal(): void
    {
        $this->reset(['showEdit', 'showDelete', 'showPassword', 'selectedId', 'selectedName', 'name', 'email', 'role', 'password', 'password_confirmation']);
        $this->role = 'member';
        $this->resetValidation();
    }

    public function render(): View
    {
        return view('livewire.admin.users.index', [
            'users' => User::with('household:id,name')
                ->select(['id', 'name', 'email', 'phone', 'household_id', 'role', 'is_super_admin', 'created_at', 'updated_at'])
                ->latest()
                ->paginate(15),
        ])->title('Pengguna');
    }
}
