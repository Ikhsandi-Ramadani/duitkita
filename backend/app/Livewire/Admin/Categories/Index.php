<?php

namespace App\Livewire\Admin\Categories;

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

    public ?string $search = null;

    public ?string $filterType = null;

    public bool $showForm = false;

    public bool $showDelete = false;

    public ?int $selectedId = null;

    public string $selectedName = '';

    public ?int $household_id = null;

    public string $name = '';

    public string $type = 'expense';

    public ?int $parent_id = null;

    public string $icon = '';

    public ?int $hue = null;

    public function updatedSearch(): void
    {
        $this->resetPage();
    }

    public function updatedFilterType(): void
    {
        $this->resetPage();
    }

    public function updatedHouseholdId(): void
    {
        $this->parent_id = null;
    }

    public function updatedType(): void
    {
        $this->parent_id = null;
    }

    public function openCreate(): void
    {
        $this->resetForm();
        $this->showForm = true;
    }

    public function edit(int $id): void
    {
        $category = Category::findOrFail($id);
        $this->selectedId = $category->id;
        $this->household_id = $category->household_id;
        $this->name = $category->name;
        $this->type = $category->type;
        $this->parent_id = $category->parent_id;
        $this->icon = $category->icon ?? '';
        $this->hue = $category->hue;
        $this->resetValidation();
        $this->showForm = true;
    }

    public function save(): void
    {
        $data = $this->validate([
            'household_id' => ['required', 'exists:households,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'in:income,expense'],
            'icon' => ['nullable', 'string', 'max:100'],
            'hue' => ['nullable', 'integer', 'min:0', 'max:360'],
            'parent_id' => ['nullable', 'exists:categories,id'],
        ]);

        if ($this->selectedId) {
            Category::findOrFail($this->selectedId)->update($data);
            $message = 'Kategori berhasil diperbarui.';
        } else {
            Category::create($data);
            $message = 'Kategori berhasil ditambahkan.';
        }

        $this->closeModal();
        session()->flash('success', $message);
    }

    public function askDelete(int $id): void
    {
        $category = Category::findOrFail($id);
        $this->selectedId = $category->id;
        $this->selectedName = $category->name;
        $this->showDelete = true;
    }

    public function delete(): void
    {
        Category::findOrFail($this->selectedId)->delete();
        $this->closeModal();
        session()->flash('success', 'Kategori berhasil dihapus.');
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
        $this->name = '';
        $this->type = 'expense';
        $this->parent_id = null;
        $this->icon = '';
        $this->hue = null;
    }

    public function render(): View
    {
        $query = Category::with(['household:id,name', 'parent:id,name'])->latest();

        if ($this->search) {
            $query->where('name', 'like', '%'.$this->search.'%');
        }

        if ($this->filterType) {
            $query->where('type', $this->filterType);
        }

        $parentCategories = Category::query()
            ->where('household_id', $this->household_id)
            ->where('type', $this->type)
            ->when($this->selectedId, fn ($query) => $query->where('id', '!=', $this->selectedId))
            ->orderBy('name')
            ->get(['id', 'name']);

        return view('livewire.admin.categories.index', [
            'categories' => $query->paginate(15),
            'households' => Household::orderBy('name')->get(['id', 'name']),
            'parentCategories' => $parentCategories,
        ])->title('Kategori');
    }
}
