// screens-tx.jsx — Daftar Transaksi + Detail Transaksi
// Exposes: TxListScreen, TxDetailScreen

function FilterChip({ label, active, icon, onClick, hasDot }) {
  return (
    <button className="tap" onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6, padding: '8px 13px', borderRadius: 12,
      fontSize: 13, fontWeight: 600, whiteSpace: 'nowrap', flexShrink: 0,
      background: active ? 'var(--primary)' : 'var(--surface)',
      color: active ? 'var(--on-primary)' : 'var(--text-2)',
      border: '1px solid ' + (active ? 'var(--primary)' : 'var(--border)'),
    }}>
      {icon && <Icon name={icon} size={15} strokeWidth={2} />}
      {label}
      {hasDot && <span style={{ width: 6, height: 6, borderRadius: '50%', background: active ? '#fff' : 'var(--primary)' }}></span>}
    </button>
  );
}

function TxListScreen({ txns, openTx, dark }) {
  const [q, setQ] = React.useState('');
  const [typeF, setTypeF] = React.useState('all');
  const [memberF, setMemberF] = React.useState(null);
  const [memberSheet, setMemberSheet] = React.useState(false);

  const filtered = txns.filter(tx => {
    if (typeF !== 'all' && tx.type !== typeF) return false;
    if (memberF && tx.by !== memberF && tx.forWhom !== memberF) return false;
    if (q) {
      const c = tx.cat ? catOf(tx.cat).name : '';
      const hay = (tx.note + ' ' + c + ' ' + tx.amount).toLowerCase();
      if (!hay.includes(q.toLowerCase())) return false;
    }
    return true;
  });

  // group by day
  const groups = [];
  filtered.forEach(tx => {
    const key = relDay(tx.date);
    let g = groups.find(x => x.key === key);
    if (!g) { g = { key, items: [], net: 0 }; groups.push(g); }
    g.items.push(tx);
    if (tx.type === 'income') g.net += tx.amount;
    else if (tx.type === 'expense') g.net -= tx.amount;
  });

  const types = [
    { v: 'all', l: 'Semua' }, { v: 'expense', l: 'Keluar' }, { v: 'income', l: 'Masuk' },
    { v: 'transfer', l: 'Transfer' }, { v: 'adjustment', l: 'Penyesuaian' },
  ];
  const memName = memberF ? memberOf(memberF).name : null;

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ padding: `${STATUS_H + 8}px 20px 0`, flexShrink: 0 }}>
        <div style={{ fontSize: 24, fontWeight: 800, letterSpacing: '-0.02em', marginBottom: 14 }}>Transaksi</div>
        {/* search */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 14, padding: '0 14px', height: 46, marginBottom: 12 }}>
          <Icon name="search" size={19} style={{ color: 'var(--text-3)' }} />
          <input value={q} onChange={e => setQ(e.target.value)} placeholder="Cari catatan, kategori, nominal…" style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent', fontSize: 14.5, color: 'var(--text)',
          }} />
          {q && <button className="tap" onClick={() => setQ('')} style={{ color: 'var(--text-3)', display: 'flex' }}><Icon name="x" size={18} /></button>}
        </div>
      </div>

      {/* filter chips */}
      <div className="dk-scroll" style={{ display: 'flex', gap: 8, padding: '0 20px 12px', overflowX: 'auto', flexShrink: 0 }}>
        {types.map(t => <FilterChip key={t.v} label={t.l} active={typeF === t.v} onClick={() => setTypeF(t.v)} />)}
        <FilterChip label={memName || 'Anggota'} icon="user" active={!!memberF} onClick={() => setMemberSheet(true)} />
      </div>

      {/* list */}
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '0 20px 110px' }}>
        {groups.length === 0 && <EmptyState icon="search" title="Tidak ada transaksi" sub="Coba ubah kata kunci atau filter." />}
        {groups.map(g => (
          <div key={g.key} style={{ marginTop: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 2 }}>
              <span style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-2)' }}>{g.key}</span>
              {g.net !== 0 && (
                <span className="num" style={{ fontSize: 12.5, fontWeight: 700, color: g.net > 0 ? 'var(--income)' : 'var(--expense)' }}>
                  {g.net > 0 ? '+' : '−'}Rp{Math.abs(g.net).toLocaleString('id-ID')}
                </span>
              )}
            </div>
            <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
              {g.items.map((tx, i) => (
                <div key={tx.id} style={{ borderBottom: i < g.items.length - 1 ? '1px solid var(--border)' : 'none' }}>
                  <TxRow tx={tx} onClick={() => openTx(tx)} />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* member filter sheet */}
      <Sheet open={memberSheet} onClose={() => setMemberSheet(false)} title="Filter anggota">
        <div style={{ padding: '6px 14px 26px' }}>
          {[{ id: null, name: 'Semua anggota' }, ...window.DK_DATA.members].map(m => {
            const on = memberF === m.id;
            return (
              <button key={m.id || 'all'} className="tap" onClick={() => { setMemberF(m.id); setMemberSheet(false); }} style={{
                display: 'flex', alignItems: 'center', gap: 13, width: '100%', padding: '11px 8px', textAlign: 'left',
                background: on ? 'var(--primary-tint)' : 'transparent', borderRadius: 14,
              }}>
                {m.id ? <Avatar id={m.id} size={38} /> : <span style={{ width: 38, height: 38, borderRadius: '50%', background: 'var(--surface-2)', color: 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="users" size={20} /></span>}
                <span style={{ flex: 1, fontSize: 15.5, fontWeight: 600 }}>{m.name}{m.role === 'owner' ? ' · Owner' : ''}</span>
                {on && <Icon name="check" size={20} style={{ color: 'var(--primary)' }} strokeWidth={2.4} />}
              </button>
            );
          })}
        </div>
      </Sheet>
    </div>
  );
}

// ── Detail ──
function Field({ label, children, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, padding: '14px 0', borderBottom: last ? 'none' : '1px solid var(--border)' }}>
      <span style={{ fontSize: 14, color: 'var(--text-3)', fontWeight: 500, flexShrink: 0 }}>{label}</span>
      <span style={{ fontSize: 14.5, fontWeight: 600, textAlign: 'right' }}>{children}</span>
    </div>
  );
}

function TxDetailScreen({ tx, nav, onDelete, dark }) {
  const meta = txMeta(tx.type);
  const w = walletOf(tx.wallet);
  const tw = tx.target ? walletOf(tx.target) : null;
  const cat = tx.cat ? catOf(tx.cat) : null;
  const by = memberOf(tx.by);
  const forWhom = tx.forWhom ? memberOf(tx.forWhom) : null;
  const mine = tx.by === window.DK_DATA.ME;
  const [confirm, setConfirm] = React.useState(false);

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title="Detail Transaksi" onBack={nav.back} right={mine &&
          <button className="tap" onClick={() => nav.push('addEdit', { tx })} style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-2)' }}><Icon name="edit" size={20} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '8px 20px 40px' }}>
        {/* hero */}
        <div style={{ textAlign: 'center', padding: '14px 0 22px' }}>
          <div style={{ width: 64, height: 64, borderRadius: 22, margin: '0 auto 14px', background: meta.tint, color: meta.color, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name={cat ? cat.icon : meta.icon} size={32} strokeWidth={1.9} />
          </div>
          <div style={{ fontSize: 13.5, fontWeight: 600, color: meta.color, marginBottom: 6 }}>{cat ? cat.name : meta.label}</div>
          <div className="num" style={{ fontSize: 38, fontWeight: 800, color: 'var(--text)', letterSpacing: '-0.03em' }}>
            {meta.sign}<span style={{ fontSize: 22, opacity: 0.7 }}>Rp</span>{Math.abs(tx.amount).toLocaleString('id-ID')}
          </div>
          {tx.note && <div style={{ fontSize: 14.5, color: 'var(--text-2)', marginTop: 8 }}>{tx.note}</div>}
        </div>

        <div className="card" style={{ padding: '2px 17px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
          <Field label="Jenis"><span style={{ color: meta.color }}>{meta.label}</span></Field>
          {tx.type === 'transfer'
            ? <Field label="Dompet"><span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>{w.name} <Icon name="arrowright" size={15} style={{ color: 'var(--text-3)' }} /> {tw.name}</span></Field>
            : <Field label="Dompet">{w.name} <ScopeBadge scope={w.scope} /></Field>}
          <Field label="Tanggal">{dayLabel(tx.date)}</Field>
          <Field label="Waktu">{timeLabel(tx.date)} WIB</Field>
          <Field label="Dicatat oleh"><span style={{ display: 'inline-flex', alignItems: 'center', gap: 7 }}><Avatar id={by.id} size={24} /> {by.name}</span></Field>
          {forWhom && <Field label="Untuk"><span style={{ display: 'inline-flex', alignItems: 'center', gap: 7 }}><Avatar id={forWhom.id} size={24} /> {forWhom.name}</span></Field>}
          <Field label="Struk" last>{tx.receipt ? <span style={{ color: 'var(--primary)' }}>📎 Lihat foto</span> : <span style={{ color: 'var(--text-3)' }}>—</span>}</Field>
        </div>

        {/* ownership note / actions */}
        {mine ? (
          <div style={{ display: 'flex', gap: 12, marginTop: 22 }}>
            <button className="tap" onClick={() => nav.push('addEdit', { tx })} style={{ flex: 1, height: 52, borderRadius: 16, background: 'var(--surface)', border: '1px solid var(--border-2)', color: 'var(--text)', fontWeight: 700, fontSize: 15, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
              <Icon name="edit" size={19} /> Edit
            </button>
            <button className="tap" onClick={() => setConfirm(true)} style={{ flex: 1, height: 52, borderRadius: 16, background: 'var(--expense-tint)', color: 'var(--expense)', fontWeight: 700, fontSize: 15, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
              <Icon name="trash" size={19} /> Hapus
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginTop: 22, padding: '13px 15px', borderRadius: 14, background: 'var(--surface-2)', color: 'var(--text-3)' }}>
            <Icon name="info" size={19} />
            <span style={{ fontSize: 13, lineHeight: 1.4 }}>Hanya <b style={{ color: 'var(--text-2)' }}>{by.name}</b> yang dapat mengubah transaksi ini.</span>
          </div>
        )}
      </div>

      <Sheet open={confirm} onClose={() => setConfirm(false)} title="Hapus transaksi?">
        <div style={{ padding: '4px 22px 28px' }}>
          <p style={{ fontSize: 14.5, color: 'var(--text-2)', lineHeight: 1.5, marginTop: 0 }}>Transaksi ini akan dihapus dan saldo dompet disesuaikan kembali.</p>
          <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
            <button className="tap" onClick={() => setConfirm(false)} style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--surface-2)', color: 'var(--text)', fontWeight: 700, fontSize: 15 }}>Batal</button>
            <button className="tap" onClick={() => { setConfirm(false); onDelete(tx); }} style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--expense)', color: '#fff', fontWeight: 700, fontSize: 15 }}>Hapus</button>
          </div>
        </div>
      </Sheet>
    </div>
  );
}

Object.assign(window, { TxListScreen, TxDetailScreen });
