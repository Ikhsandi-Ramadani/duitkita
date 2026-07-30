<template>
    <Layout>
        <section class="dashboard-hero relative mb-6 overflow-hidden rounded-[24px] bg-slate-950 px-5 py-6 text-white shadow-xl shadow-slate-900/10 sm:px-7 sm:py-7">
            <div class="hero-orb hero-orb-one" />
            <div class="hero-orb hero-orb-two" />
            <div class="relative z-10 flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
                <div class="max-w-2xl">
                    <div class="mb-3 flex items-center gap-2">
                        <span class="flex h-7 items-center gap-1.5 rounded-full border border-white/10 bg-white/10 px-3 text-[11px] font-semibold text-emerald-200 backdrop-blur">
                            <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-emerald-400" />
                            Sistem berjalan normal
                        </span>
                    </div>
                    <h2 class="text-2xl font-extrabold tracking-tight sm:text-3xl">
                        Selamat datang kembali
                    </h2>
                    <p class="mt-2 max-w-xl text-sm leading-6 text-slate-300">
                        Semua informasi penting DuitKita tersedia dalam satu tampilan. Pantau pertumbuhan pengguna dan aktivitas keuangan dengan cepat.
                    </p>
                </div>
                <div class="flex flex-wrap gap-2">
                    <Link href="/admin/users" class="hero-action hero-action-primary">
                        <i class="pi pi-users text-sm" />
                        Kelola pengguna
                    </Link>
                    <Link href="/admin/transactions" class="hero-action hero-action-secondary">
                        <i class="pi pi-arrow-right-arrow-left text-sm" />
                        Lihat transaksi
                    </Link>
                </div>
            </div>
        </section>

        <section class="mb-6">
            <div class="mb-3 flex items-end justify-between">
                <div>
                    <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-emerald-600">Overview</p>
                    <h2 class="mt-1 text-lg font-bold tracking-tight text-slate-900">Ringkasan platform</h2>
                </div>
                <p class="hidden text-xs text-slate-400 sm:block">Diperbarui secara real-time</p>
            </div>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5">
                <article
                    v-for="stat in statCards"
                    :key="stat.label"
                    class="stat-card group relative overflow-hidden rounded-2xl border border-slate-200/70 bg-white p-5 shadow-sm"
                >
                    <div :class="[stat.soft, 'absolute -right-6 -top-6 h-24 w-24 rounded-full opacity-60 blur-2xl transition group-hover:scale-125']" />
                    <div class="relative">
                        <div class="mb-5 flex items-center justify-between">
                            <span :class="[stat.soft, stat.color, 'flex h-10 w-10 items-center justify-center rounded-xl']">
                                <i :class="[stat.icon, 'text-base']" />
                            </span>
                            <i class="pi pi-arrow-up-right text-xs text-slate-300 transition group-hover:text-slate-500" />
                        </div>
                        <p class="truncate text-[11px] font-semibold uppercase tracking-wide text-slate-400">{{ stat.label }}</p>
                        <p class="mt-1.5 truncate text-xl font-extrabold tracking-tight text-slate-900 tabular-nums" :title="stat.value">
                            {{ stat.value }}
                        </p>
                        <p class="mt-2 truncate text-[11px] text-slate-400">{{ stat.hint }}</p>
                    </div>
                </article>
            </div>
        </section>

        <section class="grid grid-cols-1 gap-5 xl:grid-cols-[minmax(0,1fr)_320px]">
            <div class="overflow-hidden rounded-2xl border border-slate-200/70 bg-white shadow-sm">
                <div class="flex flex-col gap-3 border-b border-slate-100 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-6">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="h-2 w-2 rounded-full bg-emerald-500" />
                            <h3 class="font-bold text-slate-900">Arus kas platform</h3>
                        </div>
                        <p class="mt-1 pl-4 text-xs text-slate-400">Perbandingan pemasukan dan pengeluaran 6 bulan terakhir</p>
                    </div>
                    <div class="flex items-center gap-3 rounded-xl bg-slate-50 px-3 py-2 text-[11px] text-slate-500">
                        <span class="flex items-center gap-1.5">
                            <span class="h-2 w-2 rounded-full bg-emerald-500" />
                            Pemasukan
                        </span>
                        <span class="flex items-center gap-1.5">
                            <span class="h-2 w-2 rounded-full bg-rose-400" />
                            Pengeluaran
                        </span>
                    </div>
                </div>

                <div class="relative px-3 py-5 sm:px-6">
                    <div v-if="hasChartData" class="relative h-[320px]">
                        <canvas ref="chartCanvas" />
                    </div>
                    <div v-else class="flex h-[320px] flex-col items-center justify-center text-center">
                        <div class="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                            <i class="pi pi-chart-bar text-xl" />
                        </div>
                        <p class="font-semibold text-slate-700">Belum ada data transaksi</p>
                        <p class="mt-1 max-w-xs text-xs leading-5 text-slate-400">
                            Grafik akan tampil setelah pengguna mulai mencatat pemasukan atau pengeluaran.
                        </p>
                    </div>
                </div>
            </div>

            <aside class="space-y-5">
                <div class="rounded-2xl border border-slate-200/70 bg-white p-5 shadow-sm">
                    <div class="mb-4 flex items-center justify-between">
                        <div>
                            <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-400">Akses cepat</p>
                            <h3 class="mt-1 font-bold text-slate-900">Kelola data</h3>
                        </div>
                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                            <i class="pi pi-bolt text-sm" />
                        </span>
                    </div>
                    <div class="space-y-2">
                        <Link
                            v-for="action in quickActions"
                            :key="action.href"
                            :href="action.href"
                            class="group flex items-center gap-3 rounded-xl border border-transparent px-3 py-2.5 transition hover:border-slate-100 hover:bg-slate-50"
                        >
                            <span :class="[action.soft, action.color, 'flex h-9 w-9 items-center justify-center rounded-xl']">
                                <i :class="[action.icon, 'text-sm']" />
                            </span>
                            <span class="min-w-0 flex-1">
                                <span class="block truncate text-sm font-semibold text-slate-700">{{ action.label }}</span>
                                <span class="block truncate text-[11px] text-slate-400">{{ action.hint }}</span>
                            </span>
                            <i class="pi pi-chevron-right text-[10px] text-slate-300 transition group-hover:translate-x-0.5 group-hover:text-slate-500" />
                        </Link>
                    </div>
                </div>

                <div class="relative overflow-hidden rounded-2xl bg-emerald-600 p-5 text-white shadow-lg shadow-emerald-600/15">
                    <div class="absolute -right-8 -top-8 h-28 w-28 rounded-full border-[18px] border-white/10" />
                    <div class="relative">
                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-white/15">
                            <i class="pi pi-shield text-sm" />
                        </span>
                        <h3 class="mt-4 font-bold">Data testing selesai?</h3>
                        <p class="mt-1.5 text-xs leading-5 text-emerald-100">
                            Bersihkan data uji tanpa menghapus akun admin dan konfigurasi aplikasi.
                        </p>
                        <Link href="/admin/settings/data-reset" class="mt-4 inline-flex items-center gap-2 text-xs font-bold text-white hover:underline">
                            Buka Reset Data
                            <i class="pi pi-arrow-right text-[10px]" />
                        </Link>
                    </div>
                </div>
            </aside>
        </section>
    </Layout>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { Link } from '@inertiajs/vue3'
import { BarController, BarElement, CategoryScale, Chart, LinearScale, Tooltip } from 'chart.js'
import Layout from './Layout.vue'

Chart.register(BarController, BarElement, CategoryScale, LinearScale, Tooltip)

const props = defineProps({
    stats: Object,
    chartData: Array,
})

const chartCanvas = ref(null)
let chartInstance = null

function formatRupiah(amount) {
    const value = Number(amount ?? 0)
    if (value >= 1_000_000_000) return `Rp ${(value / 1_000_000_000).toLocaleString('id-ID', { maximumFractionDigits: 1 })} M`
    if (value >= 1_000_000) return `Rp ${(value / 1_000_000).toLocaleString('id-ID', { maximumFractionDigits: 1 })} jt`
    return `Rp ${value.toLocaleString('id-ID')}`
}

const statCards = computed(() => [
    {
        label: 'Total pengguna',
        value: Number(props.stats?.total_users ?? 0).toLocaleString('id-ID'),
        hint: `${Number(props.stats?.new_users_month ?? 0).toLocaleString('id-ID')} baru bulan ini`,
        icon: 'pi pi-users',
        color: 'text-emerald-600',
        soft: 'bg-emerald-50',
    },
    {
        label: 'Keluarga aktif',
        value: Number(props.stats?.total_households ?? 0).toLocaleString('id-ID'),
        hint: 'Household terdaftar',
        icon: 'pi pi-home',
        color: 'text-sky-600',
        soft: 'bg-sky-50',
    },
    {
        label: 'Total transaksi',
        value: Number(props.stats?.total_transactions ?? 0).toLocaleString('id-ID'),
        hint: 'Semua aktivitas tercatat',
        icon: 'pi pi-arrow-right-arrow-left',
        color: 'text-violet-600',
        soft: 'bg-violet-50',
    },
    {
        label: 'Total pengeluaran',
        value: formatRupiah(props.stats?.total_amount),
        hint: 'Akumulasi seluruh pengguna',
        icon: 'pi pi-arrow-up-right',
        color: 'text-rose-600',
        soft: 'bg-rose-50',
    },
    {
        label: 'Pengguna baru',
        value: Number(props.stats?.new_users_month ?? 0).toLocaleString('id-ID'),
        hint: 'Bergabung bulan ini',
        icon: 'pi pi-user-plus',
        color: 'text-amber-600',
        soft: 'bg-amber-50',
    },
])

const quickActions = [
    { href: '/admin/users', label: 'Pengguna', hint: 'Akun dan akses', icon: 'pi pi-users', color: 'text-emerald-600', soft: 'bg-emerald-50' },
    { href: '/admin/transactions', label: 'Transaksi', hint: 'Aktivitas keuangan', icon: 'pi pi-arrow-right-arrow-left', color: 'text-violet-600', soft: 'bg-violet-50' },
    { href: '/admin/categories', label: 'Kategori', hint: 'Klasifikasi transaksi', icon: 'pi pi-tags', color: 'text-sky-600', soft: 'bg-sky-50' },
    { href: '/admin/settings/app-version', label: 'Versi aplikasi', hint: 'Update dan rilis', icon: 'pi pi-mobile', color: 'text-amber-600', soft: 'bg-amber-50' },
]

const processedChart = computed(() => {
    const monthSet = new Set()
    const incomeMap = {}
    const expenseMap = {}

    for (const row of props.chartData ?? []) {
        monthSet.add(row.month)
        if (row.type === 'income') incomeMap[row.month] = Number(row.total)
        if (row.type === 'expense') expenseMap[row.month] = Number(row.total)
    }

    const labels = Array.from(monthSet).sort()
    return {
        labels,
        income: labels.map(month => incomeMap[month] ?? 0),
        expense: labels.map(month => expenseMap[month] ?? 0),
    }
})

const hasChartData = computed(() => processedChart.value.labels.length > 0)

onMounted(() => {
    if (!hasChartData.value || !chartCanvas.value) return

    const { labels, income, expense } = processedChart.value
    chartInstance = new Chart(chartCanvas.value, {
        type: 'bar',
        data: {
            labels: labels.map(month => new Intl.DateTimeFormat('id-ID', { month: 'short', year: '2-digit' }).format(new Date(`${month}-01`))),
            datasets: [
                {
                    label: 'Pemasukan',
                    data: income,
                    backgroundColor: '#10b981',
                    hoverBackgroundColor: '#059669',
                    borderRadius: 7,
                    borderSkipped: false,
                    barPercentage: 0.72,
                    categoryPercentage: 0.68,
                },
                {
                    label: 'Pengeluaran',
                    data: expense,
                    backgroundColor: '#fb7185',
                    hoverBackgroundColor: '#f43f5e',
                    borderRadius: 7,
                    borderSkipped: false,
                    barPercentage: 0.72,
                    categoryPercentage: 0.68,
                },
            ],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                tooltip: {
                    backgroundColor: '#0f172a',
                    titleColor: '#cbd5e1',
                    bodyColor: '#f8fafc',
                    padding: 12,
                    cornerRadius: 10,
                    displayColors: true,
                    boxPadding: 4,
                    callbacks: {
                        label: context => ` ${context.dataset.label}: Rp ${Number(context.raw).toLocaleString('id-ID')}`,
                    },
                },
            },
            scales: {
                x: {
                    ticks: { color: '#94a3b8', font: { size: 11, weight: 500 } },
                    grid: { display: false },
                    border: { display: false },
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#94a3b8',
                        font: { size: 10 },
                        padding: 10,
                        callback: value => formatRupiah(value),
                    },
                    grid: { color: '#f1f5f9', drawTicks: false },
                    border: { display: false },
                },
            },
        },
    })
})

onBeforeUnmount(() => chartInstance?.destroy())
</script>
