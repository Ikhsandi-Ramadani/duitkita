<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Household;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Inertia\Inertia;

class WalletController extends Controller
{
    public function index()
    {
        $wallets = Wallet::with('household:id,name')
            ->latest()
            ->paginate(15)
            ->withQueryString();

        $households = Household::select('id', 'name')->orderBy('name')->get();

        return Inertia::render('Admin/Wallets/Index', [
            'wallets'    => $wallets,
            'households' => $households,
        ]);
    }

    public function update(Request $request, Wallet $wallet)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:cash,bank,ewallet',
        ]);

        $wallet->update($data);

        return back()->with('success', 'Wallet berhasil diperbarui.');
    }

    public function destroy(Wallet $wallet)
    {
        $wallet->delete();

        return back()->with('success', 'Wallet berhasil dihapus.');
    }
}
