<div>
    <x-admin.page-header title="Versi aplikasi" description="Informasi versi yang dibaca aplikasi mobile saat memeriksa pembaruan." />
    <div class="max-w-3xl">
        <form wire:submit="save" class="admin-card space-y-5 p-5 sm:p-7">
            <div class="grid gap-5 sm:grid-cols-2">
                <div><label for="app-version" class="mb-1 block text-sm font-bold text-slate-800">Versi</label><input id="app-version" wire:model="app_version" class="admin-input" placeholder="1.0.0">@error('app_version')<p class="admin-error">{{ $message }}</p>@enderror</div>
                <div><label for="app-build" class="mb-1 block text-sm font-bold text-slate-800">Build</label><input id="app-build" type="number" min="1" wire:model="app_build" class="admin-input">@error('app_build')<p class="admin-error">{{ $message }}</p>@enderror</div>
            </div>
            <div><label for="app-download-url" class="mb-1 block text-sm font-bold text-slate-800">URL download APK</label><input id="app-download-url" type="url" wire:model="app_download_url" class="admin-input" placeholder="https://contoh.test/download/duitkita.apk">@error('app_download_url')<p class="admin-error">{{ $message }}</p>@enderror</div>
            <div><label for="app-release-notes" class="mb-1 block text-sm font-bold text-slate-800">Catatan rilis</label><textarea id="app-release-notes" wire:model="app_release_notes" class="admin-textarea" placeholder="Tuliskan perubahan pada versi ini."></textarea>@error('app_release_notes')<p class="admin-error">{{ $message }}</p>@enderror</div>
            <label class="flex min-h-11 items-center gap-3 text-sm font-semibold text-slate-800"><input type="checkbox" wire:model="app_force_update" class="h-4 w-4 rounded border-slate-300 text-emerald-700 focus:ring-emerald-600">Wajibkan pembaruan pada versi lama</label>
            <div class="flex justify-end border-t border-slate-100 pt-5"><button type="submit" class="admin-button admin-button-primary" wire:loading.attr="disabled"><span wire:loading.remove wire:target="save">Simpan pengaturan</span><span wire:loading wire:target="save">Menyimpan...</span></button></div>
        </form>
    </div>
</div>
