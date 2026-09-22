@props(['title', 'description' => null])

<div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
    <div>
        <h1 class="text-2xl font-extrabold tracking-tight text-slate-950">{{ $title }}</h1>
        @if ($description)
            <p class="mt-1 text-sm text-slate-600">{{ $description }}</p>
        @endif
    </div>
    @if (isset($actions))
        <div class="flex flex-wrap gap-2">{{ $actions }}</div>
    @endif
</div>
