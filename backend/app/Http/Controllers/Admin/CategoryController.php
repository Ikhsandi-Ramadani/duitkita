<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Household;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::with(['household:id,name', 'parent:id,name'])
            ->latest()
            ->paginate(15)
            ->withQueryString();

        $households = Household::orderBy('name')->get(['id', 'name']);

        return Inertia::render('Admin/Categories/Index', [
            'categories' => $categories,
            'households' => $households,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name'         => 'required|string|max:255',
            'type'         => 'required|in:income,expense',
            'household_id' => 'required|exists:households,id',
            'icon'         => 'nullable|string|max:100',
            'hue'          => 'nullable|integer|min:0|max:360',
            'parent_id'    => 'nullable|exists:categories,id',
        ]);

        Category::create($data);

        return back()->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name'         => 'required|string|max:255',
            'type'         => 'required|in:income,expense',
            'household_id' => 'required|exists:households,id',
            'icon'         => 'nullable|string|max:100',
            'hue'          => 'nullable|integer|min:0|max:360',
            'parent_id'    => 'nullable|exists:categories,id',
        ]);

        $category->update($data);

        return back()->with('success', 'Kategori berhasil diperbarui.');
    }

    public function destroy(Category $category)
    {
        $category->delete();

        return back()->with('success', 'Kategori berhasil dihapus.');
    }
}
