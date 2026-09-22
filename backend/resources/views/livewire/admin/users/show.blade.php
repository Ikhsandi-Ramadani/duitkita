<div>
    <x-admin.page-header title="Detail pengguna" description="Informasi akun, keluarga, dompet, dan transaksi terakhir.">
        <x-slot:actions><a href="{{ route('admin.users.index') }}" class="admin-button admin-button-secondary">Kembali ke pengguna</a></x-slot:actions>
    </x-admin.page-header>

    <section class="admin-card p-5 sm:p-6">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center">
            <div class="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-xl font-extrabold text-emerald-800">{{ str($user->name)->substr(0, 1)->upper() }}</div>
            <div class="min-w-0"><h2 class="truncate text-lg font-extrabold text-slate-950">{{ $user->name }}</h2><p class="mt-1 break-all text-sm text-slate-700">{{ $user->email }}</p>@if($user->phone)<p class="mt-1 text-xs font-semibold text-slate-600">{{ $user->phone }}</p>@endif</div>
            <div class="flex flex-wrap gap-2 sm:ml-auto"><span class="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-bold text-slate-700">{{ $user->role === 'owner' ? 'Owner' : 'Member' }}</span>@if($user->is_super_admin)<span class="rounded-md bg-violet-50 px-2.5 py-1 text-xs font-bold text-violet-800">Super Admin</span>@endif</div>
        </div>
        <p class="mt-5 text-xs font-semibold text-slate-600">Bergabung {{ $user->created_at?->translatedFormat('d M Y') ?? '-' }}</p>
    </section>

    <div class="mt-6 grid gap-6 lg:grid-cols-2">
        <section class="admin-card overflow-hidden">
            <div class="border-b border-slate-100 px-5 py-4 sm:px-6"><h2 class="text-base font-extrabold text-slate-900">Keluarga</h2></div>
            <div class="p-5 sm:p-6">@if($user->household)<p class="font-bold text-slate-800">{{ $user->household->name }}</p><p class="mt-1 text-sm text-slate-600">Owner: {{ $user->household->owner?->name ?? '-' }}</p>@else<p class="text-sm font-semibold text-slate-600">Pengguna ini belum bergabung ke keluarga.</p>@endif</div>
        </section>
        <section class="admin-card overflow-hidden">
            <div class="border-b border-slate-100 px-5 py-4 sm:px-6"><h2 class="text-base font-extrabold text-slate-900">Dompet</h2><p class="mt-1 text-xs font-semibold text-slate-600">{{ $user->wallets->count() }} dompet</p></div>
            <div class="divide-y divide-slate-100">@forelse($user->wallets as $wallet)<div class="flex items-center justify-between gap-3 px-5 py-3 sm:px-6"><div><p class="text-sm font-bold text-slate-800">{{ $wallet->name }}</p><p class="mt-0.5 text-xs font-semibold capitalize text-slate-600">{{ $wallet->type }}</p></div><span @class(['text-sm font-extrabold', 'text-emerald-700' => $wallet->current_balance >= 0, 'text-rose-700' => $wallet->current_balance < 0])>Rp {{ number_format($wallet->current_balance, 0, ',', '.') }}</span></div>@empty<p class="p-5 text-sm font-semibold text-slate-600 sm:p-6">Belum ada dompet.</p>@endforelse</div>
        </section>
    </div>

    <section class="admin-card mt-6 overflow-hidden">
        <div class="border-b border-slate-100 px-5 py-4 sm:px-6"><h2 class="text-base font-extrabold text-slate-900">Transaksi terakhir</h2><p class="mt-1 text-xs font-semibold text-slate-600">Maksimal 20 transaksi yang dicatat pengguna ini.</p></div>
        <div class="admin-table-wrap"><table class="admin-table"><thead><tr><th>Tanggal</th><th>Kategori</th><th>Dompet</th><th>Nominal</th><th>Catatan</th></tr></thead><tbody>@forelse($user->recordedTransactions as $transaction)<tr><td class="whitespace-nowrap text-sm text-slate-700">{{ $transaction->created_at?->translatedFormat('d M Y') ?? '-' }}</td><td class="text-sm font-semibold text-slate-800">{{ $transaction->category?->name ?? '-' }}</td><td class="text-sm text-slate-700">{{ $transaction->wallet?->name ?? '-' }}</td><td @class(['whitespace-nowrap text-sm font-extrabold', 'text-emerald-700' => $transaction->type === 'income', 'text-rose-700' => $transaction->type === 'expense', 'text-slate-800' => ! in_array($transaction->type, ['income', 'expense'], true)])>{{ $transaction->type === 'income' ? '+' : ($transaction->type === 'expense' ? '-' : '') }}Rp {{ number_format(abs($transaction->amount), 0, ',', '.') }}</td><td class="max-w-60 truncate text-sm text-slate-600">{{ $transaction->note ?? '-' }}</td></tr>@empty<tr><td colspan="5" class="px-4 py-10 text-center text-sm font-semibold text-slate-600">Belum ada transaksi yang dicatat pengguna ini.</td></tr>@endforelse</tbody></table></div>
    </section>
</div>
