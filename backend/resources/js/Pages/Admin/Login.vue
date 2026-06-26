<template>
    <div class="min-h-screen flex items-center justify-center bg-slate-50">
        <div class="w-full max-w-md px-4">
            <!-- Logo / Brand -->
            <div class="text-center mb-8">
                <div class="inline-flex items-center gap-3 mb-3">
                    <div class="w-11 h-11 rounded-xl bg-green-600 flex items-center justify-center shadow-sm">
                        <span class="text-white font-bold text-xl">D</span>
                    </div>
                    <span class="text-slate-900 text-2xl font-bold">DuitKita</span>
                </div>
                <p class="text-slate-500 text-sm">Masuk ke Panel Admin</p>
            </div>

            <!-- Card -->
            <div class="bg-white rounded-2xl p-8 shadow-md border border-slate-200">
                <h1 class="text-slate-800 text-xl font-semibold mb-6">Selamat Datang</h1>

                <form @submit.prevent="submit" class="space-y-5">
                    <!-- Email -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-slate-700 text-sm font-medium">Email</label>
                        <InputText
                            v-model="form.email"
                            type="email"
                            placeholder="admin@example.com"
                            :invalid="!!form.errors.email"
                            class="w-full"
                            autocomplete="email"
                        />
                        <small v-if="form.errors.email" class="text-red-500 text-xs">
                            {{ form.errors.email }}
                        </small>
                    </div>

                    <!-- Password -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-slate-700 text-sm font-medium">Password</label>
                        <Password
                            v-model="form.password"
                            placeholder="••••••••"
                            :feedback="false"
                            :invalid="!!form.errors.password"
                            input-class="w-full"
                            class="w-full"
                            toggle-mask
                            autocomplete="current-password"
                        />
                        <small v-if="form.errors.password" class="text-red-500 text-xs">
                            {{ form.errors.password }}
                        </small>
                    </div>

                    <!-- Remember Me -->
                    <div class="flex items-center gap-2">
                        <Checkbox v-model="form.remember" :binary="true" input-id="remember" />
                        <label for="remember" class="text-slate-600 text-sm cursor-pointer">
                            Ingat saya
                        </label>
                    </div>

                    <!-- Submit -->
                    <Button
                        type="submit"
                        label="Masuk"
                        :loading="form.processing"
                        class="w-full"
                        severity="success"
                        size="large"
                    />
                </form>
            </div>

            <p class="text-center text-slate-400 text-xs mt-6">
                DuitKita &copy; {{ new Date().getFullYear() }} — Admin Panel
            </p>
        </div>
    </div>
</template>

<script setup>
import { useForm } from '@inertiajs/vue3'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'

const form = useForm({
    email: '',
    password: '',
    remember: false,
})

function submit() {
    form.post('/admin/login', {
        onFinish: () => form.reset('password'),
    })
}
</script>
