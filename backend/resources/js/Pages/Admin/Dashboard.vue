<template>
    <Layout>
        <!-- Stats Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-5 gap-4 mb-6">
            <StatCard
                label="Total Pengguna"
                :value="stats.total_users"
                icon="pi-users"
                color="text-blue-400"
                bg="bg-blue-500/10"
            />
            <StatCard
                label="Total Keluarga"
                :value="stats.total_households"
                icon="pi-building"
                color="text-purple-400"
                bg="bg-purple-500/10"
            />
            <StatCard
                label="Total Transaksi"
                :value="stats.total_transactions"
                icon="pi-receipt"
                color="text-green-400"
                bg="bg-green-500/10"
            />
            <StatCard
                label="Total Pengeluaran"
                :value="formatRupiah(stats.total_amount)"
                icon="pi-wallet"
                color="text-red-400"
                bg="bg-red-500/10"
                :raw="false"
            />
            <StatCard
                label="Pengguna Baru Bulan Ini"
                :value="stats.new_users_month"
                icon="pi-user-plus"
                color="text-amber-400"
                bg="bg-amber-500/10"
            />
        </div>

        <!-- Chart -->
        <div class="bg-[#1e293b] rounded-2xl p-6 border border-slate-700">
            <h3 class="text-white font-semibold mb-4">Pemasukan vs Pengeluaran (6 Bulan Terakhir)</h3>
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

// Stat card sub-component
const StatCard = {
    props: ['label', 'value', 'icon', 'color', 'bg', 'raw'],
    template: `
        <div class="bg-[#1e293b] rounded-2xl p-5 border border-slate-700 flex items-center gap-4">
            <div :class="['w-12 h-12 rounded-xl flex items-center justify-center shrink-0', bg]">
                <i :class="['pi', icon, 'text-xl', color]" />
            </div>
            <div class="min-w-0">
                <p class="text-slate-400 text-xs mb-1 truncate">{{ label }}</p>
                <p class="text-white text-xl font-bold truncate">{{ value }}</p>
            </div>
        </div>
    `,
}

function formatRupiah(amount) {
    return 'Rp ' + Number(amount).toLocaleString('id-ID')
}

// Process chartData into labels + datasets
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
                    backgroundColor: 'rgba(34, 197, 94, 0.7)',
                    borderColor: 'rgb(34, 197, 94)',
                    borderWidth: 1,
                    borderRadius: 4,
                },
                {
                    label: 'Pengeluaran',
                    data: expense,
                    backgroundColor: 'rgba(239, 68, 68, 0.7)',
                    borderColor: 'rgb(239, 68, 68)',
                    borderWidth: 1,
                    borderRadius: 4,
                },
            ],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: { color: '#94a3b8' },
                },
                tooltip: {
                    callbacks: {
                        label: ctx => {
                            return ` ${ctx.dataset.label}: Rp ${Number(ctx.raw).toLocaleString('id-ID')}`
                        },
                    },
                },
            },
            scales: {
                x: {
                    ticks: { color: '#94a3b8' },
                    grid: { color: 'rgba(148,163,184,0.1)' },
                },
                y: {
                    ticks: {
                        color: '#94a3b8',
                        callback: val => 'Rp ' + Number(val).toLocaleString('id-ID'),
                    },
                    grid: { color: 'rgba(148,163,184,0.1)' },
                },
            },
        },
    })
})
</script>
