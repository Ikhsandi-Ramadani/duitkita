<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DuitKita Admin</title>
    @vite('resources/css/app.css')
    @livewireStyles
</head>
<body class="font-sans antialiased">
    <main class="flex min-h-screen items-center justify-center bg-slate-50 px-4 py-8">
        {{ $slot }}
    </main>
    @livewireScripts
</body>
</html>
