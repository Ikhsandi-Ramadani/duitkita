<template>
    <Layout>
        <div class="max-w-2xl">
            <!-- Page Header -->
            <div class="mb-6">
                <h1 class="text-slate-900 font-bold text-xl">Versi Aplikasi</h1>
                <p class="text-slate-500 text-sm mt-1">Kelola informasi versi APK yang ditampilkan ke pengguna.</p>
            </div>

            <!-- Form Card -->
            <div class="bg-white rounded-xl border border-slate-100 shadow-sm">
                <div class="px-6 py-4 border-b border-slate-100">
                    <h2 class="text-slate-800 font-semibold text-base">Pengaturan Versi</h2>
                </div>

                <form class="px-6 py-5 space-y-5" @submit.prevent="submit">
                    <!-- Versi Aplikasi -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-medium text-slate-700">
                            Versi Aplikasi <span class="text-red-500">*</span>
                        </label>
                        <InputText
                            v-model="form.app_version"
                            placeholder="mis: 1.0.1"
                            class="w-full"
                            :invalid="!!form.errors.app_version"
                        />
                        <small v-if="form.errors.app_version" class="text-red-500 text-xs">
                            {{ form.errors.app_version }}
                        </small>
                    </div>

                    <!-- Build Number -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-medium text-slate-700">
                            Build Number <span class="text-red-500">*</span>
                        </label>
                        <InputNumber
                            v-model="form.app_build"
                            :min="1"
                            :use-grouping="false"
                            placeholder="mis: 2"
                            class="w-full"
                            :invalid="!!form.errors.app_build"
                        />
                        <small v-if="form.errors.app_build" class="text-red-500 text-xs">
                            {{ form.errors.app_build }}
                        </small>
                    </div>

                    <!-- URL Download APK -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-medium text-slate-700">
                            URL Download APK <span class="text-red-500">*</span>
                        </label>
                        <InputText
                            v-model="form.app_download_url"
                            placeholder="https://github.com/.../app-arm64-v8a-release.apk"
                            class="w-full"
                            :invalid="!!form.errors.app_download_url"
                        />
                        <small v-if="form.errors.app_download_url" class="text-red-500 text-xs">
                            {{ form.errors.app_download_url }}
                        </small>
                    </div>

                    <!-- Catatan Rilis -->
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-medium text-slate-700">
                            Catatan Rilis <span class="text-red-500">*</span>
                        </label>
                        <Textarea
                            v-model="form.app_release_notes"
                            placeholder="Deskripsi perubahan di versi ini..."
                            rows="4"
                            class="w-full resize-none"
                            :invalid="!!form.errors.app_release_notes"
                        />
                        <small v-if="form.errors.app_release_notes" class="text-red-500 text-xs">
                            {{ form.errors.app_release_notes }}
                        </small>
                    </div>

                    <!-- Force Update -->
                    <div class="flex items-center gap-3">
                        <ToggleSwitch v-model="form.app_force_update" input-id="force-update" />
                        <label for="force-update" class="text-sm font-medium text-slate-700 cursor-pointer select-none">
                            Force Update
                            <span class="ml-1.5 text-slate-400 font-normal">(pengguna tidak bisa melewati update)</span>
                        </label>
                    </div>

                    <!-- Submit -->
                    <div class="pt-2 flex items-center gap-3">
                        <Button
                            type="submit"
                            label="Simpan Pengaturan"
                            severity="success"
                            :loading="form.processing"
                        />
                        <span v-if="saved" class="flex items-center gap-1.5 text-green-600 text-sm font-medium">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                            </svg>
                            Tersimpan
                        </span>
                    </div>
                </form>
            </div>

            <!-- Current Values Info -->
            <div class="mt-4 bg-slate-50 rounded-xl border border-slate-100 px-5 py-4">
                <p class="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">Nilai Saat Ini</p>
                <dl class="space-y-2">
                    <div class="flex items-center gap-2">
                        <dt class="text-xs text-slate-400 w-28 shrink-0">Versi</dt>
                        <dd class="text-xs font-mono text-slate-700">{{ props.settings.app_version }}</dd>
                    </div>
                    <div class="flex items-center gap-2">
                        <dt class="text-xs text-slate-400 w-28 shrink-0">Build</dt>
                        <dd class="text-xs font-mono text-slate-700">{{ props.settings.app_build }}</dd>
                    </div>
                    <div class="flex items-center gap-2">
                        <dt class="text-xs text-slate-400 w-28 shrink-0">Force Update</dt>
                        <dd class="text-xs font-mono text-slate-700">{{ props.settings.app_force_update }}</dd>
                    </div>
                    <div class="flex items-start gap-2">
                        <dt class="text-xs text-slate-400 w-28 shrink-0 pt-0.5">URL</dt>
                        <dd class="text-xs font-mono text-slate-700 break-all">{{ props.settings.app_download_url }}</dd>
                    </div>
                </dl>
            </div>
        </div>
    </Layout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useForm, usePage } from '@inertiajs/vue3'
import Layout from '../Layout.vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Textarea from 'primevue/textarea'
import ToggleSwitch from 'primevue/toggleswitch'

const props = defineProps({
    settings: Object,
})

const form = useForm({
    app_version:       props.settings.app_version,
    app_build:         parseInt(props.settings.app_build, 10),
    app_download_url:  props.settings.app_download_url,
    app_release_notes: props.settings.app_release_notes,
    app_force_update:  props.settings.app_force_update === 'true',
})

const saved = ref(false)

// Show "Tersimpan" checkmark briefly when flash success arrives
const page = usePage()
watch(
    () => page.props.flash?.success,
    (val) => {
        if (val) {
            saved.value = true
            setTimeout(() => { saved.value = false }, 3000)
        }
    }
)

function submit() {
    form.post('/admin/settings/app-version', {
        preserveScroll: true,
    })
}
</script>
