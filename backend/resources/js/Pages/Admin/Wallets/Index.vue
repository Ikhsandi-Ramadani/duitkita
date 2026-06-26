<template>
    <Layout>
        <!-- Table Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Wallets</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ wallets.total }} total wallet</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="wallets.data"
                data-key="id"
                class="p-datatable-sm"
            >
                <template #empty>
                    <div class="py-8 text-center text-slate-400 text-sm">Belum ada wallet</div>
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
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nama Wallet</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-800 text-sm font-medium">{{ data.name }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Tipe</span>
                    </template>
                    <template #body="{ data }">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-600 capitalize">
                            {{ data.type }}
                        </span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Saldo</span>
                    </template>
                    <template #body="{ data }">
                        <span
                            :class="[
                                'font-semibold text-sm',
                                data.balance >= 0 ? 'text-green-600' : 'text-red-500',
                            ]"
                        >
                            {{ formatRupiah(data.balance) }}
                        </span>
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
                    Halaman {{ wallets.current_page }} dari {{ wallets.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!wallets.prev_page_url"
                        @click="router.visit(wallets.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!wallets.next_page_url"
                        @click="router.visit(wallets.next_page_url)"
                    >
                        Berikutnya
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <!-- Edit Dialog -->
        <Dialog
            v-model:visible="editVisible"
            header="Edit Wallet"
            :style="{ width: '420px' }"
            :modal="true"
        >
            <div class="space-y-4 pt-2">
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Nama Wallet</label>
                    <InputText v-model="editForm.name" class="w-full" :invalid="!!errors.name" />
                    <small v-if="errors.name" class="text-red-500 text-xs">{{ errors.name }}</small>
                </div>
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Tipe</label>
                    <Select
                        v-model="editForm.type"
                        :options="walletTypeOptions"
                        option-label="label"
                        option-value="value"
                        class="w-full"
                        :invalid="!!errors.type"
                    />
                    <small v-if="errors.type" class="text-red-500 text-xs">{{ errors.type }}</small>
                </div>
            </div>
            <template #footer>
                <Button label="Batal" severity="secondary" outlined @click="editVisible = false" />
                <Button label="Simpan" severity="success" :loading="saving" @click="submitEdit" />
            </template>
        </Dialog>

        <!-- Delete Confirmation -->
        <Dialog
            v-model:visible="deleteVisible"
            header="Hapus Wallet"
            :style="{ width: '380px' }"
            :modal="true"
        >
            <p class="text-slate-600">
                Yakin ingin menghapus wallet <strong class="text-slate-900">{{ deleteTarget?.name }}</strong>?
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
import Select from 'primevue/select'

const props = defineProps({
    wallets: Object,
    households: Array,
})

// Derive wallet type options from existing data
const walletTypeOptions = computed(() => {
    const types = new Set(props.wallets.data.map(w => w.type).filter(Boolean))
    const base = ['cash', 'bank', 'e-wallet', 'savings', 'investment']
    base.forEach(t => types.add(t))
    return [...types].map(t => ({ label: t.charAt(0).toUpperCase() + t.slice(1), value: t }))
})

// Edit
const editVisible = ref(false)
const saving = ref(false)
const errors = reactive({})
const editForm = reactive({ id: null, name: '', type: '' })

function openEdit(wallet) {
    Object.assign(editForm, { id: wallet.id, name: wallet.name, type: wallet.type })
    Object.keys(errors).forEach(k => delete errors[k])
    editVisible.value = true
}

function submitEdit() {
    saving.value = true
    router.put(`/admin/wallets/${editForm.id}`, {
        name: editForm.name,
        type: editForm.type,
    }, {
        preserveScroll: true,
        onSuccess: () => { editVisible.value = false },
        onError: errs => Object.assign(errors, errs),
        onFinish: () => { saving.value = false },
    })
}

// Delete
const deleteVisible = ref(false)
const deleting = ref(false)
const deleteTarget = ref(null)

function openDelete(wallet) {
    deleteTarget.value = wallet
    deleteVisible.value = true
}

function submitDelete() {
    deleting.value = true
    router.delete(`/admin/wallets/${deleteTarget.value.id}`, {
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
