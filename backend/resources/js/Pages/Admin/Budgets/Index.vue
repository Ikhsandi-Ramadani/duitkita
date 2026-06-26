<template>
    <Layout>
        <!-- Filter / Action Bar -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm px-5 py-4 mb-4">
            <div class="flex flex-wrap items-center gap-3">
                <div class="ml-auto">
                    <button
                        class="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium bg-green-600 text-white hover:bg-green-700 transition-colors shadow-sm"
                        @click="openCreate"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                        </svg>
                        Tambah Budget
                    </button>
                </div>
            </div>
        </div>

        <!-- Table Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Budgets</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ budgets.total }} total budget</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="budgets.data"
                data-key="id"
                class="p-datatable-sm"
            >
                <template #empty>
                    <div class="py-8 text-center text-slate-400 text-sm">Belum ada budget</div>
                </template>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Keluarga</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.household?.name ?? '-' }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Kategori</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-800 text-sm font-medium">{{ data.category?.name ?? '-' }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nominal</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-800 font-semibold text-sm">{{ formatRupiah(data.amount) }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Periode</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-500 text-sm">{{ data.period ?? '-' }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Aksi</span>
                    </template>
                    <template #body="{ data }">
                        <div class="flex items-center gap-1.5">
                            <button
                                class="p-1.5 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                                title="Edit"
                                @click="openEdit(data)"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                </svg>
                            </button>
                            <button
                                class="p-1.5 rounded-lg text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                                title="Hapus"
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
                    Halaman {{ budgets.current_page }} dari {{ budgets.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!budgets.prev_page_url"
                        @click="router.visit(budgets.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!budgets.next_page_url"
                        @click="router.visit(budgets.next_page_url)"
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
            :header="isEditing ? 'Edit Budget' : 'Tambah Budget'"
            :style="{ width: '460px' }"
            :modal="true"
        >
            <div class="space-y-4 pt-2">
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Keluarga <span class="text-red-500">*</span></label>
                    <Select
                        v-model="form.household_id"
                        :options="households"
                        option-label="name"
                        option-value="id"
                        placeholder="Pilih keluarga"
                        class="w-full"
                        :invalid="!!errors.household_id"
                        @change="form.category_id = null"
                    />
                    <small v-if="errors.household_id" class="text-red-500 text-xs">{{ errors.household_id }}</small>
                </div>

                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Kategori <span class="text-red-500">*</span></label>
                    <Select
                        v-model="form.category_id"
                        :options="filteredCategories"
                        option-label="name"
                        option-value="id"
                        placeholder="Pilih kategori"
                        class="w-full"
                        :invalid="!!errors.category_id"
                        :disabled="!form.household_id"
                    />
                    <small v-if="!form.household_id" class="text-slate-400 text-xs">Pilih keluarga dulu</small>
                    <small v-if="errors.category_id" class="text-red-500 text-xs">{{ errors.category_id }}</small>
                </div>

                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Nominal <span class="text-red-500">*</span></label>
                    <InputNumber
                        v-model="form.amount"
                        class="w-full"
                        :min="0"
                        :invalid="!!errors.amount"
                        locale="id-ID"
                        prefix="Rp "
                        :use-grouping="true"
                    />
                    <small v-if="errors.amount" class="text-red-500 text-xs">{{ errors.amount }}</small>
                </div>

                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Periode</label>
                    <InputText
                        v-model="form.period"
                        placeholder="contoh: 2024-06"
                        class="w-full"
                        :invalid="!!errors.period"
                    />
                    <small v-if="errors.period" class="text-red-500 text-xs">{{ errors.period }}</small>
                </div>
            </div>
            <template #footer>
                <Button label="Batal" severity="secondary" outlined @click="formVisible = false" />
                <Button :label="isEditing ? 'Simpan' : 'Tambah'" severity="success" :loading="saving" @click="submitForm" />
            </template>
        </Dialog>

        <!-- Delete Confirmation -->
        <Dialog
            v-model:visible="deleteVisible"
            header="Hapus Budget"
            :style="{ width: '380px' }"
            :modal="true"
        >
            <p class="text-slate-600">
                Yakin ingin menghapus budget kategori
                <strong class="text-slate-900">{{ deleteTarget?.category?.name ?? '-' }}</strong>?
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
import { router } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'

const props = defineProps({
    budgets: Object,
    households: Array,
    categories: Array,
})

// Filter categories by selected household
const filteredCategories = computed(() => {
    if (!form.household_id) return []
    return props.categories.filter(c => c.household_id === form.household_id)
})

// Create / Edit
const formVisible = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const errors = reactive({})
const form = reactive({
    id: null,
    household_id: null,
    category_id: null,
    amount: null,
    period: '',
})

function resetForm() {
    Object.assign(form, { id: null, household_id: null, category_id: null, amount: null, period: '' })
    Object.keys(errors).forEach(k => delete errors[k])
}

function openCreate() {
    resetForm()
    isEditing.value = false
    formVisible.value = true
}

function openEdit(budget) {
    resetForm()
    Object.assign(form, {
        id: budget.id,
        household_id: budget.household_id,
        category_id: budget.category_id,
        amount: budget.amount,
        period: budget.period ?? '',
    })
    isEditing.value = true
    formVisible.value = true
}

function submitForm() {
    saving.value = true
    const payload = {
        household_id: form.household_id,
        category_id: form.category_id,
        amount: form.amount,
        period: form.period || null,
    }

    if (isEditing.value) {
        router.put(`/admin/budgets/${form.id}`, payload, {
            preserveScroll: true,
            onSuccess: () => { formVisible.value = false },
            onError: errs => Object.assign(errors, errs),
            onFinish: () => { saving.value = false },
        })
    } else {
        router.post('/admin/budgets', payload, {
            preserveScroll: true,
            onSuccess: () => { formVisible.value = false },
            onError: errs => Object.assign(errors, errs),
            onFinish: () => { saving.value = false },
        })
    }
}

// Delete
const deleteVisible = ref(false)
const deleting = ref(false)
const deleteTarget = ref(null)

function openDelete(budget) {
    deleteTarget.value = budget
    deleteVisible.value = true
}

function submitDelete() {
    deleting.value = true
    router.delete(`/admin/budgets/${deleteTarget.value.id}`, {
        preserveScroll: true,
        onSuccess: () => { deleteVisible.value = false },
        onFinish: () => { deleting.value = false },
    })
}

function formatRupiah(amount) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
    }).format(amount ?? 0)
}
</script>
