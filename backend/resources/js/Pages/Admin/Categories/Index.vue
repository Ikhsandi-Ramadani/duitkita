<template>
    <Layout>
        <!-- Filter Bar -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm px-5 py-4 mb-4">
            <div class="flex flex-wrap items-center gap-3">
                <div class="relative">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-4 w-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2"
                    >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <InputText
                        v-model="filters.search"
                        placeholder="Cari kategori..."
                        class="pl-9 w-52"
                        @input="applyFilters"
                    />
                </div>
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
                <button
                    class="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
                    @click="resetFilters"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    Reset
                </button>
                <div class="ml-auto">
                    <button
                        class="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium bg-green-600 text-white hover:bg-green-700 transition-colors shadow-sm"
                        @click="openCreate"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                        </svg>
                        Tambah Kategori
                    </button>
                </div>
            </div>
        </div>

        <!-- Table Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Kategori</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ categories.total }} total kategori</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="categories.data"
                data-key="id"
                class="p-datatable-sm"
            >
                <!-- Household -->
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Keluarga</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.household?.name ?? '-' }}</span>
                    </template>
                </Column>

                <!-- Nama -->
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nama</span>
                    </template>
                    <template #body="{ data }">
                        <div class="flex items-center gap-2">
                            <span
                                v-if="data.icon"
                                class="text-base leading-none"
                                :style="data.hue ? { color: `hsl(${data.hue}, 65%, 45%)` } : {}"
                            >{{ data.icon }}</span>
                            <div
                                v-else
                                class="w-5 h-5 rounded-full shrink-0"
                                :style="data.hue
                                    ? { background: `hsl(${data.hue}, 65%, 45%)` }
                                    : { background: '#94a3b8' }"
                            />
                            <span class="text-slate-800 text-sm font-medium">{{ data.name }}</span>
                        </div>
                    </template>
                </Column>

                <!-- Tipe -->
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
                                    : 'bg-red-100 text-red-600',
                            ]"
                        >
                            {{ data.type === 'income' ? 'Pemasukan' : 'Pengeluaran' }}
                        </span>
                    </template>
                </Column>

                <!-- Icon -->
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Icon</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm font-mono">{{ data.icon || '-' }}</span>
                    </template>
                </Column>

                <!-- Induk -->
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Induk</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.parent?.name ?? '-' }}</span>
                    </template>
                </Column>

                <!-- Aksi -->
                <Column style="width: 90px;">
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Aksi</span>
                    </template>
                    <template #body="{ data }">
                        <div class="flex items-center gap-1.5">
                            <button
                                class="p-1.5 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                                @click="openEdit(data)"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                </svg>
                            </button>
                            <button
                                class="p-1.5 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                                @click="openDelete(data)"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                </svg>
                            </button>
                        </div>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-3 border-t border-slate-100 bg-slate-50/50">
                <span class="text-slate-400 text-xs">
                    Halaman {{ categories.current_page }} dari {{ categories.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!categories.prev_page_url"
                        @click="router.visit(categories.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!categories.next_page_url"
                        @click="router.visit(categories.next_page_url)"
                    >
                        Berikutnya
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <!-- Create / Edit Dialog -->
        <Dialog
            v-model:visible="formVisible"
            :header="formMode === 'create' ? 'Tambah Kategori' : 'Edit Kategori'"
            :style="{ width: '460px' }"
            :modal="true"
        >
            <div class="space-y-4 pt-2">
                <!-- Household -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Keluarga <span class="text-red-500">*</span></label>
                    <Select
                        v-model="form.household_id"
                        :options="households"
                        option-label="name"
                        option-value="id"
                        placeholder="Pilih keluarga"
                        class="w-full"
                        :invalid="!!form.errors.household_id"
                        @change="form.parent_id = null"
                    />
                    <small v-if="form.errors.household_id" class="text-red-500 text-xs">{{ form.errors.household_id }}</small>
                </div>

                <!-- Nama -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Nama <span class="text-red-500">*</span></label>
                    <InputText
                        v-model="form.name"
                        class="w-full"
                        :invalid="!!form.errors.name"
                        placeholder="Nama kategori"
                    />
                    <small v-if="form.errors.name" class="text-red-500 text-xs">{{ form.errors.name }}</small>
                </div>

                <!-- Tipe -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Tipe <span class="text-red-500">*</span></label>
                    <Select
                        v-model="form.type"
                        :options="typeOptions"
                        option-label="label"
                        option-value="value"
                        placeholder="Pilih tipe"
                        class="w-full"
                        :invalid="!!form.errors.type"
                        @change="form.parent_id = null"
                    />
                    <small v-if="form.errors.type" class="text-red-500 text-xs">{{ form.errors.type }}</small>
                </div>

                <!-- Kategori Induk -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Kategori Induk <span class="text-slate-400 font-normal">(opsional)</span></label>
                    <Select
                        v-model="form.parent_id"
                        :options="parentOptions"
                        option-label="name"
                        option-value="id"
                        placeholder="Tidak ada (kategori utama)"
                        show-clear
                        class="w-full"
                        :disabled="!form.household_id || !form.type"
                        :invalid="!!form.errors.parent_id"
                    />
                    <small v-if="!form.household_id || !form.type" class="text-slate-400 text-xs">Pilih keluarga dan tipe dulu</small>
                    <small v-if="form.errors.parent_id" class="text-red-500 text-xs">{{ form.errors.parent_id }}</small>
                </div>

                <!-- Icon -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Icon <span class="text-slate-400 font-normal">(opsional)</span></label>
                    <div class="flex items-center gap-2">
                        <InputText
                            v-model="form.icon"
                            class="flex-1"
                            placeholder="Emoji atau nama icon, mis: 🍔 atau pi-tag"
                            :invalid="!!form.errors.icon"
                        />
                        <div
                            v-if="form.icon"
                            class="w-9 h-9 rounded-lg border border-slate-200 flex items-center justify-center text-lg shrink-0"
                        >{{ form.icon }}</div>
                    </div>
                    <small v-if="form.errors.icon" class="text-red-500 text-xs">{{ form.errors.icon }}</small>
                </div>

                <!-- Warna / Hue -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Warna (Hue 0–360) <span class="text-slate-400 font-normal">(opsional)</span></label>
                    <div class="flex items-center gap-3">
                        <InputNumber
                            v-model="form.hue"
                            :min="0"
                            :max="360"
                            class="flex-1"
                            placeholder="mis: 120"
                            :invalid="!!form.errors.hue"
                        />
                        <div
                            class="w-9 h-9 rounded-lg border border-slate-200 shrink-0 transition-colors"
                            :style="form.hue != null
                                ? { background: `hsl(${form.hue}, 65%, 45%)` }
                                : { background: '#e2e8f0' }"
                        />
                    </div>
                    <small v-if="form.errors.hue" class="text-red-500 text-xs">{{ form.errors.hue }}</small>
                </div>
            </div>

            <template #footer>
                <Button label="Batal" severity="secondary" outlined @click="formVisible = false" />
                <Button
                    :label="formMode === 'create' ? 'Simpan' : 'Perbarui'"
                    severity="success"
                    :loading="form.processing"
                    @click="submitForm"
                />
            </template>
        </Dialog>

        <!-- Delete Confirmation Dialog -->
        <Dialog
            v-model:visible="deleteVisible"
            header="Hapus Kategori"
            :style="{ width: '380px' }"
            :modal="true"
        >
            <p class="text-slate-600">
                Yakin ingin menghapus kategori <strong class="text-slate-900">{{ deleteTarget?.name }}</strong>?
                Tindakan ini tidak dapat dibatalkan.
            </p>
            <template #footer>
                <Button label="Batal" severity="secondary" outlined @click="deleteVisible = false" />
                <Button label="Hapus" severity="danger" :loading="deleting" @click="submitDelete" />
            </template>
        </Dialog>
    </Layout>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { router, useForm } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'

const props = defineProps({
    categories: Object,
    households: Array,
})

// ─── Type options ─────────────────────────────────────────────────────────────
const typeOptions = [
    { label: 'Pemasukan', value: 'income' },
    { label: 'Pengeluaran', value: 'expense' },
]

// ─── Filters ──────────────────────────────────────────────────────────────────
const params = new URLSearchParams(window.location.search)
const filters = reactive({
    search: params.get('search') ?? '',
    type: params.get('type') ?? null,
})

let searchTimer = null
function applyFilters() {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
        const query = {}
        if (filters.search) query.search = filters.search
        if (filters.type) query.type = filters.type
        router.get('/admin/categories', query, { preserveState: true, replace: true })
    }, 350)
}

function resetFilters() {
    filters.search = ''
    filters.type = null
    router.get('/admin/categories', {}, { preserveState: true, replace: true })
}

// ─── Parent category options (filtered by household + type) ───────────────────
const parentOptions = computed(() => {
    if (!form.household_id || !form.type) return []
    return props.categories.data.filter(c =>
        c.household_id === form.household_id &&
        c.type === form.type &&
        c.parent_id === null &&
        c.id !== form._editId
    )
})

// ─── Create / Edit form ───────────────────────────────────────────────────────
const formVisible = ref(false)
const formMode = ref('create')

const form = useForm({
    _editId: null,
    household_id: null,
    name: '',
    type: null,
    parent_id: null,
    icon: '',
    hue: null,
})

function openCreate() {
    form.reset()
    form._editId = null
    formMode.value = 'create'
    formVisible.value = true
}

function openEdit(category) {
    form.reset()
    form._editId = category.id
    form.household_id = category.household_id
    form.name = category.name
    form.type = category.type
    form.parent_id = category.parent_id
    form.icon = category.icon ?? ''
    form.hue = category.hue ?? null
    formMode.value = 'edit'
    formVisible.value = true
}

function submitForm() {
    if (formMode.value === 'create') {
        form.post('/admin/categories', {
            preserveScroll: true,
            onSuccess: () => { formVisible.value = false },
        })
    } else {
        form.put(`/admin/categories/${form._editId}`, {
            preserveScroll: true,
            onSuccess: () => { formVisible.value = false },
        })
    }
}

// ─── Delete ───────────────────────────────────────────────────────────────────
const deleteVisible = ref(false)
const deleting = ref(false)
const deleteTarget = ref(null)

function openDelete(category) {
    deleteTarget.value = category
    deleteVisible.value = true
}

function submitDelete() {
    deleting.value = true
    router.delete(`/admin/categories/${deleteTarget.value.id}`, {
        preserveScroll: true,
        onSuccess: () => { deleteVisible.value = false },
        onFinish: () => { deleting.value = false },
    })
}
</script>
