// data.jsx — DuitKita sample household data + money helpers
// Exposes to window: DK_DATA, fmtRp, fmtRpSigned, fmtShort, monthLabel, dayLabel, relDay

// ── Money formatting (Rupiah, Indonesian grouping: Rp1.500.000) ──
function fmtRp(n) {
  const neg = n < 0;
  const s = 'Rp' + Math.abs(Math.round(n)).toLocaleString('id-ID');
  return neg ? '−' + s : s;
}
// signed with explicit + / − for transaction rows
function fmtRpSigned(n, type) {
  const abs = 'Rp' + Math.abs(Math.round(n)).toLocaleString('id-ID');
  if (type === 'income') return '+' + abs;
  if (type === 'expense') return '−' + abs;
  return abs; // transfer / adjustment: neutral
}
// compact e.g. 1,5jt / 250rb
function fmtShort(n) {
  const a = Math.abs(n);
  if (a >= 1e9) return 'Rp' + (n / 1e9).toFixed(1).replace('.', ',') + 'M';
  if (a >= 1e6) return 'Rp' + (n / 1e6).toFixed(1).replace('.', ',') + 'jt';
  if (a >= 1e3) return 'Rp' + Math.round(n / 1e3) + 'rb';
  return 'Rp' + n;
}

const _ID_MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const _ID_MONTHS_LONG = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
const _ID_DAYS = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

const TODAY = new Date('2026-06-11T09:30:00');
function dateObj(iso) { return new Date(iso); }
function monthLabel(d) { return _ID_MONTHS_LONG[d.getMonth()] + ' ' + d.getFullYear(); }
function dayLabel(iso) {
  const d = dateObj(iso);
  return _ID_DAYS[d.getDay()] + ', ' + d.getDate() + ' ' + _ID_MONTHS[d.getMonth()] + ' ' + d.getFullYear();
}
function timeLabel(iso) {
  const d = dateObj(iso);
  return String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0');
}
// "Hari ini" / "Kemarin" / full date
function relDay(iso) {
  const d = dateObj(iso);
  const a = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const b = new Date(TODAY.getFullYear(), TODAY.getMonth(), TODAY.getDate());
  const diff = Math.round((b - a) / 86400000);
  if (diff === 0) return 'Hari ini';
  if (diff === 1) return 'Kemarin';
  return _ID_DAYS[d.getDay()] + ', ' + d.getDate() + ' ' + _ID_MONTHS[d.getMonth()];
}

// ── Members ──
const members = [
  { id: 'u1', name: 'Budi', full: 'Budi Pratama', role: 'owner', init: 'B', hue: 162, email: 'budi@keluarga.id' },
  { id: 'u2', name: 'Sari', full: 'Sari Pratama', role: 'member', init: 'S', hue: 340, email: 'sari@keluarga.id' },
  { id: 'u3', name: 'Rian', full: 'Rian Pratama', role: 'member', init: 'R', hue: 255, email: 'rian@keluarga.id' },
];
const ME = 'u1'; // logged-in user

// ── Wallets ──  scope: personal|shared  type: cash|bank|ewallet
const wallets = [
  { id: 'w1', name: 'BCA Budi', scope: 'personal', owner: 'u1', type: 'bank', balance: 18450000 },
  { id: 'w2', name: 'Tunai Budi', scope: 'personal', owner: 'u1', type: 'cash', balance: 620000 },
  { id: 'w3', name: 'GoPay Sari', scope: 'personal', owner: 'u2', type: 'ewallet', balance: 845000 },
  { id: 'w4', name: 'Tunai Sari', scope: 'personal', owner: 'u2', type: 'cash', balance: 310000 },
  { id: 'w5', name: 'OVO Rian', scope: 'personal', owner: 'u3', type: 'ewallet', balance: 175000 },
  { id: 'w6', name: 'Kas Belanja', scope: 'shared', owner: null, type: 'cash', balance: 2380000 },
  { id: 'w7', name: 'Dana Keluarga', scope: 'shared', owner: null, type: 'bank', balance: 12500000 },
];

// ── Categories ── icon = key into ICONS; kind income|expense
const categories = [
  { key: 'makan', name: 'Makanan', icon: 'utensils', kind: 'expense', hue: 24 },
  { key: 'transport', name: 'Transport', icon: 'car', kind: 'expense', hue: 210 },
  { key: 'bensin', name: 'Bensin', icon: 'fuel', kind: 'expense', hue: 30 },
  { key: 'tagihan', name: 'Tagihan', icon: 'receipt', kind: 'expense', hue: 265 },
  { key: 'pulsa', name: 'Pulsa & Data', icon: 'signal', kind: 'expense', hue: 190 },
  { key: 'belanja', name: 'Belanja', icon: 'bag', kind: 'expense', hue: 320 },
  { key: 'kesehatan', name: 'Kesehatan', icon: 'health', kind: 'expense', hue: 0 },
  { key: 'pendidikan', name: 'Pendidikan', icon: 'book', kind: 'expense', hue: 230 },
  { key: 'hiburan', name: 'Hiburan', icon: 'film', kind: 'expense', hue: 290 },
  { key: 'arisan', name: 'Arisan', icon: 'users', kind: 'expense', hue: 130 },
  { key: 'zakat', name: 'Zakat & Sedekah', icon: 'handheart', kind: 'expense', hue: 160 },
  { key: 'lainnya_e', name: 'Lainnya', icon: 'dots', kind: 'expense', hue: 200 },
  { key: 'gaji', name: 'Gaji', icon: 'briefcase', kind: 'income', hue: 162 },
  { key: 'bonus', name: 'Bonus / THR', icon: 'gift', kind: 'income', hue: 145 },
  { key: 'lainnya_i', name: 'Lainnya', icon: 'dots', kind: 'income', hue: 175 },
];

// ── Budget (per category, this month, family scope) ──
const budgets = [
  { cat: 'makan', amount: 3500000, scope: 'family' },
  { cat: 'transport', amount: 1200000, scope: 'family' },
  { cat: 'belanja', amount: 2000000, scope: 'family' },
  { cat: 'tagihan', amount: 1800000, scope: 'family' },
  { cat: 'hiburan', amount: 800000, scope: 'family' },
];

// ── Transactions ── newest first; type income|expense|transfer|adjustment
let _tid = 100;
const tid = () => 'tx' + (++_tid);
const transactions = [
  { id: tid(), type: 'expense', amount: 87000, wallet: 'w6', cat: 'makan', date: '2026-06-11T08:15:00', note: 'Sarapan + kopi', by: 'u2', forWhom: 'u3', receipt: true },
  { id: tid(), type: 'expense', amount: 250000, wallet: 'w6', cat: 'belanja', date: '2026-06-11T07:40:00', note: 'Belanja mingguan Superindo', by: 'u2', forWhom: null, receipt: true },
  { id: tid(), type: 'transfer', amount: 2000000, wallet: 'w1', target: 'w6', date: '2026-06-10T20:10:00', note: 'Isi kas belanja Juni', by: 'u1', forWhom: null },
  { id: tid(), type: 'expense', amount: 45000, wallet: 'w5', cat: 'transport', date: '2026-06-10T17:30:00', note: 'Gojek pulang sekolah', by: 'u3', forWhom: 'u3' },
  { id: tid(), type: 'expense', amount: 320000, wallet: 'w1', cat: 'tagihan', date: '2026-06-10T10:00:00', note: 'Listrik PLN', by: 'u1', forWhom: null },
  { id: tid(), type: 'income', amount: 14500000, wallet: 'w1', cat: 'gaji', date: '2026-06-09T09:00:00', note: 'Gaji bulan Juni', by: 'u1', forWhom: null },
  { id: tid(), type: 'expense', amount: 135000, wallet: 'w3', cat: 'makan', date: '2026-06-09T12:30:00', note: 'Makan siang kantor', by: 'u2', forWhom: 'u2' },
  { id: tid(), type: 'expense', amount: 50000, wallet: 'w3', cat: 'pulsa', date: '2026-06-08T19:00:00', note: 'Paket data Telkomsel', by: 'u2', forWhom: 'u3' },
  { id: tid(), type: 'transfer', amount: 500000, wallet: 'w1', target: 'w3', date: '2026-06-08T08:00:00', note: 'Uang belanja buat Sari', by: 'u1', forWhom: null },
  { id: tid(), type: 'expense', amount: 180000, wallet: 'w6', cat: 'bensin', date: '2026-06-07T16:20:00', note: 'Pertamax mobil', by: 'u1', forWhom: null, receipt: true },
  { id: tid(), type: 'adjustment', amount: -25000, wallet: 'w2', date: '2026-06-07T21:00:00', note: 'Koreksi saldo tunai', by: 'u1', forWhom: null },
  { id: tid(), type: 'expense', amount: 420000, wallet: 'w7', cat: 'pendidikan', date: '2026-06-06T14:00:00', note: 'Les Rian bulan Juni', by: 'u1', forWhom: 'u3' },
  { id: tid(), type: 'expense', amount: 95000, wallet: 'w4', cat: 'hiburan', date: '2026-06-05T20:30:00', note: 'Nonton bioskop', by: 'u2', forWhom: 'u2' },
  { id: tid(), type: 'income', amount: 3200000, wallet: 'w3', cat: 'lainnya_i', date: '2026-06-05T11:00:00', note: 'Hasil jualan online', by: 'u2', forWhom: null },
  { id: tid(), type: 'expense', amount: 65000, wallet: 'w6', cat: 'makan', date: '2026-06-04T18:45:00', note: 'Ayam geprek keluarga', by: 'u3', forWhom: null },
  { id: tid(), type: 'transfer', amount: 1000000, wallet: 'w1', target: 'w7', date: '2026-06-03T09:30:00', note: 'Nabung dana keluarga', by: 'u1', forWhom: null },
  { id: tid(), type: 'expense', amount: 150000, wallet: 'w7', cat: 'arisan', date: '2026-06-02T19:00:00', note: 'Arisan RT', by: 'u2', forWhom: null },
  { id: tid(), type: 'expense', amount: 230000, wallet: 'w6', cat: 'tagihan', date: '2026-06-01T08:00:00', note: 'Internet IndiHome', by: 'u1', forWhom: null },
];

window.DK_DATA = { members, wallets, categories, budgets, transactions, ME, TODAY };

// ── Savings goals / Kantong Tujuan ──  scope: family|personal
const goals = [
  { id: 'g1', name: 'Dana Darurat Keluarga', scope: 'family', owner: null, target: 20000000, current: 12500000, date: '2026-12-31', wallet: 'w7', icon: 'shield', hue: 162 },
  { id: 'g2', name: 'Liburan Lebaran', scope: 'family', owner: null, target: 15000000, current: 4500000, date: '2027-03-01', wallet: 'w7', icon: 'flag', hue: 30 },
  { id: 'g3', name: 'Tabungan HP Sari', scope: 'personal', owner: 'u2', target: 5000000, current: 2100000, date: '2026-09-30', wallet: 'w3', icon: 'ewallet', hue: 340 },
  { id: 'g4', name: 'Pendidikan Rian', scope: 'personal', owner: 'u1', target: 30000000, current: 18000000, date: '2028-06-01', wallet: 'w1', icon: 'book', hue: 230 },
];

// ── Debts / Utang & Piutang ──  type: payable(utang)|receivable(piutang)
const debts = [
  { id: 'd1', type: 'payable', party: 'Adira Finance', amount: 12000000, paid: 7000000, date: '2026-01-10', due: '2026-06-25', scope: 'family', owner: null, note: 'Cicilan motor', wallet: 'w7' },
  { id: 'd2', type: 'payable', party: 'Pak Hasan', amount: 2000000, paid: 0, date: '2026-05-30', due: '2026-06-20', scope: 'personal', owner: 'u1', note: 'Pinjam sementara', wallet: 'w1' },
  { id: 'd3', type: 'receivable', party: 'Tante Lia', amount: 1500000, paid: 500000, date: '2026-04-12', due: '2026-07-10', scope: 'family', owner: null, note: 'Pinjam buat usaha', wallet: 'w7' },
  { id: 'd4', type: 'receivable', party: 'Rian', amount: 300000, paid: 0, date: '2026-06-03', due: '2026-06-15', scope: 'personal', owner: 'u2', note: 'Talangin beli buku', wallet: 'w3' },
];

// ── Recurring templates ──
const recurrings = [
  { id: 'r1', kind: 'income', cat: 'gaji', wallet: 'w1', amount: 14500000, freq: 'Bulanan', next: '2026-07-01', auto: true, by: 'u1', note: 'Gaji bulanan' },
  { id: 'r2', kind: 'expense', cat: 'tagihan', wallet: 'w6', amount: 230000, freq: 'Bulanan', next: '2026-07-01', auto: true, by: 'u1', note: 'Internet IndiHome' },
  { id: 'r3', kind: 'expense', cat: 'tagihan', wallet: 'w1', amount: 320000, freq: 'Bulanan', next: '2026-07-05', auto: false, by: 'u1', note: 'Listrik PLN' },
  { id: 'r4', kind: 'expense', cat: 'pulsa', wallet: 'w3', amount: 100000, freq: 'Bulanan', next: '2026-07-03', auto: false, by: 'u2', note: 'Paket data' },
  { id: 'r5', kind: 'expense', cat: 'pendidikan', wallet: 'w7', amount: 420000, freq: 'Bulanan', next: '2026-07-06', auto: true, by: 'u1', note: 'Les Rian' },
];

// ── Monthly cashflow (for Laporan) ──
const cashflow = [
  { m: 'Jan', income: 16500000, expense: 9800000 },
  { m: 'Feb', income: 17200000, expense: 10500000 },
  { m: 'Mar', income: 16800000, expense: 11200000 },
  { m: 'Apr', income: 18900000, expense: 9600000 },
  { m: 'Mei', income: 17000000, expense: 12800000 },
  { m: 'Jun', income: 17700000, expense: 2027000 },
];

Object.assign(window.DK_DATA, { goals, debts, recurrings, cashflow });
Object.assign(window, { fmtRp, fmtRpSigned, fmtShort, monthLabel, dayLabel, timeLabel, relDay });
