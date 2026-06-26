<template>
    <Layout>
        <!-- Filter Bar -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm px-5 py-4 mb-4">
            <div class="flex flex-wrap items-center gap-3">
                <Select
                    v-model="filters.type"
                    :options="typeOptions"
                    option-label="label"
                    option-value="value"
                    placeholder="Semua Tipe"
                    show-clear
                    class="w-44"
                    @change="applyFilters"
                />
                <DatePicker
                    v-model="filters.from"
                    placeholder="Dari tanggal"
                    date-format="yy-mm-dd"
                    show-button-bar
                    class="w-44"
                    @date-select="applyFilters"
                    @clear-click="applyFilters"
                />
                <DatePicker
                    v-model="filters.until"
                    placeholder="Sampai tanggal"
                    date-format="yy-mm-dd"
                    show-button-bar
                    class="w-44"
                    @date-select="applyFilters"
                    @clear-click="applyFilters"
                />
                <button
                    class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
                    @click="resetFilters"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    Reset
                </button>
            </div>
        </div>

        <!-- Table Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Transaksi</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ transactions.total }} total transaksi</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="transactions.data"
                data-key="id"
                class="p-datatable-sm"
            >
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Catatan</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-700 text-sm">{{ data.note ?? '-' }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Jumlah</span>
                    </template>
                    <template #body="{ data }">
                        <span
                            :class="[
                                'font-semibold text-sm',
                                data.type === 'income' ? 'text-green-600' : 'text-red-500',
                            ]"
                        >
                            {{ data.type === 'income' ? '+' : '-' }}{{ formatRupiah(data.amount) }}
                        </span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Tipe</span>
                    </template>
                    <template #body="{ data }">
                        <span
                            :class="[
                                'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                                data.type === 'income'
                                    ? 'bg-green-100 text-green-700'
                                    : data.type === 'expense'
                                        ? 'bg-red-100 text-red-600'
                                        : data.type === 'transfer'
                                            ? 'bg-blue-100 text-blue-600'
                                            : 'bg-slate-100 text-slate-600',
                            ]"
                        >
                            {{ typeLabel(data.type) }}
                        </span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Kategori</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.category?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Dompet</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.wallet?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Dicatat Oleh</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.recorder?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Tanggal</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.date ?? data.created_at) }}</span>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-3 border-t border-slate-100 bg-slate-50/50">
                <span class="text-slate-400 text-xs">
                    Halaman {{ transactions.current_page }} dari {{ transactions.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!transactions.prev_page_url"
                        @click="router.visit(transactions.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!transactions.next_page_url"
                        @click="router.visit(transactions.next_page_url)"
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
import { reactive } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Select from 'primevue/select'
import DatePicker from 'primevue/datepicker'

defineProps({
    transactions: Object,
})

const typeOptions = [
    { label: 'Pemasukan', value: 'income' },
    { label: 'Pengeluaran', value: 'expense' },
    { label: 'Transfer', value: 'transfer' },
]

const params = new URLSearchParams(window.location.search)
const filters = reactive({
    type: params.get('type') ?? null,
    from: params.get('from') ? new Date(params.get('from')) : null,
    until: params.get('until') ? new Date(params.get('until')) : null,
})

function applyFilters() {
    const query = {}
    if (filters.type) query.type = filters.type
    if (filters.from) query.from = formatIsoDate(filters.from)
    if (filters.until) query.until = formatIsoDate(filters.until)

    router.get('/admin/transactions', query, {
        preserveState: true,
        replace: true,
    })
}

function resetFilters() {
    filters.type = null
    filters.from = null
    filters.until = null
    router.get('/admin/transactions', {}, { preserveState: true, replace: true })
}

function formatIsoDate(date) {
    if (!date) return null
    const d = new Date(date)
    return d.toISOString().slice(0, 10)
}

function formatRupiah(amount) {
    return 'Rp ' + Number(amount).toLocaleString('id-ID')
}

function formatDate(dateStr) {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('id-ID', {
        day: 'numeric', month: 'short', year: 'numeric',
    })
}

function typeLabel(type) {
    const map = { income: 'Pemasukan', expense: 'Pengeluaran', transfer: 'Transfer', adjustment: 'Penyesuaian' }
    return map[type] ?? type
}
</script>
