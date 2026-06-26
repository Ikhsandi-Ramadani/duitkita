<template>
    <Layout>
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Keluarga</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ households.total }} total keluarga terdaftar</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="households.data"
                data-key="id"
                class="p-datatable-sm"
            >
                <Column field="name" header="Nama Keluarga">
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nama Keluarga</span>
                    </template>
                    <template #body="{ data }">
                        <div class="flex items-center gap-2.5">
                            <div class="w-7 h-7 rounded-full bg-blue-100 flex items-center justify-center shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                </svg>
                            </div>
                            <span class="text-slate-800 text-sm font-medium">{{ data.name }}</span>
                        </div>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Pemilik</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.owner?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Kode Undang</span>
                    </template>
                    <template #body="{ data }">
                        <code class="font-mono text-xs bg-green-50 text-green-700 border border-green-200 px-2 py-1 rounded">
                            {{ data.invite_code ?? '-' }}
                        </code>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Anggota</span>
                    </template>
                    <template #body="{ data }">
                        <span class="inline-flex items-center gap-1 text-slate-600 text-sm">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
                            {{ data.members_count }} orang
                        </span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Dibuat</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.created_at) }}</span>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-3 border-t border-slate-100 bg-slate-50/50">
                <span class="text-slate-400 text-xs">
                    Halaman {{ households.current_page }} dari {{ households.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!households.prev_page_url"
                        @click="router.visit(households.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!households.next_page_url"
                        @click="router.visit(households.next_page_url)"
                    >
                        Berikutnya
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </Layout>
</template>

<script setup>
import { router } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'

defineProps({
    households: Object,
})

function formatDate(dateStr) {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('id-ID', {
        day: 'numeric', month: 'short', year: 'numeric',
    })
}
</script>
