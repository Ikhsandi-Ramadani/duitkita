<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = Transaction::with(['category:id,name', 'wallet:id,name', 'recorder:id,name'])
            ->latest();

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('from')) {
            $query->whereDate('created_at', '>=', $request->from);
        }

        if ($request->filled('until')) {
            $query->whereDate('created_at', '<=', $request->until);
        }

        $transactions = $query->paginate(20)->withQueryString();

        return Inertia::render('Admin/Transactions/Index', ['transactions' => $transactions]);
    }
}
