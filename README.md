# Handoff: DuitKita — Aplikasi Pencatatan Keuangan Keluarga (Mobile)

## Overview
DuitKita adalah aplikasi pencatatan keuangan **keluarga** (2–5 anggota) dengan model **hybrid**: tiap anggota punya **dompet pribadi**, ada **dompet bersama** untuk kebutuhan rumah tangga, dan semua anggota bisa **saling melihat** arus kas (transparansi penuh). Bahasa antarmuka **Indonesia**, mata uang **Rupiah (IDR)**.

Paket ini berisi **prototipe mobile lengkap** (16+ layar, fully clickable) yang menjadi **acuan visual & interaksi** untuk implementasi.

## About the Design Files
File dalam bundel ini adalah **referensi desain yang dibuat dengan HTML/React (via Babel in-browser)** — prototipe yang menunjukkan tampilan & perilaku yang diinginkan, **bukan kode produksi untuk disalin langsung**.

Tugasnya: **membangun ulang desain ini di environment target**. Sesuai PRD, target implementasi adalah **Flutter** (Riverpod/Bloc untuk state, Drift/Isar/sqflite untuk DB lokal + sync queue, `local_auth` untuk app lock, `fl_chart` untuk grafik). Gunakan pola & widget native Flutter — jangan menyalin struktur DOM/CSS apa adanya. Backend: Laravel + API (Sanctum), dashboard web Filament (dibrief terpisah).

Semua warna, tipografi, spacing, ikon, dan interaksi di bawah ini bersifat **final (hi-fi)** dan harus direproduksi seakurat mungkin.

## Fidelity
**High-fidelity (hi-fi).** Warna, tipografi, spacing, radius, bayangan, dan animasi sudah final. Recreate pixel-perfect di Flutter. Nilai yang tertera (hex, px, weight) adalah acuan; di Flutter konversi px → logical pixels 1:1 (desain dibuat untuk lebar layar 390pt).

---

## Design Tokens

### Tipografi
- **Font family:** `Plus Jakarta Sans` (Google Fonts), weights 400/500/600/700/800. Fallback: system sans.
- **Angka (uang) = elemen utama.** Selalu pakai **tabular numerals** (`font-feature-settings: "tnum"`; di Flutter: `FontFeature.tabularFigures()`), `letter-spacing: -0.01em` s/d `-0.03em` untuk angka besar.
- Skala teks yang dipakai (px → fontSize, weight):
  - Saldo hero (Home): **40 / 800**, prefix "Rp" 24 / 700 opacity .82
  - Angka kartu/section: 30 / 800, 23 / 800, 21 / 800, 20 / 800
  - Judul layar: 24 / 800 (letter-spacing −0.02em)
  - Judul section: 14–14.5 / 800
  - Judul kartu: 15.5 / 700
  - Body: 14.5 / 500–600
  - Label/caption: 12.5–13 / 600
  - Mikro/badge: 11–11.5 / 600–700
  - Amount baris transaksi: 15 / 700

### Warna — Light (default)
| Token | Hex |
|---|---|
| bg (luar frame) | `#eef1ef` |
| app-bg (latar layar) | `#f6f8f6` |
| surface (kartu) | `#ffffff` |
| surface-2 | `#f1f4f2` |
| surface-3 | `#e8ece9` |
| text | `#15201b` |
| text-2 | `#5a6b63` |
| text-3 (muted) | `#8b988f` |
| border | `#e7ebe8` |
| border-2 | `#dde3df` |
| **primary** (emerald) | `#047857` |
| primary-600 | `#058564` |
| primary-700 | `#036249` |
| primary-tint | `#e6f2ed` |
| primary-tint-2 | `#d3e8e0` |
| on-primary | `#ffffff` |

### Warna semantik (jenis transaksi) — Light
| Makna | Warna | Tint |
|---|---|---|
| **Pemasukan / income** (hijau) | `#0e9f6e` | `#e3f5ee` |
| **Pengeluaran / expense** (oranye-merah lembut) | `#e0603f` | `#fbeae4` |
| **Transfer** (biru) | `#3b6fd4` | `#e6edfa` |
| **Penyesuaian / adjustment** (abu hangat) | `#8b7355` | `#f1ece5` |

### Warna — Dark
| Token | Hex |
|---|---|
| bg | `#0b110e` |
| app-bg | `#0f1613` |
| surface | `#18211c` |
| surface-2 | `#1f2a24` |
| surface-3 | `#26332c` |
| text | `#e9efeb` |
| text-2 | `#9eb0a7` |
| text-3 | `#6c7d75` |
| border | `#283330` |
| border-2 | `#30403a` |
| primary | `#14b083` |
| primary-600 | `#16c091` |
| primary-700 | `#0f9d75` |
| primary-tint | `#11362c` |
| primary-tint-2 | `#154437` |
| on-primary | `#04211a` |
| income | `#2dc28d` / tint `#133229` |
| expense | `#f0795a` / tint `#36211b` |
| transfer | `#5b8def` / tint `#1a2840` |
| adjust | `#c0a786` / tint `#2c261d` |

### Avatar anggota (warna berbasis hue, chroma/lightness konsisten)
- Avatar bg: `hsl(<hue> 44% 46%)`, teks putih, font 700.
- Tint (light): `hsl(<hue> 42% 90%)`.
- Hue per anggota: **Budi 162** (emerald), **Sari 340** (rose), **Rian 255** (violet).

### Chip ikon kategori (warna berbasis hue kategori)
- Light: bg `hsl(<hue> 48% 94%)`, ikon `hsl(<hue> 55% 42%)`.
- Dark: bg `hsl(<hue> 30% 20%)`, ikon `hsl(<hue> 58% 66%)`.
- Hue kategori: Makanan 24, Transport 210, Bensin 30, Tagihan 265, Pulsa 190, Belanja 320, Kesehatan 0, Pendidikan 230, Hiburan 290, Arisan 130, Zakat 160, Lainnya 200, Gaji 162, Bonus 145.

### Spacing / Radius / Shadow
- **Radius:** sm `12`, base `18`, lg `24`, xl `30`. Chip/tile `11–17`. Avatar/FAB lihat per komponen. Phone frame `46`.
- **Padding layar:** horizontal `20`. Padding kartu `15–18`. Gap antar elemen umum `8–14`.
- **Shadow (light):**
  - sm: `0 1px 2px rgba(20,40,30,.05), 0 1px 3px rgba(20,40,30,.04)`
  - base: `0 4px 16px rgba(20,40,30,.07), 0 2px 6px rgba(20,40,30,.04)`
  - lg: `0 12px 34px rgba(20,40,30,.12)`
  - primary (FAB/CTA): `0 8px 24px rgba(4,120,87,.32)`
- **Border kartu:** `1px solid var(--border)`.
- **Animasi:** entrance `cubic-bezier(.22,1,.36,1)` ~.32s (slide-up 8px + fade); bottom sheet slide-up .34s; progress bar width .6–.7s; toggle/transition .2s. Hormati `prefers-reduced-motion`.

---

## Device Frame & Navigasi Global
- **Canvas desain:** 390 × 846 (lebar acuan 390). Di Flutter responsif penuh; jangan hardcode 390 kecuali untuk proporsi.
- **Status bar:** tinggi ±46. Pada layar berheader emerald (Home, App Lock) ikon status **putih**; layar lain ikon **gelap**.
- **Bottom navigation** (tinggi ±76, surface bg, border-top, shadow `0 -6px 24px rgba(0,0,0,.05)`): 5 slot — **Beranda · Transaksi · [ + ] · Dompet · Profil**.
  - Slot tengah = **FAB** menonjol: 60×60, radius 22, bg primary, ikon "+" putih (stroke 2.4), `margin-top: -22` (mengambang di atas bar), shadow primary. Membuka alur **Tambah Transaksi**.
  - Item aktif: warna primary, label 700; non-aktif: text-3, label 600. Ikon outline, stroke 1.9 (aktif 2.3).
- **Ikon:** set garis (outline) custom, viewBox 24, stroke 1.75–2, linecap/linejoin round, `currentColor`. Di Flutter pakai **Lucide** (paket `lucide_icons`) atau `Icons` Material yang setara — gaya outline ringan. Daftar makna ikon ada di `app/icons.jsx`.

---

## Screens / Views

> Atribusi kepemilikan muncul di mana-mana: tiap baris transaksi punya **badge avatar pencatat** (lingkaran kecil 19px dengan ring surface di pojok kanan-bawah ikon kategori), badge **Pribadi/Bersama**, dan label **"untuk <nama>"**.

### 1. App Lock
- **Tujuan:** kunci aplikasi saat dibuka (PIN + biometrik).
- **Layout:** full-screen gradient emerald `linear-gradient(165deg, #058564, #036249 55%, #024c39)`, konten center, teks putih.
- **Komponen:** brand mark (rounded square 58, ikon wallet putih) + "DuitKita" (22/800) + subjudul "Keuangan Keluarga Pratama"; avatar user 64 dengan ring putih + "Halo, Budi"; teks "Masukkan PIN kamu"; **6 titik PIN** (13px, terisi putih); **keypad numerik** (tombol bulat 72px, bg `rgba(255,255,255,.13)`, angka 26/600), pojok kiri-bawah = tombol **biometrik** (ikon fingerprint), kanan-bawah = backspace; link "Bukan Budi? Ganti akun".
- **Behavior:** ketik 6 digit → auto-unlock (delay ~220ms) → Beranda. Tap fingerprint → unlock (delay ~300ms). "Ganti akun" → layar Login.

### 2. Login / Onboarding
- **Tujuan:** masuk; untuk first-run pilih buat/gabung keluarga.
- **Login:** brand mark; judul "Masuk ke DuitKita" (27/800); field Email & Kata sandi (tinggi 52, radius 14, surface bg, border-2, ikon kiri); link "Lupa sandi?"; tombol primary "Masuk" (54, radius 16); divider "Pertama kali pakai?"; dua kartu pilihan: **Buat Keluarga Baru** (ikon users, primary-tint) & **Gabung Keluarga** (ikon qr) — masing-masing baris dengan judul 15/700 + subjudul + chevron.
- **Buat Keluarga (CreateView):** TopBar back; penjelasan role owner; field "Nama kamu" & "Nama keluarga"; info box primary-tint; tombol "Buat & Mulai".
- **Gabung (JoinView):** TopBar back; 6 kotak input kode (46×58, radius 14, border jadi primary saat terisi, font 24/800); tombol "Gabung Keluarga" (aktif saat 6 kotak terisi).

### 3. Beranda (Home) — layar terpenting
- **Header emerald** (gradient `158deg, #058564→#036249`, sudut bawah membulat 30, bleed ke atas di belakang status bar, dua lingkaran dekoratif `rgba(255,255,255,.05–.07)`):
  - Baris atas: avatar user + "Selamat pagi," + "Budi 👋"; kanan tombol lonceng (notif) dengan dot kuning `#ffd23d`.
  - **Total Kekayaan Keluarga** + tombol mata (sembunyikan saldo) → **angka besar 40/800 putih**.
  - Dua **glass card** (bg `rgba(255,255,255,.14)`, border `rgba(255,255,255,.2)`, blur): "Saldo Saya" & "Kas Bersama" (label 12.5 + angka 18.5/800).
- **Body (app-bg):**
  - **Kartu Budget** "Pengeluaran Juni" → "{n}% terpakai" + chevron; angka terpakai vs "dari Rp…"; progress bar (warna expense bila over). Tap → layar Anggaran.
  - **Quick actions** (4 tile: ikon 52px radius 17 primary-tint + label): Isi Kas Bersama, Transfer, Pemasukan, Scan Struk.
  - **Hub fitur** (baris scroll horizontal, tile 56px radius 18 surface+border): Anggaran, Tujuan, Utang, Berulang, Laporan.
  - **Kartu ringkasan Target & Utang** (dua bagian dibagi divider): kiri "Kantong Tujuan" (ring kecil + total terkumpul), kanan "Utang / Piutang" (−utang merah, +piutang hijau). Tap → layar terkait.
  - **Transaksi Terbaru** (header + "Lihat semua") → kartu berisi 5 baris transaksi.

### 4. Tambah Transaksi (alur cepat) — paling sering dipakai
- **Full-screen overlay** (bukan sheet). Header: tombol X (tutup) + judul "Catat Transaksi" / "Edit Transaksi".
- **Selector jenis** (segmented 4, warna mengikuti jenis saat aktif): **Keluar / Masuk / Transfer / Sesuaikan**.
- **Amount hero:** label ("Nominal" / "Saldo sebenarnya" untuk adjustment) + **angka 46/800** berwarna sesuai jenis. Untuk **Penyesuaian**: tampilkan **Selisih** (target − saldo dompet saat ini) dengan tanda + / −.
- **Kartu detail (baris yang relevan per jenis):** Kategori (income/expense), Dompet (sumber), Ke dompet (transfer), **Untuk** (pilih avatar anggota, opsional, expense/income), Catatan, Foto struk.
- **Keypad numerik** (grid 3 kolom: 1–9, `000`, 0, backspace; tombol 52 tinggi, radius 15, surface+border). Tombol **Simpan** (56, radius 17) warna mengikuti jenis, disabled hingga valid.
- **Sheets pendukung:** pilih Kategori (grid 4 kolom, chip ikon 54), pilih Dompet (dikelompok: Dompet Saya / Kas Bersama / Dompet Anggota Lain, dengan saldo), input Catatan (textarea).
- **Shortcut "Isi Kas Bersama"** = preset jenis Transfer, sumber = dompet pribadi utama, tujuan = Kas Belanja.

### 5. Daftar Transaksi
- TopBar judul "Transaksi" (24/800); **search bar** (cari catatan/kategori/nominal); **filter chip** scroll: Semua/Keluar/Masuk/Transfer/Penyesuaian + chip "Anggota" (buka sheet pilih anggota).
- **List dikelompokkan per tanggal** (header "Hari ini"/"Kemarin"/"<Hari, tgl>" + **net harian** berwarna). Tiap grup = kartu berisi baris transaksi. Tap baris → Detail.

### 6. Detail Transaksi
- TopBar back (+ tombol Edit hanya bila milik user login).
- Hero: ikon kategori/jenis (64, radius 22, tint) + nama kategori (warna jenis) + **amount 38/800** (dengan tanda) + catatan.
- Kartu field: Jenis, Dompet (untuk transfer: "asal → tujuan"; lain: nama + badge Pribadi/Bersama), Tanggal, Waktu (WIB), **Dicatat oleh** (avatar+nama), **Untuk** (bila ada), Struk.
- **Aturan kepemilikan:** tombol **Edit & Hapus** hanya tampil bila `recorded_by === user login`. Bila bukan miliknya → info box "Hanya <nama> yang dapat mengubah transaksi ini." Hapus → konfirmasi sheet.

### 7. Dompet
- TopBar "Dompet" + tombol "+ Dompet".
- **Kartu total** emerald (Total Kekayaan Keluarga + Saldo Saya + Kas Bersama).
- **Kelompok:** "Dompet Saya" (dikelola olehmu), "Kas Bersama" (milik keluarga), "Dompet <Anggota>" (hanya bisa dilihat). Tiap kelompok punya total. Kartu dompet: ikon jenis (cash/bank/ewallet), nama, jenis (+avatar pemilik utk anggota lain), saldo 16/800, chevron. Tap → Detail Dompet.

### 8. Detail Dompet
- TopBar nama dompet + menu.
- **Hero saldo:** untuk **Kas Bersama** kartu emerald (teks putih); untuk pribadi kartu surface. Ikon jenis + "jenis · pemilik/Bersama" + "Saldo saat ini" + angka 36/800.
- **Aksi** (bila milik user / bersama): "+ Transaksi" (primary) & "Sesuaikan" (penyesuaian saldo). Bila dompet anggota lain → info "hanya bisa dilihat".
- **Riwayat** transaksi dompet (dikelompok per tanggal).

### 9. Profil / Pengaturan
- Judul "Profil"; **kartu profil** (avatar 60 + nama + badge "Owner" + email + tombol edit).
- **Kartu keluarga** "Keluarga Pratama" (n anggota) + tombol "Undang" → sheet kode undangan (6 char `PRT4K9`, tombol Salin & Bagikan). Daftar anggota dengan role.
- Section **AKUN**: Edit profil, Ganti PIN, Keamanan & biometrik.
- Section **KELOLA KELUARGA** (badge "Owner", owner-only): Kelola anggota, Kelola kategori, Kelola dompet.
- Section **APLIKASI**: **Mode gelap** (toggle), Notifikasi, Tentang DuitKita (v1.4).
- Tombol **Keluar** (expense-tint) → kembali ke Login.

### 10. Anggaran (Budget)
- TopBar "Anggaran Juni". Kartu emerald total terpakai vs anggaran + sisa + progress. Daftar **per kategori**: chip ikon + nama + "terpakai/anggaran" + persen + progress bar (merah bila over).

### 11. Notifikasi
- TopBar "Notifikasi". Daftar kartu: ikon berwarna (warning/transfer/income/bell) + judul + sub + waktu. (Contoh: budget hampir habis, isi kas, gaji masuk, tagihan jatuh tempo.)

### 12. Kantong Tujuan (Savings Goals)
- TopBar "Kantong Tujuan" + "+". Kartu emerald total terkumpul vs target. Kelompok: **Tujuan Bersama / Tujuan Saya / Tujuan Anggota Lain**.
- **Kartu goal** (tap → Detail): **ring progres** (56, persen di tengah) + nama (ikon) + badge Bersama/Pribadi + tanggal target; current/target + progress bar; "Kurang Rp…" + tombol **"Sisihkan dana"**.
- **Sisihkan dana** (AmountSheet): chip cepat (+50rb/100rb/250rb/500rb/1jt) + Reset, pilih **sumber dompet**, konfirmasi → progres goal naik & uang ditransfer ke dompet penyimpanan goal (tercatat sebagai transaksi transfer; bila sumber = dompet goal → earmark saja).

### 13. Detail Kantong
- Hero: ring besar (104) + nama + badge + tanggal + current/target + "tersimpan di <dompet>". Tombol "Sisihkan dana". **Riwayat Kontribusi** (daftar transaksi setoran; empty state bila kosong).

### 14. Utang & Piutang
- TopBar "Utang & Piutang" + "+". Dua **kartu ringkasan**: Utang (merah, "harus dibayar") & Piutang (hijau, "akan diterima"). **Segmented** Utang (n) / Piutang (n).
- **Kartu item** (tap → Detail): inisial pihak (chip warna jenis) + nama + catatan + badge Bersama / avatar pemilik; "Sisa"/"Lunas" + amount + "dari Rp total"; progress; status jatuh tempo berwarna (merah bila ≤7 hari / terlambat, kuning `#c98a16` bila dekat) + tombol **Bayar/Terima**.
- **Bayar/Terima** (AmountSheet, default = sisa, pilih dompet): payable → expense dari dompet; receivable → income ke dompet. Update `paid` & saldo.

### 15. Detail Utang/Piutang
- Hero: inisial + pihak + catatan + badge + status; sisa/total + progress. Tombol Bayar cicilan / Terima pembayaran. **Riwayat Pembayaran**.

### 16. Transaksi Berulang (Recurring)
- TopBar "Transaksi Berulang" + "+". Dua kartu ringkasan (masuk rutin/bln, keluar rutin/bln).
- **Kartu template:** ikon (kategori/income) + nama + "dompet · frekuensi" + amount berwarna; baris "Berikutnya <tgl>" + **toggle Otomatis/Ingatkan**; tombol **"Catat sekarang"** (membuat transaksi langsung).

### 17. Laporan
- TopBar "Laporan" + pemilih periode ("Juni 2026"). Dua kartu Pemasukan/Pengeluaran.
- **Donut** pengeluaran per kategori (conic-gradient; di Flutter pakai `fl_chart` PieChart) + legend (warna, nama, persen) + total di lubang tengah.
- **Grafik arus kas bulanan** (bar ganda income/expense per bulan; legend Masuk/Keluar).
- **Pengeluaran per anggota** (avatar + nama + amount + bar, atribusi `spent_by || recorded_by`).

### Forms (bottom sheet) — Tambah entitas
- **Tambah Kantong:** Nama, Target (RupiahInput), Jangka waktu (chip 3/6/12/24 bln), Jenis (Bersama/Pribadi), Dompet penyimpanan, Ikon. 
- **Tambah Utang/Piutang:** Jenis, Pihak, Jumlah, Jatuh tempo (chip 1mg/2mg/1bln/3bln), Milik, Dompet terkait, Catatan.
- **Tambah Template Berulang:** Jenis, Nama, Jumlah, Kategori, Dompet, Frekuensi.
- Komponen input bersama: **RupiahInput** (prefix "Rp", input numerik berformat ribuan titik), TextInput (ikon + field), ChipRow (chip pilihan scroll), Segmented, SaveButton.

---

## Interactions & Behavior
- **Navigasi:** 4 tab utama + stack push untuk layar detail/sekunder (back menutup). Bottom nav **disembunyikan** di layar pushed (detail) dan saat overlay Tambah Transaksi terbuka.
- **Tambah/Edit/Hapus transaksi** memutasi saldo dompet secara konsisten:
  - income: `+amount` ke dompet; expense: `−amount`; transfer: `−` sumber & `+` tujuan; adjustment: `±selisih`.
  - Hapus = kebalikannya. Edit = balikkan transaksi lama lalu terapkan baru.
- **Toast** konfirmasi (mis. "Transaksi tersimpan ✓") muncul ±2.2s di atas bottom nav.
- **Sembunyikan saldo** (mata): ganti semua nominal jadi "••••••".
- **Dark mode:** toggle dari Profil atau Tweaks; seluruh token warna beralih.
- **Validasi:** tombol Simpan disabled hingga syarat minimal terpenuhi (nominal > 0; transfer butuh tujuan ≠ sumber; income/expense butuh kategori; form butuh nama + jumlah).
- **Animasi:** lihat token. Entrance per layar, slide-up untuk sheet, ring/bar progres beranimasi.

## State Management
Skema data (selaras PRD — gunakan untuk model Drift/Isar):
- **households**: id, name, owner_id.
- **users (members)**: id, household_id, name, email, role(owner|member); UI: init, hue.
- **wallets**: id, household_id, scope(personal|shared), owner_user_id(nullable; wajib bila personal), name, type(cash|bank|ewallet), icon, color, initial_balance, current_balance.
- **categories**: id, household_id, name, type(income|expense), icon, parent_id.
- **transactions**: id, client_id(uuid idempotensi sync), household_id, type(income|expense|transfer|adjustment), wallet_id, target_wallet_id(nullable), category_id(nullable utk transfer/adjustment), amount, date, note, **recorded_by**, **spent_by**(nullable), receipt_path(nullable), updated_at, deleted_at.
- **budgets**: id, scope(family|personal), owner_user_id(nullable), category_id, amount, period_month.
- **savings_goals (kantong)**: id, scope(family|personal), owner_user_id(nullable), name, target_amount, current_amount, target_date, wallet_id, icon, hue.
- **debts (utang/piutang)**: id, owner_user_id(nullable), type(payable|receivable), party_name, amount, paid, date, due_date, status, note, wallet_id.
- **recurrings**: id, type(income|expense), wallet_id, category_id, amount, freq, next_run_date, end_date, auto_create(bool), note.

Aturan penting: saldo = initial + Σ(income) − Σ(expense) ± transfer ± adjustment (cache `current_balance`). Adjustment dikecualikan dari agregasi income/expense pada laporan. Transfer netral terhadap total kekayaan. Edit/hapus transaksi **hanya oleh recorded_by** (owner tidak override). Visibilitas baca penuh untuk semua anggota. Saldo minus diperbolehkan (beri peringatan, jangan blokir). Semua query di-scope ke household_id. Sync offline: updated_at + soft delete + client_id (UUID HP).

## Screenshots
Acuan visual tiap layar ada di folder `screenshots/` (light mode kecuali disebut dark). Gunakan ini sebagai referensi cepat tanpa menjalankan prototipe:

| File | Layar |
|---|---|
| `01-app-lock.png` | App Lock (PIN + biometrik) |
| `02-beranda.png` | Beranda / Home |
| `03-tambah-transaksi.png` | Tambah Transaksi (keypad) |
| `04-transaksi.png` | Daftar Transaksi |
| `05-detail-transaksi.png` | Detail Transaksi |
| `06-dompet.png` | Dompet |
| `07-detail-dompet.png` | Detail Dompet (kas bersama) |
| `08-profil.png` | Profil / Pengaturan |
| `09-kantong-tujuan.png` | Kantong Tujuan |
| `10-detail-kantong.png` | Detail Kantong |
| `11-utang-piutang.png` | Utang & Piutang |
| `12-detail-utang.png` | Detail Utang |
| `13-berulang.png` | Transaksi Berulang |
| `14-laporan.png` | Laporan (donut + cashflow) |
| `15-anggaran.png` | Anggaran |
| `16-beranda-dark.png` | Beranda — **dark mode** |
| `17-laporan-dark.png` | Laporan — **dark mode** |

## Assets
- **Font:** Plus Jakarta Sans (Google Fonts) — tambahkan ke `pubspec.yaml`.
- **Ikon:** set garis custom (lihat `app/icons.jsx` untuk daftar nama & makna). Di Flutter gunakan **Lucide** (`lucide_icons`) atau Material Icons outline yang setara. Tidak ada file gambar; semua ikon vektor.
- **Imagery:** belum ada foto/ilustrasi; foto struk = placeholder (fitur upload nanti).
- **Logo/brand:** belum ada logo final — saat ini brand mark = rounded square emerald + ikon dompet. Ganti dengan logo resmi bila tersedia.

## Files (di dalam bundel & proyek)
- `DuitKita.html` — entry; memuat semua skrip (urutan penting).
- `app/styles.css` — **design tokens** (light/dark), font, util, keyframes. **Sumber kebenaran warna/spacing.**
- `app/data.jsx` — data contoh + helper format Rupiah/tanggal (Bahasa Indonesia). Lihat `fmtRp`, grouping `Rp1.500.000`.
- `app/icons.jsx` — daftar ikon outline (nama → path).
- `app/ui.jsx` — primitives: Avatar, ScopeBadge, CatIcon, Sheet, TopBar, Segmented; lookup memberOf/walletOf/catOf; `txMeta` (warna/label per jenis).
- `app/components.jsx` — TxRow (baris transaksi + badge pencatat), MoneyText, ProgressBar, ProgressRing, AmountSheet, EmptyState.
- `app/frame.jsx` — PhoneFrame, StatusBar, BottomNav (struktur nav 5-slot + FAB).
- `app/screens-home.jsx` · `screens-add.jsx` · `screens-tx.jsx` · `screens-wallet.jsx` · `screens-auth.jsx` · `screens-profile.jsx` · `screens-extra.jsx` (Budget+Notif) · `screens-goals.jsx` · `screens-debt.jsx` · `screens-more.jsx` (Recurring+Laporan) · `screens-forms.jsx` (form tambah).
- `app/App.jsx` — orkestrator: state (transaksi/goals/debts/recurrings/saldo), navigasi stack+tab, handler mutasi saldo, Tweaks (dark/aksen/layar awal).
- `tweaks-panel.jsx` — panel kontrol prototipe (abaikan untuk implementasi produksi).

> **Cara menjalankan prototipe:** buka `DuitKita.html` di browser. Mulai dari App Lock — tap **ikon sidik jari** atau ketik 6 digit apa saja untuk masuk.
