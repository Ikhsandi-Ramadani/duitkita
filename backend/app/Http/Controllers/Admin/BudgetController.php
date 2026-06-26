<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Budget;
use App\Models\Category;
use App\Models\Household;
use Illuminate\Http\Request;
use Inertia\Inertia;

class BudgetController extends Controller
{
    public function index()
    {
        $budgets = Budget::with([
            'household:id,name',
            'category:id,name,type',
        ])
            ->latest()
            ->paginate(15)
            ->withQueryString();

        $households = Household::select('id', 'name')->orderBy('name')->get();

        $categories = Category::select('id', 'name', 'type', 'household_id')
            ->orderBy('name')
            ->get();

        return Inertia::render('Admin/Budgets/Index', [
            'budgets'    => $budgets,
            'households' => $households,
            'categories' => $categories,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'household_id'  => 'required|exists:households,id',
            'scope'         => 'required|in:family,personal',
            'owner_user_id' => 'nullable|exists:users,id',
            'category_id'   => 'required|exists:categories,id',
            'amount'        => 'required|integer|min:1',
            'period_month'  => ['required', 'string', 'regex:/^\d{4}-(0[1-9]|1[0-2])$/'],
        ]);

        Budget::create($data);

        return back()->with('success', 'Budget berhasil ditambahkan.');
    }

    public function update(Request $request, Budget $budget)
    {
        $data = $request->validate([
            'household_id'  => 'required|exists:households,id',
            'scope'         => 'required|in:family,personal',
            'owner_user_id' => 'nullable|exists:users,id',
            'category_id'   => 'required|exists:categories,id',
            'amount'        => 'required|integer|min:1',
            'period_month'  => ['required', 'string', 'regex:/^\d{4}-(0[1-9]|1[0-2])$/'],
        ]);

        $budget->update($data);

        return back()->with('success', 'Budget berhasil diperbarui.');
    }

    public function destroy(Budget $budget)
    {
        $budget->delete();

        return back()->with('success', 'Budget berhasil dihapus.');
    }
}
