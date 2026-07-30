<template>
    <Layout>
        <div class="max-w-3xl">
            <div class="mb-6">
                <h1 class="text-slate-900 font-bold text-xl">Reset Data</h1>
                <p class="text-slate-500 text-sm mt-1">
                    Bersihkan data hasil testing dan kembalikan aplikasi ke kondisi siap digunakan.
                </p>
            </div>

            <div class="bg-amber-50 border border-amber-200 rounded-xl px-5 py-4 mb-5">
                <div class="flex gap-3">
                    <i class="pi pi-exclamation-triangle text-amber-600 mt-0.5" />
                    <div>
                        <p class="text-amber-900 font-semibold text-sm">Tindakan ini tidak dapat dibatalkan</p>
                        <p class="text-amber-800 text-sm mt-1">
                            Semua pengguna biasa, rumah tangga, transaksi, wallet, kategori, anggaran,
                            target tabungan, utang, transaksi berulang, dan notifikasi akan dihapus permanen.
                        </p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-xl border border-slate-100 shadow-sm mb-5">
                <div class="px-6 py-4 border-b border-slate-100">
                    <h2 class="text-slate-800 font-semibold text-base">Ringkasan Data Saat Ini</h2>
                </div>
                <div class="p-6 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
                    <div
                        v-for="item in countItems"
                        :key="item.key"
                        class="rounded-lg border border-slate-100 bg-slate-50 px-4 py-3"
                    >
                        <p class="text-2xl font-bold text-slate-800 tabular-nums">{{ formatNumber(item.value) }}</p>
                        <p class="text-xs text-slate-500 mt-1">{{ item.label }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-xl border border-red-200 shadow-sm">
                <div class="px-6 py-4 border-b border-red-100">
                    <h2 class="text-red-700 font-semibold text-base">Konfirmasi Reset</h2>
                </div>

                <form class="px-6 py-5 space-y-5" @submit.prevent="submit">
                    <div class="flex flex-col gap-1.5">
                        <label for="current-password" class="text-sm font-medium text-slate-700">
                            Password Admin <span class="text-red-500">*</span>
                        </label>
                        <InputText
                            id="current-password"
                            v-model="form.current_password"
                            type="password"
                            autocomplete="current-password"
                            placeholder="Masukkan password akun admin"
                            class="w-full"
                            :invalid="!!form.errors.current_password"
                        />
                        <small v-if="form.errors.current_password" class="text-red-500 text-xs">
                            {{ form.errors.current_password }}
                        </small>
                    </div>

                    <div class="flex flex-col gap-1.5">
                        <label for="confirmation" class="text-sm font-medium text-slate-700">
                            Ketik <span class="font-mono font-bold text-red-600">{{ confirmationPhrase }}</span>
                            untuk melanjutkan
                        </label>
                        <InputText
                            id="confirmation"
                            v-model="form.confirmation"
                            :placeholder="confirmationPhrase"
                            autocomplete="off"
                            class="w-full font-mono"
                            :invalid="!!form.errors.confirmation"
                        />
                        <small v-if="form.errors.confirmation" class="text-red-500 text-xs">
                            {{ form.errors.confirmation }}
                        </small>
                    </div>

                    <div class="rounded-lg bg-green-50 border border-green-100 px-4 py-3 flex gap-2">
                        <i class="pi pi-shield text-green-600 mt-0.5" />
                        <p class="text-green-800 text-sm">
                            Akun super admin dan pengaturan versi aplikasi tidak akan dihapus.
                        </p>
                    </div>

                    <Button
                        type="submit"
                        label="Reset Semua Data"
                        icon="pi pi-trash"
                        severity="danger"
                        :loading="form.processing"
                        :disabled="form.confirmation !== confirmationPhrase || !form.current_password"
                    />
                </form>
            </div>
        </div>
    </Layout>
</template>

<script setup>
import { computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'

const props = defineProps({
    counts: {
        type: Object,
        required: true,
    },
    confirmationPhrase: {
        type: String,
        required: true,
    },
})

const labels = {
    households: 'Households',
    users: 'Pengguna',
    wallets: 'Wallets',
    categories: 'Kategori',
    transactions: 'Transaksi',
    budgets: 'Budgets',
    savings_goals: 'Target Tabungan',
    debts: 'Utang',
    recurrings: 'Berulang',
    notifications: 'Notifikasi',
}

const countItems = computed(() =>
    Object.entries(props.counts).map(([key, value]) => ({
        key,
        label: labels[key] ?? key,
        value,
    }))
)

const form = useForm({
    current_password: '',
    confirmation: '',
})

function formatNumber(value) {
    return new Intl.NumberFormat('id-ID').format(value)
}

function submit() {
    form.delete('/admin/settings/data-reset', {
        preserveScroll: true,
        onSuccess: () => form.reset(),
    })
}
</script>
