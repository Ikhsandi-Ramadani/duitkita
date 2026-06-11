// screens-add.jsx — Tambah Transaksi (fast entry flow)
// Exposes: AddTransaction

const TYPE_OPTS = [
  { value: 'expense', label: 'Keluar', color: 'var(--expense)' },
  { value: 'income', label: 'Masuk', color: 'var(--income)' },
  { value: 'transfer', label: 'Transfer', color: 'var(--transfer)' },
  { value: 'adjustment', label: 'Sesuaikan', color: 'var(--adjust)' },
];

// ── Category picker sheet ──
function CategorySheet({ open, kind, onPick, onClose }) {
  const cats = window.DK_DATA.categories.filter(c => c.kind === kind);
  return (
    <Sheet open={open} onClose={onClose} title={kind === 'income' ? 'Pilih kategori pemasukan' : 'Pilih kategori'}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 14, padding: '12px 20px 30px' }}>
        {cats.map(c => (
          <button key={c.key} className="tap" onClick={() => onPick(c.key)} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7,
          }}>
            <CatIcon catKey={c.key} size={54} iconSize={26} />
            <span style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-2)', textAlign: 'center', lineHeight: 1.2 }}>{c.name}</span>
          </button>
        ))}
      </div>
    </Sheet>
  );
}

// ── Wallet picker sheet ──
function WalletSheet({ open, title, exclude, onPick, onClose }) {
  const W = window.DK_DATA.wallets;
  const ME = window.DK_DATA.ME;
  const mine = W.filter(w => w.scope === 'personal' && w.owner === ME && w.id !== exclude);
  const shared = W.filter(w => w.scope === 'shared' && w.id !== exclude);
  const others = W.filter(w => w.scope === 'personal' && w.owner !== ME && w.id !== exclude);
  const Group = ({ label, list }) => list.length ? (
    <div style={{ marginBottom: 8 }}>
      <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-3)', padding: '10px 22px 6px' }}>{label}</div>
      {list.map(w => (
        <button key={w.id} className="tap" onClick={() => onPick(w.id)} style={{
          display: 'flex', alignItems: 'center', gap: 13, width: '100%', padding: '10px 22px', textAlign: 'left',
        }}>
          <span style={{ width: 42, height: 42, borderRadius: 13, background: 'var(--surface-2)', color: 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name={walletTypeIcon(w.type)} size={21} strokeWidth={1.9} />
          </span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 600 }}>{w.name}</div>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)' }}>{walletTypeLabel(w.type)} · {w.scope === 'shared' ? 'Bersama' : memberOf(w.owner).name}</div>
          </div>
          <span className="num" style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--text-2)' }}>Rp{w.balance.toLocaleString('id-ID')}</span>
        </button>
      ))}
    </div>
  ) : null;
  return (
    <Sheet open={open} onClose={onClose} title={title}>
      <div style={{ paddingBottom: 24 }}>
        <Group label="Dompet Saya" list={mine} />
        <Group label="Kas Bersama" list={shared} />
        <Group label="Dompet Anggota Lain" list={others} />
      </div>
    </Sheet>
  );
}

// detail row
function DetailRow({ icon, label, value, onClick, color, placeholder, last }) {
  return (
    <button className="tap" onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 13, width: '100%', padding: '13px 0', textAlign: 'left',
      borderBottom: last ? 'none' : '1px solid var(--border)',
    }}>
      <span style={{ color: 'var(--text-3)', display: 'flex' }}><Icon name={icon} size={20} strokeWidth={1.9} /></span>
      <span style={{ fontSize: 14.5, color: 'var(--text-2)', fontWeight: 500 }}>{label}</span>
      <span style={{ flex: 1 }}></span>
      <span style={{ fontSize: 14.5, fontWeight: 600, color: value ? (color || 'var(--text)') : 'var(--text-3)', display: 'flex', alignItems: 'center', gap: 4, maxWidth: 170, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
        {value || placeholder}<Icon name="chevronright" size={16} />
      </span>
    </button>
  );
}

function AddTransaction({ preset = {}, edit, onClose, onSave, dark }) {
  const ME = window.DK_DATA.ME;
  const [type, setType] = React.useState(edit ? edit.type : (preset.type || 'expense'));
  const [amount, setAmount] = React.useState(edit ? (edit.type === 'adjustment' ? walletOf(edit.wallet).balance : Math.abs(edit.amount)) : 0); // integer rupiah
  const [cat, setCat] = React.useState(edit ? edit.cat : null);
  const [wallet, setWallet] = React.useState(edit ? edit.wallet : (preset.wallet || (preset.type === 'income' ? 'w1' : 'w6')));
  const [target, setTarget] = React.useState(edit ? edit.target : (preset.target || (preset.type === 'transfer' ? 'w6' : null)));
  const [forWhom, setForWhom] = React.useState(edit ? edit.forWhom : null);
  const [note, setNote] = React.useState(edit ? edit.note : '');
  const [catOpen, setCatOpen] = React.useState(false);
  const [wSheet, setWSheet] = React.useState(null); // 'src' | 'dst'
  const [noteOpen, setNoteOpen] = React.useState(false);
  const meta = txMeta(type);

  // reset category when switching kind
  React.useEffect(() => {
    if (type === 'transfer' || type === 'adjustment') setCat(null);
  }, [type]);

  const press = (d) => setAmount(a => {
    const s = String(a) + d;
    if (s.length > 12) return a;
    return parseInt(s, 10) || 0;
  });
  const press000 = () => setAmount(a => { const n = a * 1000; return n > 1e11 ? a : n; });
  const back = () => setAmount(a => Math.floor(a / 10));

  const w = walletOf(wallet);
  const selisih = type === 'adjustment' && w ? amount - w.balance : 0;
  const canSave = amount > 0 && (type !== 'transfer' || (target && target !== wallet)) && (['transfer', 'adjustment'].includes(type) || cat);

  const save = () => {
    if (!canSave) return;
    const tx = {
      id: edit ? edit.id : 'tx' + Date.now(), type,
      amount: type === 'adjustment' ? selisih : amount,
      wallet, target: type === 'transfer' ? target : null,
      cat, date: edit ? edit.date : new Date('2026-06-11T09:30:00').toISOString(),
      note: note || (type === 'adjustment' ? 'Penyesuaian saldo' : ''),
      by: ME, forWhom, receipt: edit ? edit.receipt : false,
    };
    onSave(tx, edit);
  };

  const keypad = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'back'];

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 70, background: 'var(--app-bg)',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', padding: `${STATUS_H}px 12px 4px` }}>
        <button className="tap" onClick={onClose} aria-label="Tutup" style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text)' }}>
          <Icon name="x" size={24} strokeWidth={2} />
        </button>
        <div style={{ flex: 1, textAlign: 'center', fontSize: 17, fontWeight: 700, marginRight: 40 }}>{edit ? 'Edit Transaksi' : 'Catat Transaksi'}</div>
      </div>

      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '6px 20px 16px', display: 'flex', flexDirection: 'column' }}>
        {/* type selector */}
        <div style={{ display: 'flex', gap: 6, padding: 5, borderRadius: 15, background: 'var(--surface-2)', marginBottom: 18 }}>
          {TYPE_OPTS.map(o => {
            const on = o.value === type;
            return (
              <button key={o.value} className="tap" onClick={() => setType(o.value)} style={{
                flex: 1, padding: '9px 2px', borderRadius: 11, fontSize: 13, fontWeight: 700,
                color: on ? '#fff' : 'var(--text-2)',
                background: on ? o.color : 'transparent',
                boxShadow: on ? 'var(--shadow-sm)' : 'none',
              }}>{o.label}</button>
            );
          })}
        </div>

        {/* amount hero */}
        <div style={{ textAlign: 'center', padding: '14px 0 18px' }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-3)', marginBottom: 8 }}>
            {type === 'adjustment' ? 'Saldo sebenarnya' : 'Nominal'}
          </div>
          <div className="num" style={{ fontSize: 46, fontWeight: 800, color: amount ? meta.color : 'var(--text-3)', letterSpacing: '-0.03em', lineHeight: 1 }}>
            <span style={{ fontSize: 26, fontWeight: 700, opacity: 0.7 }}>Rp</span>{amount.toLocaleString('id-ID')}
          </div>
          {type === 'adjustment' && amount > 0 && (
            <div style={{ marginTop: 10, fontSize: 13.5, fontWeight: 600, color: selisih === 0 ? 'var(--text-3)' : (selisih > 0 ? 'var(--income)' : 'var(--expense)') }}>
              Selisih: {selisih > 0 ? '+' : selisih < 0 ? '−' : ''}Rp{Math.abs(selisih).toLocaleString('id-ID')} {selisih !== 0 ? `(${selisih > 0 ? 'tambah' : 'kurang'})` : ''}
            </div>
          )}
        </div>

        {/* details card */}
        <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 16 }}>
          {(type === 'income' || type === 'expense') && (
            <DetailRow icon="category" label="Kategori" placeholder="Pilih"
              value={cat ? catOf(cat).name : ''} onClick={() => setCatOpen(true)} />
          )}
          <DetailRow icon="wallet" label={type === 'transfer' ? 'Dari dompet' : 'Dompet'} placeholder="Pilih"
            value={w ? w.name : ''} onClick={() => setWSheet('src')} />
          {type === 'transfer' && (
            <DetailRow icon="transfer" label="Ke dompet" placeholder="Pilih"
              value={target ? walletOf(target).name : ''} color="var(--transfer)" onClick={() => setWSheet('dst')} />
          )}
          {(type === 'expense' || type === 'income') && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '13px 0', borderBottom: '1px solid var(--border)' }}>
              <span style={{ color: 'var(--text-3)', display: 'flex' }}><Icon name="users" size={20} strokeWidth={1.9} /></span>
              <span style={{ fontSize: 14.5, color: 'var(--text-2)', fontWeight: 500 }}>Untuk</span>
              <span style={{ flex: 1 }}></span>
              <div style={{ display: 'flex', gap: 6 }}>
                {window.DK_DATA.members.map(m => {
                  const on = forWhom === m.id;
                  return (
                    <button key={m.id} className="tap" onClick={() => setForWhom(on ? null : m.id)} style={{
                      borderRadius: '50%', padding: 0, opacity: on ? 1 : 0.4,
                      boxShadow: on ? '0 0 0 2.5px var(--primary)' : 'none',
                    }}><Avatar id={m.id} size={30} /></button>
                  );
                })}
              </div>
            </div>
          )}
          <DetailRow icon="note" label="Catatan" placeholder="Tambah"
            value={note} onClick={() => setNoteOpen(true)} last={type === 'transfer' || type === 'adjustment'} />
          {(type === 'expense' || type === 'income') && (
            <DetailRow icon="camera" label="Foto struk" placeholder="Opsional" value="" onClick={() => {}} last />
          )}
        </div>

        <div style={{ flex: 1 }}></div>

        {/* keypad */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8, marginBottom: 12 }}>
          {keypad.map(k => (
            <button key={k} className="tap" onClick={() => k === 'back' ? back() : k === '000' ? press000() : press(k)} style={{
              height: 52, borderRadius: 15, background: 'var(--surface)', border: '1px solid var(--border)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 22, fontWeight: 700, color: 'var(--text)', boxShadow: 'var(--shadow-sm)',
            }}>
              {k === 'back' ? <Icon name="backspace" size={24} strokeWidth={1.9} /> : <span className="num">{k}</span>}
            </button>
          ))}
        </div>

        <button className="tap" onClick={save} disabled={!canSave} style={{
          height: 56, borderRadius: 17, width: '100%',
          background: canSave ? meta.color : 'var(--surface-2)',
          color: canSave ? '#fff' : 'var(--text-3)',
          fontSize: 16.5, fontWeight: 700, boxShadow: canSave ? 'var(--shadow)' : 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          <Icon name="check" size={21} strokeWidth={2.4} /> Simpan
        </button>
      </div>

      <CategorySheet open={catOpen} kind={type === 'income' ? 'income' : 'expense'} onClose={() => setCatOpen(false)}
        onPick={(k) => { setCat(k); setCatOpen(false); }} />
      <WalletSheet open={wSheet === 'src'} title="Pilih dompet" exclude={wSheet === 'src' ? target : null}
        onClose={() => setWSheet(null)} onPick={(id) => { setWallet(id); setWSheet(null); }} />
      <WalletSheet open={wSheet === 'dst'} title="Pilih dompet tujuan" exclude={wallet}
        onClose={() => setWSheet(null)} onPick={(id) => { setTarget(id); setWSheet(null); }} />
      <NoteSheet open={noteOpen} value={note} onClose={() => setNoteOpen(false)} onSave={(v) => { setNote(v); setNoteOpen(false); }} />
    </div>
  );
}

// note input sheet
function NoteSheet({ open, value, onClose, onSave }) {
  const [v, setV] = React.useState(value || '');
  React.useEffect(() => { if (open) setV(value || ''); }, [open]);
  if (!open) return null;
  return (
    <Sheet open={open} onClose={onClose} title="Catatan">
      <div style={{ padding: '8px 20px 26px' }}>
        <textarea autoFocus value={v} onChange={e => setV(e.target.value)} placeholder="Mis. belanja mingguan, bensin mobil…" rows={3} style={{
          width: '100%', borderRadius: 14, border: '1px solid var(--border-2)', background: 'var(--surface-2)',
          padding: 14, fontSize: 15, color: 'var(--text)', resize: 'none', outline: 'none',
        }} />
        <button className="tap" onClick={() => onSave(v)} style={{
          marginTop: 14, width: '100%', height: 50, borderRadius: 15, background: 'var(--primary)', color: 'var(--on-primary)', fontSize: 15.5, fontWeight: 700,
        }}>Simpan catatan</button>
      </div>
    </Sheet>
  );
}

window.AddTransaction = AddTransaction;
