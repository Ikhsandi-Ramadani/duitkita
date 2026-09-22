<div class="w-full max-w-md">
    <div class="mb-8 text-center">
        <div class="brand-mark mx-auto flex h-14 w-14 items-center justify-center rounded-2xl text-2xl font-black text-white">D</div>
        <h1 class="mt-5 text-2xl font-extrabold tracking-tight text-slate-950">Masuk ke Panel Admin</h1>
        <p class="mt-2 text-sm text-slate-600">Kelola data DuitKita dari satu tempat.</p>
    </div>

    <form wire:submit="authenticate" class="admin-card space-y-5 p-6 sm:p-8">
        <div>
            <label for="email" class="mb-1.5 block text-sm font-bold text-slate-800">Email</label>
            <input id="email" type="email" wire:model="email" autocomplete="email" class="admin-input" placeholder="admin@example.com">
            @error('email') <p class="admin-error" role="alert">{{ $message }}</p> @enderror
        </div>
        <div>
            <label for="password" class="mb-1.5 block text-sm font-bold text-slate-800">Password</label>
            <input id="password" type="password" wire:model="password" autocomplete="current-password" class="admin-input" placeholder="Masukkan password">
            @error('password') <p class="admin-error" role="alert">{{ $message }}</p> @enderror
        </div>
        <label class="flex min-h-11 items-center gap-3 text-sm font-semibold text-slate-700">
            <input type="checkbox" wire:model="remember" class="h-4 w-4 rounded border-slate-300 text-emerald-700 focus:ring-emerald-600">
            Ingat saya di perangkat ini
        </label>
        <button type="submit" class="admin-button admin-button-primary w-full" wire:loading.attr="disabled" wire:target="authenticate">
            <span wire:loading.remove wire:target="authenticate">Masuk</span>
            <span wire:loading wire:target="authenticate">Memeriksa akses...</span>
        </button>
    </form>

    <p class="mt-6 text-center text-xs font-semibold text-slate-500">DuitKita Admin</p>
</div>
