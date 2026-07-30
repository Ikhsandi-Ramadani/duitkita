<template>
    <div class="admin-shell flex min-h-screen overflow-hidden">
        <Transition name="fade">
            <button
                v-if="sidebarOpen"
                type="button"
                class="fixed inset-0 z-30 bg-slate-950/45 backdrop-blur-[2px] lg:hidden"
                aria-label="Tutup navigasi"
                @click="sidebarOpen = false"
            />
        </Transition>

        <aside
            :class="[
                'admin-sidebar fixed inset-y-0 left-0 z-40 flex w-72 flex-col border-r border-slate-200/80 bg-white/95 shadow-2xl shadow-slate-900/5 backdrop-blur-xl transition-all duration-300 lg:static lg:translate-x-0 lg:shadow-none',
                sidebarOpen ? 'translate-x-0' : '-translate-x-full',
                sidebarCollapsed ? 'lg:w-20' : 'lg:w-72',
            ]"
        >
            <div
                :class="[
                    'flex h-[76px] shrink-0 items-center border-b border-slate-100',
                    sidebarCollapsed ? 'justify-center px-3' : 'justify-between px-5',
                ]"
            >
                <Link href="/admin" class="flex min-w-0 items-center gap-3" @click="sidebarOpen = false">
                    <div class="brand-mark relative flex h-11 w-11 shrink-0 items-center justify-center overflow-hidden rounded-2xl text-white shadow-lg shadow-emerald-600/20">
                        <span class="relative z-10 text-lg font-extrabold tracking-tight">D</span>
                    </div>
                    <div v-if="!sidebarCollapsed" class="min-w-0">
                        <p class="truncate text-[17px] font-extrabold tracking-tight text-slate-900">DuitKita</p>
                        <p class="mt-0.5 text-[11px] font-medium tracking-wide text-slate-400">CONTROL CENTER</p>
                    </div>
                </Link>

                <button
                    v-if="!sidebarCollapsed"
                    type="button"
                    class="flex h-9 w-9 items-center justify-center rounded-xl text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 lg:hidden"
                    aria-label="Tutup navigasi"
                    @click="sidebarOpen = false"
                >
                    <i class="pi pi-times text-sm" />
                </button>
            </div>

            <nav class="admin-nav flex-1 overflow-y-auto px-3 py-5">
                <div v-for="(group, groupIndex) in navGroups" :key="group.label" :class="groupIndex ? 'mt-6' : ''">
                    <p
                        v-if="!sidebarCollapsed"
                        class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.16em] text-slate-400"
                    >
                        {{ group.label }}
                    </p>
                    <div class="space-y-1">
                        <Link
                            v-for="item in group.items"
                            :key="item.href"
                            :href="item.href"
                            :title="sidebarCollapsed ? item.label : undefined"
                            :class="[
                                'group relative flex min-h-11 items-center rounded-xl text-sm font-medium transition-all duration-200',
                                sidebarCollapsed ? 'justify-center px-2' : 'gap-3 px-3',
                                isActive(item.href)
                                    ? 'bg-emerald-50 text-emerald-700 shadow-sm shadow-emerald-900/5'
                                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900',
                            ]"
                            @click="sidebarOpen = false"
                        >
                            <span
                                v-if="isActive(item.href)"
                                class="absolute inset-y-2 left-0 w-1 rounded-r-full bg-emerald-500"
                            />
                            <span
                                :class="[
                                    'flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-colors',
                                    isActive(item.href)
                                        ? 'bg-white text-emerald-600 shadow-sm'
                                        : 'text-slate-400 group-hover:bg-white group-hover:text-slate-600 group-hover:shadow-sm',
                                ]"
                            >
                                <i :class="[item.icon, 'text-[15px]']" />
                            </span>
                            <span v-if="!sidebarCollapsed" class="truncate">{{ item.label }}</span>
                            <i
                                v-if="!sidebarCollapsed && isActive(item.href)"
                                class="pi pi-chevron-right ml-auto text-[10px] text-emerald-400"
                            />
                        </Link>
                    </div>
                </div>
            </nav>

            <div class="shrink-0 border-t border-slate-100 p-3">
                <div
                    :class="[
                        'rounded-2xl border border-slate-100 bg-slate-50/80',
                        sidebarCollapsed ? 'p-2' : 'p-3',
                    ]"
                >
                    <div :class="['flex items-center', sidebarCollapsed ? 'justify-center' : 'gap-3']">
                        <div class="avatar-ring flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-100">
                            <span class="text-sm font-bold text-emerald-700">
                                {{ userInitial }}
                            </span>
                        </div>
                        <div v-if="!sidebarCollapsed" class="min-w-0 flex-1">
                            <p class="truncate text-sm font-semibold text-slate-800">{{ auth?.user?.name }}</p>
                            <p class="truncate text-[11px] text-slate-400">{{ auth?.user?.email }}</p>
                        </div>
                        <button
                            v-if="!sidebarCollapsed"
                            type="button"
                            class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-slate-400 transition hover:bg-red-50 hover:text-red-500"
                            title="Keluar"
                            aria-label="Keluar"
                            @click="logout"
                        >
                            <i class="pi pi-sign-out text-sm" />
                        </button>
                    </div>
                </div>
            </div>
        </aside>

        <div class="flex min-w-0 flex-1 flex-col">
            <header class="admin-topbar sticky top-0 z-20 flex h-[76px] shrink-0 items-center border-b border-slate-200/70 bg-white/80 px-4 backdrop-blur-xl sm:px-6 lg:px-8">
                <button
                    type="button"
                    class="mr-3 flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 shadow-sm transition hover:border-emerald-200 hover:text-emerald-600 lg:hidden"
                    aria-label="Buka navigasi"
                    @click="sidebarOpen = true"
                >
                    <i class="pi pi-bars" />
                </button>

                <button
                    type="button"
                    class="mr-4 hidden h-9 w-9 items-center justify-center rounded-xl text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 lg:flex"
                    :title="sidebarCollapsed ? 'Perbesar sidebar' : 'Perkecil sidebar'"
                    @click="toggleSidebar"
                >
                    <i :class="sidebarCollapsed ? 'pi pi-angle-double-right' : 'pi pi-angle-double-left'" class="text-sm" />
                </button>

                <div class="min-w-0">
                    <div class="flex items-center gap-2">
                        <h1 class="truncate text-base font-bold tracking-tight text-slate-900 sm:text-lg">
                            {{ currentPage.label }}
                        </h1>
                        <span class="hidden h-1 w-1 rounded-full bg-slate-300 sm:block" />
                        <span class="hidden text-xs text-slate-400 sm:block">{{ currentPage.section }}</span>
                    </div>
                    <p class="mt-0.5 hidden truncate text-xs text-slate-400 md:block">
                        {{ currentPage.description }}
                    </p>
                </div>

                <div class="ml-auto flex items-center gap-3">
                    <div class="hidden items-center gap-2 rounded-xl border border-slate-200/80 bg-white px-3 py-2 text-xs text-slate-500 shadow-sm xl:flex">
                        <i class="pi pi-calendar text-emerald-500" />
                        <span>{{ currentDate }}</span>
                    </div>
                    <div class="hidden h-8 w-px bg-slate-200 sm:block" />
                    <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-slate-900 text-white shadow-md shadow-slate-900/10">
                        <span class="text-sm font-bold">{{ userInitial }}</span>
                    </div>
                </div>
            </header>

            <main class="admin-content flex-1 overflow-y-auto px-4 py-5 sm:px-6 sm:py-7 lg:px-8">
                <div class="mx-auto w-full max-w-[1600px]">
                    <slot />
                </div>
            </main>
        </div>

        <Toast position="top-right" />
    </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Link, router, usePage } from '@inertiajs/vue3'
import Toast from 'primevue/toast'
import { useToast } from 'primevue/usetoast'

const page = usePage()
const auth = computed(() => page.props.auth)
const toast = useToast()
const sidebarOpen = ref(false)
const sidebarCollapsed = ref(window.localStorage.getItem('admin-sidebar-collapsed') === 'true')

const navGroups = [
    {
        label: 'Ringkasan',
        items: [
            {
                href: '/admin',
                label: 'Dashboard',
                section: 'Ringkasan',
                description: 'Pantau aktivitas dan performa DuitKita.',
                icon: 'pi pi-chart-pie',
            },
        ],
    },
    {
        label: 'Manajemen',
        items: [
            {
                href: '/admin/users',
                label: 'Pengguna',
                section: 'Manajemen',
                description: 'Kelola akun dan akses pengguna.',
                icon: 'pi pi-users',
            },
            {
                href: '/admin/households',
                label: 'Keluarga',
                section: 'Manajemen',
                description: 'Lihat dan kelola grup keluarga.',
                icon: 'pi pi-home',
            },
            {
                href: '/admin/transactions',
                label: 'Transaksi',
                section: 'Keuangan',
                description: 'Pantau seluruh aktivitas transaksi.',
                icon: 'pi pi-arrow-right-arrow-left',
            },
            {
                href: '/admin/wallets',
                label: 'Dompet',
                section: 'Keuangan',
                description: 'Kelola sumber dana pengguna.',
                icon: 'pi pi-wallet',
            },
            {
                href: '/admin/categories',
                label: 'Kategori',
                section: 'Keuangan',
                description: 'Atur klasifikasi pemasukan dan pengeluaran.',
                icon: 'pi pi-tags',
            },
            {
                href: '/admin/budgets',
                label: 'Anggaran',
                section: 'Keuangan',
                description: 'Pantau rencana anggaran keluarga.',
                icon: 'pi pi-chart-bar',
            },
        ],
    },
    {
        label: 'Sistem',
        items: [
            {
                href: '/admin/settings/app-version',
                label: 'Versi Aplikasi',
                section: 'Pengaturan',
                description: 'Kelola versi dan pembaruan aplikasi.',
                icon: 'pi pi-mobile',
            },
            {
                href: '/admin/settings/data-reset',
                label: 'Reset Data',
                section: 'Pengaturan',
                description: 'Bersihkan data testing dengan aman.',
                icon: 'pi pi-refresh',
            },
        ],
    },
]

const navItems = navGroups.flatMap(group => group.items)

function isActive(href) {
    const url = page.url.split('?')[0]
    if (href === '/admin') return url === '/admin' || url === '/admin/'
    return url.startsWith(href)
}

const currentPage = computed(() =>
    navItems.find(item => isActive(item.href)) ?? {
        label: 'Admin',
        section: 'DuitKita',
        description: 'Kelola aplikasi DuitKita.',
    }
)

const currentDate = new Intl.DateTimeFormat('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
}).format(new Date())

const userInitial = computed(() => (auth.value?.user?.name ?? 'A').charAt(0).toUpperCase())

watch(
    () => page.props.flash,
    flash => {
        if (flash?.success) {
            toast.add({ severity: 'success', summary: 'Berhasil', detail: flash.success, life: 3200 })
        }
        if (flash?.error) {
            toast.add({ severity: 'error', summary: 'Gagal', detail: flash.error, life: 4200 })
        }
    },
    { immediate: false }
)

watch(
    () => page.url,
    () => {
        sidebarOpen.value = false
    }
)

function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value
    window.localStorage.setItem('admin-sidebar-collapsed', String(sidebarCollapsed.value))
}

function logout() {
    router.post('/admin/logout')
}
</script>
