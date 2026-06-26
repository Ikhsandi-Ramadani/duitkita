<template>
    <Layout>
        <div class="bg-[#1e293b] rounded-2xl border border-slate-700 overflow-hidden">
            <!-- Header + Filters -->
            <div class="px-6 py-4 border-b border-slate-700 space-y-3">
                <div class="flex items-center justify-between">
                    <h2 class="text-white font-semibold text-lg">Transaksi</h2>
                    <span class="text-slate-400 text-sm">{{ transactions.total }} total</span>
                </div>

                <!-- Filter Toolbar -->
                <div class="flex flex-wrap gap-3">
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
                    <Button
                        label="Reset"
                        severity="secondary"
                        size="small"
                        outlined
                        @click="resetFilters"
                    />
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="transactions.data"
                data-key="id"
                class="p-datatable-sm"
                striped-rows
            >
                <Column header="Catatan">
                    <template #body="{ data }">
                        <span class="text-slate-200 text-sm">{{ data.note ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Jumlah">
                    <template #body="{ data }">
                        <span
                            :class="[
                                'font-semibold text-sm',
                                data.type === 'income' ? 'text-green-400' : 'text-red-400',
                            ]"
                        >
                            {{ formatRupiah(data.amount) }}
                        </span>
                    </template>
                </Column>
                <Column header="Tipe">
                    <template #body="{ data }">
                        <Tag
                            :value="typeLabel(data.type)"
                            :severity="typeSeverity(data.type)"
                        />
                    </template>
                </Column>
                <Column header="Kategori">
                    <template #body="{ data }">
                        <span class="text-slate-300 text-sm">{{ data.category?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Dompet">
                    <template #body="{ data }">
                        <span class="text-slate-300 text-sm">{{ data.wallet?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Dicatat Oleh">
                    <template #body="{ data }">
                        <span class="text-slate-300 text-sm">{{ data.recorder?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Tanggal">
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.date ?? data.created_at) }}</span>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-4 border-t border-slate-700">
                <span class="text-slate-400 text-sm">
                    Halaman {{ transactions.current_page }} dari {{ transactions.last_page }}
                </span>
                <div class="flex gap-2">
                    <Button
                        label="Sebelumnya"
                        icon="pi pi-chevron-left"
                        severity="secondary"
                        size="small"
                        :disabled="!transactions.prev_page_url"
                        @click="router.visit(transactions.prev_page_url)"
                    />
                    <Button
                        label="Berikutnya"
                        icon="pi pi-chevron-right"
                        icon-pos="right"
                        severity="secondary"
                        size="small"
                        :disabled="!transactions.next_page_url"
                        @click="router.visit(transactions.next_page_url)"
                    />
                </div>
            </div>
        </div>
    </Layout>
</template>

<script setup>
import { reactive } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import Select from 'primevue/select'
import DatePicker from 'primevue/datepicker'

defineProps({
    transactions: Object,
})

const page = usePage()

const typeOptions = [
    { label: 'Pemasukan', value: 'income' },
    { label: 'Pengeluaran', value: 'expense' },
    { label: 'Transfer', value: 'transfer' },
]

// Init filters from current URL query params
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

function typeSeverity(type) {
    const map = { income: 'success', expense: 'danger', transfer: 'info', adjustment: 'secondary' }
    return map[type] ?? 'secondary'
}
</script>
