<div>
    <x-admin.page-header title="Keluarga" description="Daftar keluarga yang terdaftar di DuitKita." />

    <div class="admin-card overflow-hidden">
        <div class="flex flex-col gap-1 border-b border-slate-100 px-4 py-4 sm:px-6">
            <h2 class="text-base font-extrabold text-slate-900">Semua keluarga</h2>
            <p class="text-xs font-semibold text-slate-600">{{ $households->total() }} keluarga ditemukan.</p>
        </div>
        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead><tr><th>Nama keluarga</th><th>Pemilik</th><th>Kode undang</th><th>Anggota</th><th>Dibuat</th></tr></thead>
                <tbody>
                @forelse ($households as $household)
                    <tr>
                        <td class="font-bold text-slate-800">{{ $household->name }}</td>
                        <td class="text-sm text-slate-700">{{ $household->owner?->name ?? '-' }}</td>
                        <td><code class="rounded bg-emerald-50 px-2 py-1 text-xs font-bold text-emerald-800">{{ $household->invite_code ?? '-' }}</code></td>
                        <td class="text-sm font-semibold text-slate-700">{{ $household->members_count }} orang</td>
                        <td class="text-sm text-slate-600">{{ $household->created_at?->translatedFormat('d M Y') ?? '-' }}</td>
                    </tr>
                @empty
                    <tr><td colspan="5" class="px-4 py-10 text-center text-sm font-semibold text-slate-600">Belum ada keluarga. Data keluarga akan muncul setelah pengguna membuat keluarga.</td></tr>
                @endforelse
                </tbody>
            </table>
        </div>
        <x-admin.pagination :items="$households" />
    </div>
</div>
