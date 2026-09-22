<div>
    <x-admin.page-header title="Transaksi" description="Periksa transaksi lintas keluarga dengan filter tanggal dan tipe." />

    <div class="admin-card overflow-hidden">
        <div class="grid gap-3 border-b border-slate-100 px-4 py-4 sm:grid-cols-4 sm:px-6">
            <div class="sm:col-span-1">
                <label for="transaction-type" class="mb-1 block text-xs font-bold text-slate-700">Tipe</label>
                <select id="transaction-type" wire:model.live="type" class="admin-select">
                    <option value="">Semua tipe</option>
                    <option value="income">Pemasukan</option>
                    <option value="expense">Pengeluaran</option>
                    <option value="transfer">Transfer</option>
                    <option value="adjustment">Penyesuaian</option>
                </select>
            </div>
            <div>
                <label for="date-from" class="mb-1 block text-xs font-bold text-slate-700">Dari tanggal</label>
                <input id="date-from" type="date" wire:model.live="dateFrom" class="admin-input">
            </div>
            <div>
                <label for="date-until" class="mb-1 block text-xs font-bold text-slate-700">Sampai tanggal</label>
                <input id="date-until" type="date" wire:model.live="dateUntil" class="admin-input">
            </div>
            <div class="flex items-end"><button type="button" wire:click="resetFilters" class="admin-button admin-button-secondary w-full">Hapus filter</button></div>
        </div>
        <div class="flex items-center justify-between gap-3 border-b border-slate-100 px-4 py-4 sm:px-6">
            <div><h2 class="text-base font-extrabold text-slate-900">Aktivitas keuangan</h2><p class="text-xs font-semibold text-slate-600">{{ $transactions->total() }} transaksi ditemukan.</p></div>
            <span wire:loading class="text-xs font-bold text-emerald-700">Memuat...</span>
        </div>
        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead><tr><th>Tanggal</th><th>Kategori</th><th>Dompet</th><th>Tipe</th><th>Nominal</th><th>Dicatat oleh</th><th>Catatan</th></tr></thead>
                <tbody>
                @forelse ($transactions as $transaction)
                    @php($typeLabel = ['income' => 'Pemasukan', 'expense' => 'Pengeluaran', 'transfer' => 'Transfer', 'adjustment' => 'Penyesuaian'][$transaction->type] ?? $transaction->type)
                    <tr>
                        <td class="whitespace-nowrap text-sm text-slate-700">{{ $transaction->created_at?->translatedFormat('d M Y H:i') ?? '-' }}</td>
                        <td class="text-sm font-semibold text-slate-800">{{ $transaction->category?->name ?? '-' }}</td>
                        <td class="text-sm text-slate-700">{{ $transaction->wallet?->name ?? '-' }}</td>
                        <td><span @class(['rounded-md px-2 py-1 text-xs font-bold', 'bg-emerald-50 text-emerald-800' => $transaction->type === 'income', 'bg-rose-50 text-rose-800' => $transaction->type === 'expense', 'bg-sky-50 text-sky-800' => $transaction->type === 'transfer', 'bg-amber-50 text-amber-800' => $transaction->type === 'adjustment'])>{{ $typeLabel }}</span></td>
                        <td @class(['whitespace-nowrap text-sm font-extrabold', 'text-emerald-700' => $transaction->type === 'income', 'text-rose-700' => $transaction->type === 'expense', 'text-slate-800' => ! in_array($transaction->type, ['income', 'expense'], true)])>{{ $transaction->type === 'income' ? '+' : ($transaction->type === 'expense' ? '-' : '') }}Rp {{ number_format(abs($transaction->amount), 0, ',', '.') }}</td>
                        <td class="text-sm text-slate-700">{{ $transaction->recorder?->name ?? '-' }}</td>
                        <td class="max-w-52 truncate text-sm text-slate-600" title="{{ $transaction->note }}">{{ $transaction->note ?? '-' }}</td>
                    </tr>
                @empty
                    <tr><td colspan="7" class="px-4 py-10 text-center text-sm font-semibold text-slate-600">Tidak ada transaksi untuk filter ini. Coba ubah filter tanggal atau tipe.</td></tr>
                @endforelse
                </tbody>
            </table>
        </div>
        <x-admin.pagination :items="$transactions" />
    </div>
</div>
