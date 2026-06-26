<template>
    <Layout>
        <div class="bg-[#1e293b] rounded-2xl border border-slate-700 overflow-hidden">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-slate-700">
                <h2 class="text-white font-semibold text-lg">Keluarga</h2>
                <span class="text-slate-400 text-sm">{{ households.total }} total</span>
            </div>

            <!-- Table -->
            <DataTable
                :value="households.data"
                data-key="id"
                class="p-datatable-sm"
                striped-rows
            >
                <Column field="name" header="Nama Keluarga" />
                <Column header="Pemilik">
                    <template #body="{ data }">
                        <span class="text-slate-300">{{ data.owner?.name ?? '-' }}</span>
                    </template>
                </Column>
                <Column header="Kode Undang">
                    <template #body="{ data }">
                        <code class="font-mono text-xs bg-slate-700 text-amber-300 px-2 py-1 rounded">
                            {{ data.invite_code ?? '-' }}
                        </code>
                    </template>
                </Column>
                <Column header="Anggota">
                    <template #body="{ data }">
                        <span class="text-slate-300">{{ data.members_count }} orang</span>
                    </template>
                </Column>
                <Column header="Dibuat">
                    <template #body="{ data }">
                        <span class="text-slate-400 text-sm">{{ formatDate(data.created_at) }}</span>
                    </template>
                </Column>
            </DataTable>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-6 py-4 border-t border-slate-700">
                <span class="text-slate-400 text-sm">
                    Halaman {{ households.current_page }} dari {{ households.last_page }}
                </span>
                <div class="flex gap-2">
                    <Button
                        label="Sebelumnya"
                        icon="pi pi-chevron-left"
                        severity="secondary"
                        size="small"
                        :disabled="!households.prev_page_url"
                        @click="router.visit(households.prev_page_url)"
                    />
                    <Button
                        label="Berikutnya"
                        icon="pi pi-chevron-right"
                        icon-pos="right"
                        severity="secondary"
                        size="small"
                        :disabled="!households.next_page_url"
                        @click="router.visit(households.next_page_url)"
                    />
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
import Button from 'primevue/button'

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
