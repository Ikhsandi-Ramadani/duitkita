<template>
    <Layout>
        <div class="bg-[#1e293b] rounded-2xl border border-slate-700 overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-700">
                <h2 class="text-white font-semibold text-lg">Pengguna</h2>
                <span class="text-slate-400 text-sm">{{ users.total }} total</span>
            </div>

            <!-- Table -->
            <DataTable
                :value="users.data"
                :rows="users.per_page"
                :total-records="users.total"
                data-key="id"
                class="p-datatable-sm"
                striped-rows
            >
                <Column field="name" header="Nama" />
                <Column field="email" header="Email" />
                <Column header="Role">
                    <template #body="{ data }">
                        <Tag
                            :value="data.role === 'owner' ? 'Owner' : 'Member'"
                            :severity="data.role === 'owner' ? 'warning' : 'secondary'"
                        />
                    </template>
                </Column>
                <Column header="Keluarga">
                    <template #body="{ data }">
                        <span class="text-slate-300 text-sm">{{ data.household?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Bergabung">
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.created_at) }}</span>
                    </template>
                </Column>
                <Column header="Aksi" style="width: 120px;">
                    <template #body="{ data }">
                        <div class="flex items-center gap-2">
                            <Button
                                icon="pi pi-pencil"
                                severity="secondary"
                                size="small"
                                rounded
                                @click="openEdit(data)"
                            />
                            <Button
                                icon="pi pi-trash"
                                severity="danger"
                                size="small"
                                rounded
                                @click="openDelete(data)"
                            />
                        </div>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-4 border-t border-slate-700">
                <span class="text-slate-400 text-sm">
                    Halaman {{ users.current_page }} dari {{ users.last_page }}
                </span>
                <div class="flex gap-2">
                    <Button
                        label="Sebelumnya"
                        icon="pi pi-chevron-left"
                        severity="secondary"
                        size="small"
                        :disabled="!users.prev_page_url"
                        @click="router.visit(users.prev_page_url)"
                    />
                    <Button
                        label="Berikutnya"
                        icon="pi pi-chevron-right"
                        icon-pos="right"
                        severity="secondary"
                        size="small"
                        :disabled="!users.next_page_url"
                        @click="router.visit(users.next_page_url)"
                    />
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
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-slate-300">Nama</label>
                    <InputText v-model="editForm.name" class="w-full" :invalid="!!errors.name" />
                    <small v-if="errors.name" class="text-red-400 text-xs">{{ errors.name }}</small>
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-slate-300">Email</label>
                    <InputText v-model="editForm.email" type="email" class="w-full" :invalid="!!errors.email" />
                    <small v-if="errors.email" class="text-red-400 text-xs">{{ errors.email }}</small>
                </div>
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-slate-300">Role</label>
                    <Select
                        v-model="editForm.role"
                        :options="roleOptions"
                        option-label="label"
                        option-value="value"
                        class="w-full"
                        :invalid="!!errors.role"
                    />
                    <small v-if="errors.role" class="text-red-400 text-xs">{{ errors.role }}</small>
                </div>
            </div>
            <template #footer>
                <Button label="Batal" severity="secondary" outlined @click="editVisible = false" />
                <Button label="Simpan" :loading="saving" @click="submitEdit" />
            </template>
        </Dialog>

        <!-- Delete Confirmation -->
        <Dialog
            v-model:visible="deleteVisible"
            header="Hapus Pengguna"
            :style="{ width: '380px' }"
            :modal="true"
        >
            <p class="text-slate-300">
                Yakin ingin menghapus pengguna <strong class="text-white">{{ deleteTarget?.name }}</strong>?
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
import Tag from 'primevue/tag'
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
