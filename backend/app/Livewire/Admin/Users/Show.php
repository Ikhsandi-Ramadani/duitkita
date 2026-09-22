<?php

namespace App\Livewire\Admin\Users;

use App\Models\User;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.admin')]
class Show extends Component
{
    public User $user;

    public function mount(User $user): void
    {
        $this->user = $user;
    }

    public function render(): View
    {
        $this->user->load([
            'household.owner',
            'wallets',
            'recordedTransactions' => fn ($query) => $query->latest()->limit(20)->with([
                'category:id,name,type',
                'wallet:id,name',
            ]),
        ]);

        return view('livewire.admin.users.show')->title('Detail pengguna');
    }
}
