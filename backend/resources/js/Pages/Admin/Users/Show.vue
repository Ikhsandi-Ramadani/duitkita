<template>
    <Layout>
        <!-- Header Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm px-6 py-5 mb-4">
            <div class="flex items-start justify-between gap-4">
                <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center shrink-0">
                        <span class="text-green-700 font-bold text-lg">{{ user.name?.charAt(0)?.toUpperCase() ?? '?' }}</span>
                    </div>
                    <div>
                        <h1 class="text-slate-900 font-bold text-lg leading-tight">{{ user.name }}</h1>
                        <p class="text-slate-500 text-sm mt-0.5">{{ user.email }}</p>
                        <p v-if="user.phone" class="text-slate-400 text-xs mt-0.5">{{ user.phone }}</p>
                    </div>
                </div>
                <button
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors shrink-0"
                    @click="router.visit('/admin/users')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                    </svg>
                    Kembali
                </button>
            </div>

            <div class="flex flex-wrap items-center gap-2 mt-4">
                <span
                    :class="[
                        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                        user.role === 'owner' ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-600',
                    ]"
                >
                    {{ user.role === 'owner' ? 'Owner' : 'Member' }}
                </span>
                <span
                    v-if="user.is_super_admin"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-700"
                >
                    Super Admin
                </span>
                <span class="text-slate-400 text-xs ml-auto">
                    Bergabung {{ formatDate(user.created_at) }}
                </span>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
            <!-- Household Card -->
            <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-100">
                    <h2 class="text-slate-800 font-semibold text-base">Keluarga</h2>
                </div>
                <div class="px-6 py-4">
                    <template v-if="user.household">
                        <div class="flex items-center gap-3">
                            <div class="w-9 h-9 rounded-xl bg-green-50 flex items-center justify-center shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                </svg>
                            </div>
                            <div>
                                <p class="text-slate-800 font-semibold text-sm">{{ user.household.name }}</p>
                                <p class="text-slate-400 text-xs mt-0.5">Owner: {{ user.household.owner?.name ?? '-' }}</p>
                            </div>
                        </div>
                    </template>
                    <template v-else>
                        <p class="text-slate-400 text-sm">Tidak bergabung ke household</p>
                    </template>
                </div>
            </div>

            <!-- Wallets Card -->
            <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-100">
                    <h2 class="text-slate-800 font-semibold text-base">Dompet</h2>
                    <p class="text-slate-400 text-xs mt-0.5">{{ user.wallets?.length ?? 0 }} dompet</p>
                </div>
                <div class="divide-y divide-slate-50">
                    <template v-if="user.wallets?.length">
                        <div
                            v-for="wallet in user.wallets"
                            :key="wallet.id"
                            class="px-6 py-3 flex items-center justify-between"
                        >
                            <div>
                                <p class="text-slate-800 text-sm font-medium">{{ wallet.name }}</p>
                                <p class="text-slate-400 text-xs capitalize">{{ wallet.type }}</p>
                            </div>
                            <span
                                :class="[
                                    'text-sm font-semibold',
                                    wallet.balance >= 0 ? 'text-green-600' : 'text-red-500',
                                ]"
                            >
                                {{ formatRupiah(wallet.balance) }}
                            </span>
                        </div>
                    </template>
                    <template v-else>
                        <p class="px-6 py-4 text-slate-400 text-sm">Belum ada dompet</p>
                    </template>
                </div>
            </div>
        </div>

        <!-- Transaksi Terakhir Card -->
        <div class="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-slate-100">
                <h2 class="text-slate-800 font-semibold text-base">Transaksi Terakhir</h2>
                <p class="text-slate-400 text-xs mt-0.5">{{ user.recordedTransactions?.length ?? 0 }} transaksi ditampilkan</p>
            </div>
            <DataTable
                :value="user.recordedTransactions ?? []"
                data-key="id"
                class="p-datatable-sm"
            >
                <template #empty>
                    <div class="py-8 text-center text-slate-400 text-sm">Belum ada transaksi</div>
                </template>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Tanggal</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-500 text-sm">{{ formatDate(data.created_at) }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Kategori</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-700 text-sm">{{ data.category?.name ?? '-' }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Wallet</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-600 text-sm">{{ data.wallet?.name ?? '-' }}</span>
                    </template>
                </Column>

                <Column>
                    <template #header>
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Nominal</span>
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
                        <span class="text-slate-500 text-xs font-semibold uppercase tracking-wide">Catatan</span>
                    </template>
                    <template #body="{ data }">
                        <span class="text-slate-500 text-sm">{{ data.note ?? '-' }}</span>
                    </template>
                </Column>
            </DataTable>
        </div>
    </Layout>
</template>

<script setup>
import { router } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'

const props = defineProps({
    user: Object,
})

function formatDate(dateStr) {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('id-ID', {
        day: 'numeric', month: 'short', year: 'numeric',
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
