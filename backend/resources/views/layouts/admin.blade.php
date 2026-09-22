<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title ?? 'DuitKita Admin' }}</title>
    @vite('resources/css/app.css')
    @livewireStyles
</head>
<body class="font-sans antialiased">
    <div x-data="{ sidebarOpen: false }" class="admin-shell min-h-screen lg:flex">
        <div x-cloak x-show="sidebarOpen" x-transition.opacity class="fixed inset-0 z-30 bg-slate-950/40 lg:hidden" @click="sidebarOpen = false"></div>

        <aside class="fixed inset-y-0 left-0 z-40 flex w-72 -translate-x-full flex-col border-r border-slate-200 bg-white transition-transform duration-200 lg:static lg:translate-x-0" :class="sidebarOpen ? 'translate-x-0' : ''">
            <div class="flex h-20 items-center gap-3 border-b border-slate-100 px-6">
                <div class="brand-mark flex h-10 w-10 items-center justify-center rounded-xl text-lg font-black text-white">D</div>
                <div class="min-w-0">
                    <div class="truncate text-base font-extrabold text-slate-900">DuitKita</div>
                    <div class="text-xs font-semibold text-slate-500">Panel Admin</div>
                </div>
                <button type="button" class="ml-auto inline-flex min-h-11 min-w-11 items-center justify-center rounded-lg text-slate-500 hover:bg-slate-100 lg:hidden" aria-label="Tutup menu" @click="sidebarOpen = false">&times;</button>
            </div>

            <nav class="admin-nav flex-1 overflow-y-auto px-4 py-5" aria-label="Navigasi admin">
                <p class="px-3 pb-2 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">Operasional</p>
                <div class="space-y-1">
                    @php($nav = [
                        ['route' => 'admin.dashboard', 'label' => 'Ringkasan', 'icon' => '▦'],
                        ['route' => 'admin.users.index', 'label' => 'Pengguna', 'icon' => '♙'],
                        ['route' => 'admin.households.index', 'label' => 'Keluarga', 'icon' => '⌂'],
                        ['route' => 'admin.transactions.index', 'label' => 'Transaksi', 'icon' => '↔'],
                        ['route' => 'admin.wallets.index', 'label' => 'Dompet', 'icon' => '▣'],
                        ['route' => 'admin.categories.index', 'label' => 'Kategori', 'icon' => '≡'],
                        ['route' => 'admin.budgets.index', 'label' => 'Anggaran', 'icon' => '◫'],
                    ])
                    @foreach ($nav as $item)
                        <a href="{{ route($item['route']) }}" @class([
                            'flex min-h-11 items-center gap-3 rounded-lg px-3 text-sm font-semibold transition-colors',
                            'bg-emerald-50 text-emerald-800' => request()->routeIs($item['route']),
                            'text-slate-600 hover:bg-slate-50 hover:text-slate-900' => ! request()->routeIs($item['route']),
                        ])>
                            <span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-sm text-slate-600" aria-hidden="true">{{ $item['icon'] }}</span>
                            <span>{{ $item['label'] }}</span>
                        </a>
                    @endforeach
                </div>

                <p class="px-3 pb-2 pt-7 text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">Pengaturan</p>
                <div class="space-y-1">
                    <a href="{{ route('admin.settings.app-version') }}" @class([
                        'flex min-h-11 items-center gap-3 rounded-lg px-3 text-sm font-semibold transition-colors',
                        'bg-emerald-50 text-emerald-800' => request()->routeIs('admin.settings.app-version'),
                        'text-slate-600 hover:bg-slate-50 hover:text-slate-900' => ! request()->routeIs('admin.settings.app-version'),
                    ])><span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-sm text-slate-600" aria-hidden="true">⌁</span>Versi aplikasi</a>
                    <a href="{{ route('admin.settings.data-reset') }}" @class([
                        'flex min-h-11 items-center gap-3 rounded-lg px-3 text-sm font-semibold transition-colors',
                        'bg-emerald-50 text-emerald-800' => request()->routeIs('admin.settings.data-reset'),
                        'text-slate-600 hover:bg-slate-50 hover:text-slate-900' => ! request()->routeIs('admin.settings.data-reset'),
                    ])><span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-sm text-slate-600" aria-hidden="true">⌫</span>Reset data</a>
                </div>
            </nav>

            <div class="border-t border-slate-100 p-4">
                <div class="mb-3 flex items-center gap-3 rounded-lg bg-slate-50 p-3">
                    <div class="flex h-9 w-9 items-center justify-center rounded-full bg-emerald-100 text-sm font-extrabold text-emerald-800">{{ str($user?->name ?? 'A')->substr(0, 1)->upper() }}</div>
                    <div class="min-w-0 flex-1">
                        <p class="truncate text-sm font-bold text-slate-800">{{ $user?->name ?? 'Admin' }}</p>
                        <p class="truncate text-xs text-slate-600">Super Admin</p>
                    </div>
                </div>
                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" class="admin-button admin-button-secondary w-full">Keluar</button>
                </form>
            </div>
        </aside>

        <div class="flex min-h-screen min-w-0 flex-1 flex-col">
            <header class="sticky top-0 z-20 flex min-h-20 items-center justify-between border-b border-slate-200/80 bg-white/95 px-4 backdrop-blur-sm sm:px-6 lg:px-9">
                <div class="flex min-w-0 items-center gap-3">
                    <button type="button" class="inline-flex min-h-11 min-w-11 items-center justify-center rounded-lg text-xl text-slate-600 hover:bg-slate-100 lg:hidden" aria-label="Buka menu" @click="sidebarOpen = true">☰</button>
                    <div class="min-w-0">
                        <p class="truncate text-sm font-bold text-slate-900">{{ $heading ?? 'Panel Admin' }}</p>
                        <p class="hidden text-xs text-slate-600 sm:block">Kelola data aplikasi dan pantau aktivitas keluarga</p>
                    </div>
                </div>
                <div class="hidden items-center gap-2 text-xs font-semibold text-slate-500 sm:flex"><span class="h-2 w-2 rounded-full bg-emerald-600" aria-hidden="true"></span>Admin aktif</div>
            </header>

            <main class="admin-content flex-1 overflow-y-auto px-4 py-6 sm:px-6 lg:px-9 lg:py-8">
                @if (session('success'))
                    <div role="status" class="mb-5 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-800">{{ session('success') }}</div>
                @endif
                @if (session('error'))
                    <div role="alert" class="mb-5 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm font-semibold text-rose-800">{{ session('error') }}</div>
                @endif
                {{ $slot }}
            </main>
        </div>
    </div>
    @livewireScripts
</body>
</html>
