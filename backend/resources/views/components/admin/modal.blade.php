@props(['title'])

<div class="admin-modal-backdrop" role="dialog" aria-modal="true" aria-label="{{ $title }}" tabindex="-1" x-data x-on:keydown.escape.window="$wire.closeModal()" wire:keydown.escape.window="closeModal">
    <div class="admin-modal" @click.outside="$wire.closeModal()">
        <div class="flex items-start justify-between gap-4 border-b border-slate-100 px-5 py-4 sm:px-6">
            <h2 class="text-base font-extrabold text-slate-900">{{ $title }}</h2>
            <button type="button" class="inline-flex min-h-11 min-w-11 items-center justify-center rounded-lg text-xl text-slate-500 hover:bg-slate-100" wire:click="closeModal" aria-label="Tutup">&times;</button>
        </div>
        <div class="px-5 py-5 sm:px-6">{{ $slot }}</div>
    </div>
</div>
