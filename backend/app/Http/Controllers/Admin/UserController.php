<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class UserController extends Controller
{
    public function index()
    {
        $users = User::with('household:id,name')
            ->select(['id', 'name', 'email', 'phone', 'household_id', 'role', 'is_super_admin', 'created_at', 'updated_at'])
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('Admin/Users/Index', ['users' => $users]);
    }

    public function show(User $user)
    {
        $user->load([
            'household.owner',
            'wallets',
            'recordedTransactions' => fn ($q) => $q->latest()->limit(20)->with([
                'category:id,name,type',
                'wallet:id,name',
            ]),
        ]);

        return Inertia::render('Admin/Users/Show', ['user' => $user]);
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'role'  => 'required|in:owner,member',
        ]);

        $user->update($data);
        return back()->with('success', 'User diperbarui.');
    }

    public function resetPassword(Request $request, User $user)
    {
        $request->validate([
            'password' => 'required|min:8|confirmed',
        ]);

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return back()->with('success', 'Password berhasil direset.');
    }

    public function destroy(User $user)
    {
        $user->delete();
        return back()->with('success', 'User dihapus.');
    }
}
