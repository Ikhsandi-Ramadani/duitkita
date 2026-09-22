<?php

namespace App\Livewire\Admin\Wallets;

use App\Models\Household;
use App\Models\Wallet;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.admin')]
class Index extends Component
{
    use WithPagination;

    public bool $showEdit = false;

    public bool $showDelete = false;

    public ?int $selectedId = null;

    public string $selectedName = '';

    public string $name = '';

    public string $type = 'cash';

    public function edit(int $id): void
    {
        $wallet = Wallet::findOrFail($id);
        $this->selectedId = $wallet->id;
        $this->name = $wallet->name;
        $this->type = $wallet->type;
        $this->resetValidation();
        $this->showEdit = true;
    }

    public function update(): void
    {
        $data = $this->validate([
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:cash,bank,ewallet'],
        ]);

        Wallet::findOrFail($this->selectedId)->update($data);
        $this->closeModal();
        session()->flash('success', 'Dompet berhasil diperbarui.');
    }

    public function askDelete(int $id): void
    {
        $wallet = Wallet::findOrFail($id);
        $this->selectedId = $wallet->id;
        $this->selectedName = $wallet->name;
        $this->resetValidation();
        $this->showDelete = true;
    }

    public function delete(): void
    {
        Wallet::findOrFail($this->selectedId)->delete();
        $this->closeModal();
        session()->flash('success', 'Dompet berhasil dihapus.');
    }

    public function closeModal(): void
    {
        $this->reset(['showEdit', 'showDelete', 'selectedId', 'selectedName', 'name', 'type']);
        $this->type = 'cash';
        $this->resetValidation();
    }

    public function render(): View
    {
        return view('livewire.admin.wallets.index', [
            'wallets' => Wallet::with('household:id,name')->latest()->paginate(15),
            'households' => Household::select('id', 'name')->orderBy('name')->get(),
        ])->title('Dompet');
    }
}
