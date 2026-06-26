<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Household;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_users'        => User::count(),
            'total_households'   => Household::count(),
            'total_transactions' => Transaction::count(),
            'total_amount'       => Transaction::where('type', 'expense')->sum('amount'),
            'new_users_month'    => User::whereMonth('created_at', now()->month)
                                        ->whereYear('created_at', now()->year)
                                        ->count(),
        ];

        $chartData = DB::table('transactions')
            ->selectRaw("DATE_FORMAT(created_at, '%Y-%m') as month, type, SUM(amount) as total")
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month', 'type')
            ->orderBy('month')
            ->get();

        return Inertia::render('Admin/Dashboard', [
            'stats'     => $stats,
            'chartData' => $chartData,
        ]);
    }
}
