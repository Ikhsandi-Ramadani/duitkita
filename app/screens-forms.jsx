// screens-forms.jsx — add forms for Goal / Debt / Recurring
// Exposes: AddGoalSheet, AddDebtSheet, AddRecurringSheet, RupiahInput, FormField, ChipRow

function addMonths(n) {
  const d = new Date('2026-06-11T09:30:00');
  d.setMonth(d.getMonth() + n);
  return d.toISOString();
}
function addDays(n) {
  const d = new Date('2026-06-11T09:30:00');
  d.setDate(d.getDate() + n);
  return d.toISOString();
}

function RupiahInput({ value, onChange, accent = 'var(--primary)' }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 4, height: 56, borderRadius: 14, background: 'var(--surface-2)', border: '1px solid var(--border-2)', padding: '0 16px' }}>
      <span className="num" style={{ fontSize: 20, fontWeight: 700, color: value ? accent : 'var(--text-3)' }}>Rp</span>
      <input inputMode="numeric" value={value ? value.toLocaleString('id-ID') : ''} placeholder="0"
        onChange={e => { const n = parseInt(e.target.value.replace(/\D/g, ''), 10) || 0; onChange(Math.min(n, 1e11)); }}
        className="num" style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontSize: 22, fontWeight: 800, color: value ? accent : 'var(--text-3)', letterSpacing: '-0.02em', minWidth: 0 }} />
    </div>
  );
}

function FormField({ label, children, hint }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-2)', marginBottom: 8 }}>{label}</div>
      {children}
      {hint && <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 6 }}>{hint}</div>}
    </div>
  );
}

function TextInput({ value, onChange, placeholder, icon }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 50, borderRadius: 14, background: 'var(--surface-2)', border: '1px solid var(--border-2)', padding: '0 14px' }}>
      {icon && <Icon name={icon} size={18} style={{ color: 'var(--text-3)' }} />}
      <input value={value} onChange={e => onChange(e.target.value)} placeholder={placeholder} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontSize: 15, color: 'var(--text)', minWidth: 0 }} />
    </div>
  );
}

// horizontal selectable chip row
function ChipRow({ options, value, onChange }) {
  return (
    <div className="dk-scroll" style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 2 }}>
      {options.map(o => {
        const on = o.value === value;
        return (
          <button key={o.value} className="tap" onClick={() => onChange(o.value)} style={{
            display: 'inline-flex', alignItems: 'center', gap: 7, padding: '10px 14px', borderRadius: 12, flexShrink: 0,
            fontSize: 13.5, fontWeight: 600, whiteSpace: 'nowrap',
            background: on ? 'var(--primary)' : 'var(--surface-2)', color: on ? 'var(--on-primary)' : 'var(--text-2)',
            border: '1px solid ' + (on ? 'var(--primary)' : 'transparent'),
          }}>{o.icon && <Icon name={o.icon} size={16} strokeWidth={2} />}{o.label}</button>
        );
      })}
    </div>
  );
}

function SaveButton({ disabled, onClick, label = 'Simpan', accent = 'var(--primary)' }) {
  return (
    <button className="tap" onClick={onClick} disabled={disabled} style={{
      width: '100%', height: 54, borderRadius: 16, marginTop: 6,
      background: disabled ? 'var(--surface-2)' : accent, color: disabled ? 'var(--text-3)' : '#fff',
      fontSize: 16, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    }}><Icon name="check" size={20} strokeWidth={2.4} /> {label}</button>
  );
}

const GOAL_ICONS = ['target', 'shield', 'flag', 'gift', 'book', 'ewallet', 'piggy', 'health'];

// ── Add Goal ──
function AddGoalSheet({ open, onClose, onSave }) {
  const ME = window.DK_DATA.ME;
  const [name, setName] = React.useState('');
  const [target, setTarget] = React.useState(0);
  const [months, setMonths] = React.useState(6);
  const [scope, setScope] = React.useState('family');
  const [wallet, setWallet] = React.useState('w7');
  const [icon, setIcon] = React.useState('target');
  React.useEffect(() => { if (open) { setName(''); setTarget(0); setMonths(6); setScope('family'); setWallet('w7'); setIcon('target'); } }, [open]);

  const walletOpts = window.DK_DATA.wallets
    .filter(w => scope === 'family' ? w.scope === 'shared' : (w.scope === 'personal' && w.owner === ME))
    .map(w => ({ value: w.id, label: w.name }));
  React.useEffect(() => { if (walletOpts.length && !walletOpts.find(o => o.value === wallet)) setWallet(walletOpts[0].value); }, [scope]);

  const valid = name.trim() && target > 0 && wallet;
  const save = () => valid && onSave({
    id: 'g' + Date.now(), name: name.trim(), scope, owner: scope === 'personal' ? ME : null,
    target, current: 0, date: addMonths(months), wallet, icon, hue: 162 + (GOAL_ICONS.indexOf(icon) * 30) % 200,
  });

  return (
    <Sheet open={open} onClose={onClose} title="Kantong Tujuan Baru" full>
      <div style={{ padding: '8px 22px 28px' }}>
        <FormField label="Nama tujuan"><TextInput value={name} onChange={setName} placeholder="Mis. Dana Darurat, Liburan…" icon="flag" /></FormField>
        <FormField label="Target dana"><RupiahInput value={target} onChange={setTarget} /></FormField>
        <FormField label="Jangka waktu">
          <ChipRow value={months} onChange={setMonths} options={[{ value: 3, label: '3 bulan' }, { value: 6, label: '6 bulan' }, { value: 12, label: '1 tahun' }, { value: 24, label: '2 tahun' }]} />
        </FormField>
        <FormField label="Jenis kantong">
          <Segmented value={scope} onChange={setScope} options={[{ value: 'family', label: 'Bersama' }, { value: 'personal', label: 'Pribadi' }]} />
        </FormField>
        <FormField label="Disimpan di dompet"><ChipRow value={wallet} onChange={setWallet} options={walletOpts} /></FormField>
        <FormField label="Ikon">
          <div style={{ display: 'flex', gap: 9, flexWrap: 'wrap' }}>
            {GOAL_ICONS.map(ic => (
              <button key={ic} className="tap" onClick={() => setIcon(ic)} style={{ width: 44, height: 44, borderRadius: 13, display: 'flex', alignItems: 'center', justifyContent: 'center', background: icon === ic ? 'var(--primary)' : 'var(--surface-2)', color: icon === ic ? '#fff' : 'var(--text-2)' }}><Icon name={ic} size={21} /></button>
            ))}
          </div>
        </FormField>
        <SaveButton disabled={!valid} onClick={save} label="Buat Kantong" />
      </div>
    </Sheet>
  );
}

// ── Add Debt ──
function AddDebtSheet({ open, onClose, onSave }) {
  const ME = window.DK_DATA.ME;
  const [type, setType] = React.useState('payable');
  const [party, setParty] = React.useState('');
  const [amount, setAmount] = React.useState(0);
  const [days, setDays] = React.useState(30);
  const [scope, setScope] = React.useState('family');
  const [note, setNote] = React.useState('');
  const [wallet, setWallet] = React.useState('w7');
  React.useEffect(() => { if (open) { setType('payable'); setParty(''); setAmount(0); setDays(30); setScope('family'); setNote(''); setWallet('w7'); } }, [open]);

  const walletOpts = window.DK_DATA.wallets
    .filter(w => scope === 'family' ? w.scope === 'shared' : (w.scope === 'personal' && w.owner === ME))
    .map(w => ({ value: w.id, label: w.name }));
  React.useEffect(() => { if (walletOpts.length && !walletOpts.find(o => o.value === wallet)) setWallet(walletOpts[0].value); }, [scope]);

  const accent = type === 'payable' ? 'var(--expense)' : 'var(--income)';
  const valid = party.trim() && amount > 0;
  const save = () => valid && onSave({
    id: 'd' + Date.now(), type, party: party.trim(), amount, paid: 0,
    date: new Date('2026-06-11T09:30:00').toISOString(), due: addDays(days),
    scope, owner: scope === 'personal' ? ME : null, note: note.trim() || (type === 'payable' ? 'Utang' : 'Piutang'), wallet,
  });

  return (
    <Sheet open={open} onClose={onClose} title="Catat Utang / Piutang" full>
      <div style={{ padding: '8px 22px 28px' }}>
        <FormField label="Jenis">
          <Segmented value={type} onChange={setType} options={[{ value: 'payable', label: 'Utang (saya pinjam)' }, { value: 'receivable', label: 'Piutang' }]} />
        </FormField>
        <FormField label={type === 'payable' ? 'Pinjam dari' : 'Dipinjam oleh'}><TextInput value={party} onChange={setParty} placeholder="Nama orang / lembaga" icon="user" /></FormField>
        <FormField label="Jumlah"><RupiahInput value={amount} onChange={setAmount} accent={accent} /></FormField>
        <FormField label="Jatuh tempo">
          <ChipRow value={days} onChange={setDays} options={[{ value: 7, label: '1 minggu' }, { value: 14, label: '2 minggu' }, { value: 30, label: '1 bulan' }, { value: 90, label: '3 bulan' }]} />
        </FormField>
        <FormField label="Milik">
          <Segmented value={scope} onChange={setScope} options={[{ value: 'family', label: 'Bersama' }, { value: 'personal', label: 'Pribadi' }]} />
        </FormField>
        <FormField label="Dompet terkait" hint="Tempat uang keluar/masuk saat dibayar."><ChipRow value={wallet} onChange={setWallet} options={walletOpts} /></FormField>
        <FormField label="Catatan (opsional)"><TextInput value={note} onChange={setNote} placeholder="Keterangan singkat" icon="note" /></FormField>
        <SaveButton disabled={!valid} onClick={save} label="Simpan" accent={accent} />
      </div>
    </Sheet>
  );
}

// ── Add Recurring ──
function AddRecurringSheet({ open, onClose, onSave }) {
  const ME = window.DK_DATA.ME;
  const [kind, setKind] = React.useState('expense');
  const [note, setNote] = React.useState('');
  const [amount, setAmount] = React.useState(0);
  const [cat, setCat] = React.useState('tagihan');
  const [wallet, setWallet] = React.useState('w6');
  const [freq, setFreq] = React.useState('Bulanan');
  React.useEffect(() => { if (open) { setKind('expense'); setNote(''); setAmount(0); setCat('tagihan'); setWallet('w6'); setFreq('Bulanan'); } }, [open]);

  const catOpts = window.DK_DATA.categories.filter(c => c.kind === kind).map(c => ({ value: c.key, label: c.name, icon: c.icon }));
  React.useEffect(() => { const def = kind === 'income' ? 'gaji' : 'tagihan'; setCat(def); }, [kind]);
  const walletOpts = window.DK_DATA.wallets.map(w => ({ value: w.id, label: w.name }));
  const accent = kind === 'income' ? 'var(--income)' : 'var(--expense)';
  const valid = note.trim() && amount > 0;
  const save = () => valid && onSave({
    id: 'r' + Date.now(), kind, cat, wallet, amount, freq, next: addMonths(1), auto: false, by: ME, note: note.trim(),
  });

  return (
    <Sheet open={open} onClose={onClose} title="Template Berulang Baru" full>
      <div style={{ padding: '8px 22px 28px' }}>
        <FormField label="Jenis">
          <Segmented value={kind} onChange={setKind} options={[{ value: 'expense', label: 'Pengeluaran' }, { value: 'income', label: 'Pemasukan' }]} />
        </FormField>
        <FormField label="Nama"><TextInput value={note} onChange={setNote} placeholder="Mis. Langganan Netflix, Gaji…" icon="repeat" /></FormField>
        <FormField label="Jumlah"><RupiahInput value={amount} onChange={setAmount} accent={accent} /></FormField>
        <FormField label="Kategori"><ChipRow value={cat} onChange={setCat} options={catOpts} /></FormField>
        <FormField label="Dompet"><ChipRow value={wallet} onChange={setWallet} options={walletOpts} /></FormField>
        <FormField label="Frekuensi">
          <Segmented value={freq} onChange={setFreq} options={[{ value: 'Harian', label: 'Harian' }, { value: 'Mingguan', label: 'Mingguan' }, { value: 'Bulanan', label: 'Bulanan' }]} />
        </FormField>
        <SaveButton disabled={!valid} onClick={save} label="Buat Template" accent={accent} />
      </div>
    </Sheet>
  );
}

Object.assign(window, { AddGoalSheet, AddDebtSheet, AddRecurringSheet, RupiahInput, FormField, ChipRow, TextInput, SaveButton });
