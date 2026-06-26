<template>
    <Layout>
        <!-- Table Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100">
                <div>
                    <h2 class="text-slate-800 font-semibold text-base">Pengguna</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ users.total }} total pengguna terdaftar</p>
                </div>
            </div>

            <!-- Table -->
            <DataTable
                :value="users.data"
                :rows="users.per_page"
                :total-records="users.total"
                data-key="id"
                class="p-datatable-sm"
            >
                <Column field="name" header="Nama">
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nama</span>
                    </template>
                    <template #body="{ data }">
                        <div class="flex items-center gap-2.5">
                            <div class="w-7 h-7 rounded-full bg-green-100 flex items-center justify-center shrink-0">
                                <span class="text-green-700 text-xs font-semibold">{{ data.name?.charAt(0)?.toUpperCase() ?? '?' }}</span>
                            </div>
                            <span class="text-slate-800 text-sm font-medium">{{ data.name }}</span>
                        </div>
                    </template>
                </Column>
                <Column field="email" header="Email">
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Email</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.email }}</span>
                    </template>
                </Column>
                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Role</span>
                    </template>
                    <template #body="{ data }">
                        <span
                            :class="[
                                'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                                data.role === 'owner'
                                    ? 'bg-green-100 text-green-700'
                                    : 'bg-slate-100 text-slate-600',
                            ]"
                        >
                            {{ data.role === 'owner' ? 'Owner' : 'Member' }}
                        </span>
                    </template>
                </Column>
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
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Bergabung</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.created_at) }}</span>
                    </template>
                </Column>
                <Column header="Aksi" style="width: 100px;">
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
                    Halaman {{ users.current_page }} dari {{ users.last_page }}
                </span>
                <div class="flex gap-1.5">
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!users.prev_page_url"
                        @click="router.visit(users.prev_page_url)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                        </svg>
                        Sebelumnya
                    </button>
                    <button
                        class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        :disabled="!users.next_page_url"
                        @click="router.visit(users.next_page_url)"
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
            header="Edit Pengguna"
            :style="{ width: '420px' }"
            :modal="true"
        >
            <div class="space-y-4 pt-2">
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Nama</label>
                    <InputText v-model="editForm.name" class="w-full" :invalid="!!errors.name" />
                    <small v-if="errors.name" class="text-red-500 text-xs">{{ errors.name }}</small>
                </div>
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Email</label>
                    <InputText v-model="editForm.email" type="email" class="w-full" :invalid="!!errors.email" />
                    <small v-if="errors.email" class="text-red-500 text-xs">{{ errors.email }}</small>
                </div>
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-medium text-slate-700">Role</label>
                    <Select
                        v-model="editForm.role"
                        :options="roleOptions"
                        option-label="label"
                        option-value="value"
                        class="w-full"
                        :invalid="!!errors.role"
                    />
                    <small v-if="errors.role" class="text-red-500 text-xs">{{ errors.role }}</small>
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
            header="Hapus Pengguna"
            :style="{ width: '380px' }"
            :modal="true"
        >
            <p class="text-slate-600">
                Yakin ingin menghapus pengguna <strong class="text-slate-900">{{ deleteTarget?.name }}</strong>?
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
import { ref, reactive } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'

const props = defineProps({
    users: Object,
})

const roleOptions = [
    { label: 'Owner', value: 'owner' },
    { label: 'Member', value: 'member' },
]

// Edit
const editVisible = ref(false)
const saving = ref(false)
const errors = reactive({})
const editForm = reactive({ id: null, name: '', email: '', role: '' })

function openEdit(user) {
    Object.assign(editForm, { id: user.id, name: user.name, email: user.email, role: user.role })
    Object.keys(errors).forEach(k => delete errors[k])
    editVisible.value = true
}

function submitEdit() {
    saving.value = true
    router.put(`/admin/users/${editForm.id}`, {
        name: editForm.name,
        email: editForm.email,
        role: editForm.role,
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

function openDelete(user) {
    deleteTarget.value = user
    deleteVisible.value = true
}

function submitDelete() {
    deleting.value = true
    router.delete(`/admin/users/${deleteTarget.value.id}`, {
        preserveScroll: true,
        onSuccess: () => { deleteVisible.value = false },
        onFinish: () => { deleting.value = false },
    })
}

function formatDate(dateStr) {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('id-ID', {
        day: 'numeric', month: 'short', year: 'numeric',
    })
}
</script>
