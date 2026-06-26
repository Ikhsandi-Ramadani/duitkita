<template>
    <Layout>
        <!-- Stats Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-5 gap-4 mb-6">
            <div class="bg-white rounded-xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-xl bg-green-100 flex items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-500 text-xs mb-0.5 truncate">Total Pengguna</p>
                    <p class="text-slate-900 text-xl font-bold truncate">{{ stats.total_users }}</p>
                </div>
            </div>

            <div class="bg-white rounded-xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-xl bg-blue-100 flex items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-500 text-xs mb-0.5 truncate">Total Keluarga</p>
                    <p class="text-slate-900 text-xl font-bold truncate">{{ stats.total_households }}</p>
                </div>
            </div>

            <div class="bg-white rounded-xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-xl bg-purple-100 flex items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-500 text-xs mb-0.5 truncate">Total Transaksi</p>
                    <p class="text-slate-900 text-xl font-bold truncate">{{ stats.total_transactions }}</p>
                </div>
            </div>

            <div class="bg-white rounded-xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-xl bg-red-100 flex items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-500 text-xs mb-0.5 truncate">Total Pengeluaran</p>
                    <p class="text-slate-900 text-xl font-bold truncate">{{ formatRupiah(stats.total_amount) }}</p>
                </div>
            </div>

            <div class="bg-white rounded-xl p-5 border border-slate-100 shadow-sm flex items-center gap-4">
                <div class="w-11 h-11 rounded-xl bg-green-100 flex items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                    </svg>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-500 text-xs mb-0.5 truncate">Pengguna Baru Bulan Ini</p>
                    <p class="text-slate-900 text-xl font-bold truncate">{{ stats.new_users_month }}</p>
                </div>
            </div>
        </div>

        <!-- Chart -->
        <div class="bg-white rounded-xl p-6 border border-slate-100 shadow-sm">
            <div class="flex items-center justify-between mb-5">
                <div>
                    <h3 class="text-slate-800 font-semibold text-base">Pemasukan vs Pengeluaran</h3>
                    <p class="text-slate-400 text-xs mt-0.5">6 Bulan Terakhir</p>
                </div>
                <div class="flex items-center gap-4 text-xs text-slate-500">
                    <span class="flex items-center gap-1.5">
                        <span class="w-3 h-3 rounded-full bg-green-500 inline-block"></span>
                        Pemasukan
                    </span>
                    <span class="flex items-center gap-1.5">
                        <span class="w-3 h-3 rounded-full bg-red-400 inline-block"></span>
                        Pengeluaran
                    </span>
                </div>
            </div>
            <div class="relative" style="height: 300px;">
                <canvas ref="chartCanvas" />
            </div>
        </div>
    </Layout>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { Chart, BarController, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from 'chart.js'
import Layout from './Layout.vue'

Chart.register(BarController, BarElement, CategoryScale, LinearScale, Tooltip, Legend)

const props = defineProps({
    stats: Object,
    chartData: Array,
})

const chartCanvas = ref(null)

function formatRupiah(amount) {
    return 'Rp ' + Number(amount).toLocaleString('id-ID')
}

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
    const income = labels.map(m => incomeMap[m] ?? 0)
    const expense = labels.map(m => expenseMap[m] ?? 0)

    return { labels, income, expense }
})

onMounted(() => {
    const { labels, income, expense } = processedChart.value

    new Chart(chartCanvas.value, {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {
                    label: 'Pemasukan',
                    data: income,
                    backgroundColor: 'rgba(22, 163, 74, 0.8)',
                    borderColor: '#16a34a',
                    borderWidth: 1,
                    borderRadius: 6,
                },
                {
                    label: 'Pengeluaran',
                    data: expense,
                    backgroundColor: 'rgba(239, 68, 68, 0.75)',
                    borderColor: '#ef4444',
                    borderWidth: 1,
                    borderRadius: 6,
                },
            ],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false,
                },
                tooltip: {
                    backgroundColor: '#0f172a',
                    titleColor: '#94a3b8',
                    bodyColor: '#f1f5f9',
                    padding: 10,
                    callbacks: {
                        label: ctx => {
                            return ` ${ctx.dataset.label}: Rp ${Number(ctx.raw).toLocaleString('id-ID')}`
                        },
                    },
                },
            },
            scales: {
                x: {
                    ticks: { color: '#94a3b8', font: { size: 12 } },
                    grid: { color: '#f1f5f9' },
                    border: { color: '#e2e8f0' },
                },
                y: {
                    ticks: {
                        color: '#94a3b8',
                        font: { size: 11 },
                        callback: val => 'Rp ' + Number(val).toLocaleString('id-ID'),
                    },
                    grid: { color: '#f1f5f9' },
                    border: { color: '#e2e8f0' },
                },
            },
        },
    })
})
</script>
