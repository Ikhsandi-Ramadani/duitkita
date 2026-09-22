<?php

namespace App\Livewire\Admin\Households;

use App\Models\Household;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.admin')]
class Index extends Component
{
    use WithPagination;

    public function render(): View
    {
        return view('livewire.admin.households.index', [
            'households' => Household::with('owner:id,name')
                ->withCount('members')
                ->latest()
                ->paginate(15),
        ])->title('Keluarga');
    }
}
