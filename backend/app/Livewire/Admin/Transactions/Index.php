<?php

namespace App\Livewire\Admin\Transactions;

use App\Models\Transaction;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.admin')]
class Index extends Component
{
    use WithPagination;

    public ?string $type = null;

    public ?string $dateFrom = null;

    public ?string $dateUntil = null;

    public function updatedType(): void
    {
        $this->resetPage();
    }

    public function updatedDateFrom(): void
    {
        $this->resetPage();
    }

    public function updatedDateUntil(): void
    {
        $this->resetPage();
    }

    public function resetFilters(): void
    {
        $this->reset(['type', 'dateFrom', 'dateUntil']);
        $this->resetPage();
    }

    public function render(): View
    {
        $query = Transaction::with(['category:id,name', 'wallet:id,name', 'recorder:id,name'])->latest();

        if ($this->type) {
            $query->where('type', $this->type);
        }

        if ($this->dateFrom) {
            $query->whereDate('created_at', '>=', $this->dateFrom);
        }

        if ($this->dateUntil) {
            $query->whereDate('created_at', '<=', $this->dateUntil);
        }

        return view('livewire.admin.transactions.index', [
            'transactions' => $query->paginate(20),
        ])->title('Transaksi');
    }
}
