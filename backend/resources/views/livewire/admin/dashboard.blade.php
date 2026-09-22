<div>
    <x-admin.page-header title="Ringkasan" description="Data nyata aplikasi pada saat halaman dibuka.">
        <x-slot:actions>
            <a href="{{ route('admin.transactions.index') }}" class="admin-button admin-button-secondary">Lihat transaksi</a>
            <a href="{{ route('admin.users.index') }}" class="admin-button admin-button-primary">Kelola pengguna</a>
        </x-slot:actions>
    </x-admin.page-header>

    <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4" aria-label="Ringkasan data">
        @foreach ([
            ['label' => 'Pengguna', 'value' => $stats['total_users'], 'note' => $stats['new_users_month'].' pengguna baru bulan ini', 'tone' => 'emerald'],
            ['label' => 'Keluarga', 'value' => $stats['total_households'], 'note' => 'Total keluarga terdaftar', 'tone' => 'sky'],
            ['label' => 'Transaksi', 'value' => $stats['total_transactions'], 'note' => 'Semua transaksi tersimpan', 'tone' => 'violet'],
            ['label' => 'Pengeluaran', 'value' => 'Rp '.number_format($stats['total_amount'], 0, ',', '.'), 'note' => 'Akumulasi pengeluaran', 'tone' => 'amber'],
        ] as $stat)
            <div class="admin-card p-5">
                <p class="text-xs font-bold uppercase tracking-[0.08em] text-slate-600">{{ $stat['label'] }}</p>
                <p class="mt-3 break-words text-2xl font-extrabold tracking-tight text-slate-950">{{ $stat['value'] }}</p>
                <p class="mt-2 text-xs font-semibold text-slate-600">{{ $stat['note'] }}</p>
            </div>
        @endforeach
    </section>

    <section class="mt-6 grid gap-6 xl:grid-cols-[minmax(0,1.5fr)_minmax(19rem,0.8fr)]">
        <div class="admin-card p-5 sm:p-6">
            <div class="flex flex-wrap items-end justify-between gap-3">
                <div>
                    <h2 class="text-base font-extrabold text-slate-900">Arus transaksi enam bulan terakhir</h2>
                    <p class="mt-1 text-sm text-slate-600">Perbandingan nominal pemasukan dan pengeluaran yang tercatat.</p>
                </div>
                <div class="flex gap-4 text-xs font-bold text-slate-600">
                    <span><i class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-emerald-600"></i>Pemasukan</span>
                    <span><i class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-rose-500"></i>Pengeluaran</span>
                </div>
            </div>
            <div class="mt-8 flex h-64 items-end gap-2 border-b border-l border-slate-200 px-3 pb-1 pt-4 sm:gap-4" aria-label="Grafik arus transaksi">
                @foreach ($chart as $item)
                    <div class="flex min-w-0 flex-1 flex-col items-center justify-end gap-2 self-stretch">
                        <div class="flex h-full w-full max-w-16 items-end justify-center gap-1">
                            <div class="w-1/2 rounded-t bg-emerald-600" style="height: {{ max(3, ($item['income'] / $maxChartValue) * 100) }}%" title="Pemasukan {{ number_format($item['income'], 0, ',', '.') }}"></div>
                            <div class="w-1/2 rounded-t bg-rose-500" style="height: {{ max(3, ($item['expense'] / $maxChartValue) * 100) }}%" title="Pengeluaran {{ number_format($item['expense'], 0, ',', '.') }}"></div>
                        </div>
                        <span class="text-[11px] font-bold text-slate-600">{{ $item['label'] }}</span>
                    </div>
                @endforeach
            </div>
        </div>

        <div class="admin-card p-5 sm:p-6">
            <h2 class="text-base font-extrabold text-slate-900">Akses cepat</h2>
            <p class="mt-1 text-sm text-slate-600">Menu yang paling sering dipakai untuk pemeriksaan data.</p>
            <div class="mt-5 divide-y divide-slate-100">
                @foreach ([
                    ['route' => 'admin.users.index', 'label' => 'Pengguna', 'note' => 'Akun dan role'],
                    ['route' => 'admin.households.index', 'label' => 'Keluarga', 'note' => 'Keanggotaan dan kode undang'],
                    ['route' => 'admin.transactions.index', 'label' => 'Transaksi', 'note' => 'Filter aktivitas keuangan'],
                    ['route' => 'admin.settings.data-reset', 'label' => 'Reset data', 'note' => 'Hapus data uji dengan konfirmasi'],
                ] as $item)
                    <a href="{{ route($item['route']) }}" class="flex min-h-16 items-center justify-between gap-4 py-3 hover:text-emerald-800">
                        <span><span class="block text-sm font-bold text-slate-800">{{ $item['label'] }}</span><span class="mt-0.5 block text-xs font-semibold text-slate-600">{{ $item['note'] }}</span></span>
                        <span class="text-lg text-slate-400" aria-hidden="true">›</span>
                    </a>
                @endforeach
            </div>
        </div>
    </section>
</div>
