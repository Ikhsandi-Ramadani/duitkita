<template>
    <div class="flex h-screen bg-slate-50 overflow-hidden">
        <!-- Sidebar Overlay (mobile) -->
        <div
            v-if="sidebarOpen"
            class="fixed inset-0 bg-black/40 z-20 lg:hidden"
            @click="sidebarOpen = false"
        />

        <!-- Sidebar -->
        <aside
            :class="[
                'fixed lg:static inset-y-0 left-0 z-30 flex flex-col bg-white border-r border-slate-200 transition-transform duration-300',
                sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0',
                'w-64',
            ]"
        >
            <!-- Brand -->
            <div class="flex items-center gap-3 px-6 py-5 border-b border-slate-100">
                <div class="w-9 h-9 rounded-xl bg-green-600 flex items-center justify-center shrink-0 shadow-sm">
                    <span class="text-white font-bold text-base">D</span>
                </div>
                <div class="min-w-0">
                    <p class="text-slate-900 font-bold text-base leading-tight">DuitKita</p>
                    <p class="text-slate-400 text-xs">Admin Panel</p>
                </div>
            </div>

            <!-- Nav -->
            <nav class="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto">
                <Link
                    v-for="item in navItems"
                    :key="item.href"
                    :href="item.href"
                    :class="[
                        'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors group',
                        isActive(item.href)
                            ? 'bg-green-50 text-green-700 font-semibold border-l-2 border-green-600 rounded-l-none'
                            : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900',
                    ]"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5 shrink-0"
                        :class="isActive(item.href) ? 'text-green-600' : 'text-slate-400 group-hover:text-slate-600'"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        stroke-width="2"
                        v-html="item.iconPath"
                    />
                    <span>{{ item.label }}</span>
                </Link>
            </nav>

            <!-- User info + logout -->
            <div class="px-4 py-4 border-t border-slate-100 space-y-3">
                <div class="flex items-center gap-2 px-1">
                    <div class="w-7 h-7 rounded-full bg-green-100 flex items-center justify-center shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-green-700" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                    </div>
                    <p class="text-slate-500 text-xs truncate">{{ auth?.user?.email }}</p>
                </div>
                <button
                    class="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-slate-600 hover:bg-red-50 hover:text-red-600 transition-colors"
                    @click="logout"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                    </svg>
                    <span>Keluar</span>
                </button>
            </div>
        </aside>

        <!-- Main -->
        <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
            <!-- Top Bar -->
            <header class="flex items-center justify-between px-4 lg:px-6 py-4 bg-white border-b border-slate-200 shrink-0">
                <!-- Hamburger (mobile) -->
                <button
                    class="lg:hidden text-slate-500 hover:text-slate-800 p-1"
                    @click="sidebarOpen = !sidebarOpen"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>

                <!-- Page title -->
                <div class="hidden lg:flex items-center gap-2">
                    <span class="text-slate-400 text-sm">Admin</span>
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                    </svg>
                    <span class="text-slate-800 font-semibold text-sm">{{ currentPageTitle }}</span>
                </div>

                <!-- Right side -->
                <div class="flex items-center gap-3 ml-auto">
                    <span class="text-slate-500 text-sm hidden sm:block">{{ auth?.user?.name }}</span>
                    <div class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                        <span class="text-green-700 font-semibold text-sm">
                            {{ (auth?.user?.name ?? 'A').charAt(0).toUpperCase() }}
                        </span>
                    </div>
                </div>
            </header>

            <!-- Content -->
            <main class="flex-1 overflow-y-auto p-4 lg:p-6">
                <slot />
            </main>
        </div>
    </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { usePage, router, Link } from '@inertiajs/vue3'

const page = usePage()
const auth = computed(() => page.props.auth)
const sidebarOpen = ref(false)

const navItems = [
    {
        href: '/admin',
        label: 'Dashboard',
        iconPath: '<path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />',
    },
    {
        href: '/admin/users',
        label: 'Users',
        iconPath: '<path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />',
    },
    {
        href: '/admin/households',
        label: 'Households',
        iconPath: '<path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />',
    },
    {
        href: '/admin/transactions',
        label: 'Transaksi',
        iconPath: '<path stroke-linecap="round" stroke-linejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />',
    },
]

function isActive(href) {
    const url = page.url
    if (href === '/admin') {
        return url === '/admin' || url === '/admin/'
    }
    return url.startsWith(href)
}

const currentPageTitle = computed(() => {
    const url = page.url
    const item = navItems.find(n => {
        if (n.href === '/admin') return url === '/admin' || url === '/admin/'
        return url.startsWith(n.href)
    })
    return item?.label ?? 'Admin'
})

function logout() {
    router.post('/admin/logout')
}
</script>
