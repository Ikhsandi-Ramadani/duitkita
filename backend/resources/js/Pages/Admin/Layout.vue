<template>
    <div class="flex h-screen bg-[#0f172a] overflow-hidden">
        <!-- Sidebar Overlay (mobile) -->
        <div
            v-if="sidebarOpen"
            class="fixed inset-0 bg-black/50 z-20 lg:hidden"
            @click="sidebarOpen = false"
        />

        <!-- Sidebar -->
        <aside
            :class="[
                'fixed lg:static inset-y-0 left-0 z-30 flex flex-col bg-[#1e293b] border-r border-slate-700 transition-transform duration-300',
                sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0',
                'w-64',
            ]"
        >
            <!-- Brand -->
            <div class="flex items-center gap-3 px-6 py-5 border-b border-slate-700">
                <div class="w-9 h-9 rounded-xl bg-amber-500 flex items-center justify-center shrink-0">
                    <span class="text-white font-bold">D</span>
                </div>
                <span class="text-white font-bold text-lg">DuitKita</span>
            </div>

            <!-- Nav -->
            <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
                <NavLink
                    v-for="item in navItems"
                    :key="item.href"
                    :href="item.href"
                    :label="item.label"
                    :icon="item.icon"
                    :active="isActive(item.href)"
                />
            </nav>

            <!-- User info at bottom -->
            <div class="px-4 py-4 border-t border-slate-700">
                <p class="text-slate-400 text-xs truncate">{{ auth?.user?.email }}</p>
            </div>
        </aside>

        <!-- Main -->
        <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
            <!-- Top Bar -->
            <header class="flex items-center justify-between px-4 lg:px-6 py-4 bg-[#1e293b] border-b border-slate-700 shrink-0">
                <!-- Hamburger (mobile) -->
                <button
                    class="lg:hidden text-slate-400 hover:text-white p-1"
                    @click="sidebarOpen = !sidebarOpen"
                >
                    <i class="pi pi-bars text-xl" />
                </button>

                <!-- Page title -->
                <h2 class="text-white font-semibold text-lg hidden lg:block">
                    {{ currentPageTitle }}
                </h2>

                <!-- Actions -->
                <div class="flex items-center gap-3 ml-auto">
                    <span class="text-slate-300 text-sm hidden sm:block">
                        {{ auth?.user?.name }}
                    </span>
                    <Button
                        label="Keluar"
                        icon="pi pi-sign-out"
                        severity="secondary"
                        size="small"
                        outlined
                        @click="logout"
                    />
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
import { usePage, router } from '@inertiajs/vue3'
import Button from 'primevue/button'

// Sub-component for nav links
const NavLink = {
    props: ['href', 'label', 'icon', 'active'],
    template: `
        <a
            :href="href"
            :class="[
                'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                active
                    ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30'
                    : 'text-slate-400 hover:text-white hover:bg-slate-700/50'
            ]"
            @click.prevent="navigate"
        >
            <i :class="['pi', icon, 'text-base']" />
            <span>{{ label }}</span>
        </a>
    `,
    methods: {
        navigate() {
            const { router } = require('@inertiajs/vue3')
            router.visit(this.href)
        },
    },
}

const page = usePage()
const auth = computed(() => page.props.auth)
const sidebarOpen = ref(false)

const navItems = [
    { href: '/admin', label: 'Dashboard', icon: 'pi-home' },
    { href: '/admin/users', label: 'Pengguna', icon: 'pi-users' },
    { href: '/admin/households', label: 'Keluarga', icon: 'pi-building' },
    { href: '/admin/transactions', label: 'Transaksi', icon: 'pi-wallet' },
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
