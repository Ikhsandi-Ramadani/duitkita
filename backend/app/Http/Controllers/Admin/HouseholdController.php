<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Household;
use Inertia\Inertia;

class HouseholdController extends Controller
{
    public function index()
    {
        $households = Household::with('owner:id,name')
            ->withCount('members')
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('Admin/Households/Index', ['households' => $households]);
    }
}
