<div>
    <x-admin.page-header title="Pengguna" description="Kelola akun, role, dan akses admin keluarga." />
    <div class="admin-card overflow-hidden">
        <div class="border-b border-slate-100 px-4 py-4 sm:px-6"><h2 class="text-base font-extrabold text-slate-900">Semua pengguna</h2><p class="mt-1 text-xs font-semibold text-slate-600">{{ $users->total() }} pengguna terdaftar.</p></div>
        <div class="admin-table-wrap"><table class="admin-table"><thead><tr><th>Nama</th><th>Email</th><th>Role</th><th>Keluarga</th><th>Bergabung</th><th>Aksi</th></tr></thead><tbody>
        @forelse($users as $user)
            <tr>
                <td><div class="flex items-center gap-3"><span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-sm font-extrabold text-emerald-800">{{ str($user->name)->substr(0, 1)->upper() }}</span><span class="min-w-0"><span class="block truncate text-sm font-bold text-slate-800">{{ $user->name }}</span>@if($user->is_super_admin)<span class="mt-0.5 block text-[11px] font-bold text-violet-700">Super Admin</span>@endif</span></div></td>
                <td class="text-sm text-slate-700">{{ $user->email }}</td>
                <td><span class="rounded-md bg-slate-100 px-2 py-1 text-xs font-bold text-slate-700">{{ $user->role === 'owner' ? 'Owner' : 'Member' }}</span></td>
                <td class="text-sm text-slate-700">{{ $user->household?->name ?? '-' }}</td>
                <td class="whitespace-nowrap text-sm text-slate-600">{{ $user->created_at?->translatedFormat('d M Y') ?? '-' }}</td>
                <td><div class="flex flex-wrap gap-2"><a href="{{ route('admin.users.show', $user) }}" class="admin-button admin-button-secondary">Detail</a><button type="button" class="admin-button admin-button-secondary" wire:click="edit({{ $user->id }})">Edit</button><button type="button" class="admin-button admin-button-secondary" wire:click="askPasswordReset({{ $user->id }})">Reset password</button><button type="button" class="admin-button admin-button-danger" wire:click="askDelete({{ $user->id }})">Hapus</button></div></td>
            </tr>
        @empty
            <tr><td colspan="6" class="px-4 py-10 text-center text-sm font-semibold text-slate-600">Belum ada pengguna yang terdaftar.</td></tr>
        @endforelse
        </tbody></table></div>
        <x-admin.pagination :items="$users" />
    </div>

    @if($showEdit)
        <x-admin.modal title="Edit pengguna">
            <form wire:submit="update" class="space-y-4">
                <div><label for="user-name" class="mb-1 block text-sm font-bold text-slate-800">Nama</label><input id="user-name" wire:model="name" class="admin-input">@error('name')<p class="admin-error">{{ $message }}</p>@enderror</div>
                <div><label for="user-email" class="mb-1 block text-sm font-bold text-slate-800">Email</label><input id="user-email" type="email" wire:model="email" class="admin-input">@error('email')<p class="admin-error">{{ $message }}</p>@enderror</div>
                <div><label for="user-role" class="mb-1 block text-sm font-bold text-slate-800">Role</label><select id="user-role" wire:model="role" class="admin-select"><option value="owner">Owner</option><option value="member">Member</option></select>@error('role')<p class="admin-error">{{ $message }}</p>@enderror</div>
                <div class="flex justify-end gap-2 pt-2"><button type="button" class="admin-button admin-button-secondary" wire:click="closeModal">Batal</button><button type="submit" class="admin-button admin-button-primary" wire:loading.attr="disabled">Simpan perubahan</button></div>
            </form>
        </x-admin.modal>
    @endif

    @if($showPassword)
        <x-admin.modal title="Reset password">
            <form wire:submit="resetPassword" class="space-y-4">
                <p class="text-sm text-slate-700">Buat password baru untuk <strong class="text-slate-900">{{ $selectedName }}</strong>.</p>
                <div><label for="new-password" class="mb-1 block text-sm font-bold text-slate-800">Password baru</label><input id="new-password" type="password" wire:model="password" class="admin-input" autocomplete="new-password">@error('password')<p class="admin-error">{{ $message }}</p>@enderror</div>
                <div><label for="new-password-confirmation" class="mb-1 block text-sm font-bold text-slate-800">Ulangi password</label><input id="new-password-confirmation" type="password" wire:model="password_confirmation" class="admin-input" autocomplete="new-password"></div>
                <div class="flex justify-end gap-2 pt-2"><button type="button" class="admin-button admin-button-secondary" wire:click="closeModal">Batal</button><button type="submit" class="admin-button admin-button-primary">Simpan password</button></div>
            </form>
        </x-admin.modal>
    @endif

    @if($showDelete)
        <x-admin.modal title="Hapus pengguna">
            <p class="text-sm leading-6 text-slate-700">Pengguna <strong class="text-slate-950">{{ $selectedName }}</strong> akan dihapus. Tindakan ini tidak dapat dibatalkan.</p>
            <div class="mt-5 flex justify-end gap-2"><button type="button" class="admin-button admin-button-secondary" wire:click="closeModal">Batal</button><button type="button" class="admin-button admin-button-danger" wire:click="delete">Hapus pengguna</button></div>
        </x-admin.modal>
    @endif
</div>
