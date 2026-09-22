@props(['items'])

<div class="flex flex-col gap-3 border-t border-slate-100 bg-slate-50/60 px-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-6">
    <p class="text-xs font-semibold text-slate-600">Halaman {{ $items->currentPage() }} dari {{ $items->lastPage() }}</p>
    <div class="flex gap-2">
        <button type="button" class="admin-button admin-button-secondary" wire:click="previousPage" @disabled($items->onFirstPage())>Sebelumnya</button>
        <button type="button" class="admin-button admin-button-secondary" wire:click="nextPage" @disabled(!$items->hasMorePages())>Berikutnya</button>
    </div>
</div>
