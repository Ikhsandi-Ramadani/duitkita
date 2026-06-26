<template>
    <div class="min-h-screen flex items-center justify-center bg-[#0f172a]">
        <div class="w-full max-w-md">
            <!-- Logo / Brand -->
            <div class="text-center mb-8">
                <div class="inline-flex items-center gap-2 mb-3">
                    <div class="w-10 h-10 rounded-xl bg-amber-500 flex items-center justify-center">
                        <span class="text-white font-bold text-lg">D</span>
                    </div>
                    <span class="text-white text-2xl font-bold">DuitKita</span>
                </div>
                <p class="text-slate-400 text-sm">Panel Admin</p>
            </div>

            <!-- Card -->
            <div class="bg-[#1e293b] rounded-2xl p-8 shadow-2xl border border-slate-700">
                <h1 class="text-white text-xl font-semibold mb-6">Masuk ke Admin</h1>

                <form @submit.prevent="submit" class="space-y-5">
                    <!-- Email -->
                    <div class="flex flex-col gap-1">
                        <label class="text-slate-300 text-sm font-medium">Email</label>
                        <InputText
                            v-model="form.email"
                            type="email"
                            placeholder="admin@example.com"
                            :invalid="!!form.errors.email"
                            class="w-full"
                            autocomplete="email"
                        />
                        <small v-if="form.errors.email" class="text-red-400 text-xs">
                            {{ form.errors.email }}
                        </small>
                    </div>

                    <!-- Password -->
                    <div class="flex flex-col gap-1">
                        <label class="text-slate-300 text-sm font-medium">Password</label>
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
                        <small v-if="form.errors.password" class="text-red-400 text-xs">
                            {{ form.errors.password }}
                        </small>
                    </div>

                    <!-- Remember Me -->
                    <div class="flex items-center gap-2">
                        <Checkbox v-model="form.remember" :binary="true" input-id="remember" />
                        <label for="remember" class="text-slate-300 text-sm cursor-pointer">
                            Ingat saya
                        </label>
                    </div>

                    <!-- Submit -->
                    <Button
                        type="submit"
                        label="Masuk"
                        :loading="form.processing"
                        class="w-full"
                        severity="warning"
                        size="large"
                    />
                </form>
            </div>
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
