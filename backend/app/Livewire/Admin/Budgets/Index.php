<?php

namespace App\Livewire\Admin\Budgets;

use App\Models\Budget;
use App\Models\Category;
use App\Models\Household;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('layouts.admin')]
class Index extends Component
{
    use WithPagination;

    public bool $showForm = false;

    public bool $showDelete = false;

    public ?int $selectedId = null;

    public string $selectedName = '';

    public ?int $household_id = null;

    public string $scope = 'family';

    public ?int $owner_user_id = null;

    public ?int $category_id = null;

    public ?int $amount = null;

    public string $period_month = '';

    public function updatedHouseholdId(): void
    {
        $this->category_id = null;
    }

    public function openCreate(): void
    {
        $this->resetForm();
        $this->showForm = true;
    }

    public function edit(int $id): void
    {
        $budget = Budget::findOrFail($id);
        $this->selectedId = $budget->id;
        $this->household_id = $budget->household_id;
        $this->scope = $budget->scope;
        $this->owner_user_id = $budget->owner_user_id;
        $this->category_id = $budget->category_id;
        $this->amount = $budget->amount;
        $this->period_month = $budget->period_month;
        $this->resetValidation();
        $this->showForm = true;
    }

    public function save(): void
    {
        $data = $this->validate([
            'household_id' => ['required', 'exists:households,id'],
            'scope' => ['required', 'in:family,personal'],
            'owner_user_id' => ['nullable', 'exists:users,id'],
            'category_id' => ['required', 'exists:categories,id'],
            'amount' => ['required', 'integer', 'min:1'],
            'period_month' => ['required', 'date_format:Y-m'],
        ]);

        if ($this->scope === 'family') {
            $data['owner_user_id'] = null;
        }

        if ($this->selectedId) {
            Budget::findOrFail($this->selectedId)->update($data);
            $message = 'Anggaran berhasil diperbarui.';
        } else {
            Budget::create($data);
            $message = 'Anggaran berhasil ditambahkan.';
        }

        $this->closeModal();
        session()->flash('success', $message);
    }

    public function askDelete(int $id): void
    {
        $budget = Budget::with('category:id,name')->findOrFail($id);
        $this->selectedId = $budget->id;
        $this->selectedName = $budget->category?->name ?? 'anggaran ini';
        $this->showDelete = true;
    }

    public function delete(): void
    {
        Budget::findOrFail($this->selectedId)->delete();
        $this->closeModal();
        session()->flash('success', 'Anggaran berhasil dihapus.');
    }

    public function closeModal(): void
    {
        $this->reset(['showForm', 'showDelete', 'selectedId', 'selectedName']);
        $this->resetForm();
        $this->resetValidation();
    }

    public function resetForm(): void
    {
        $this->selectedId = null;
        $this->household_id = null;
        $this->scope = 'family';
        $this->owner_user_id = null;
        $this->category_id = null;
        $this->amount = null;
        $this->period_month = now()->format('Y-m');
    }

    public function render(): View
    {
        $categories = Category::query()
            ->when($this->household_id, fn ($query) => $query->where('household_id', $this->household_id))
            ->orderBy('name')
            ->get(['id', 'name', 'type', 'household_id']);

        return view('livewire.admin.budgets.index', [
            'budgets' => Budget::with(['household:id,name', 'category:id,name,type'])->latest()->paginate(15),
            'households' => Household::select('id', 'name')->orderBy('name')->get(),
            'categories' => $categories,
        ])->title('Anggaran');
    }
}
