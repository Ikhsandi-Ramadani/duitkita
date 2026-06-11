// screens-goals.jsx — Kantong Tujuan / Target Tabungan
// Exposes: GoalsScreen

function _dateShort(iso) {
  const d = new Date(iso);
  const M = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return M[d.getMonth()] + ' ' + d.getFullYear();
}

function GoalCard({ g, onSisih, onOpen }) {
  const pct = Math.round((g.current / g.target) * 100);
  const sisa = Math.max(0, g.target - g.current);
  const done = g.current >= g.target;
  const color = `hsl(${g.hue} 55% 45%)`;
  const tint = window.__dkDark ? `hsl(${g.hue} 30% 20%)` : `hsl(${g.hue} 48% 94%)`;
  return (
    <div className="card tap" onClick={() => onOpen(g)} style={{ padding: 16, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 12, cursor: 'pointer' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
        <ProgressRing size={56} stroke={6} value={g.current} max={g.target} color={done ? 'var(--income)' : color} track="var(--surface-2)">
          <span style={{ color: done ? 'var(--income)' : 'var(--text)' }}>{pct}%</span>
        </ProgressRing>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
            <span style={{ width: 26, height: 26, borderRadius: 9, background: tint, color, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={g.icon} size={15} strokeWidth={2} /></span>
            <span style={{ fontSize: 15.5, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{g.name}</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6 }}>
            <ScopeBadge scope={g.scope === 'family' ? 'shared' : 'personal'} />
            <span style={{ fontSize: 12, color: 'var(--text-3)', display: 'inline-flex', alignItems: 'center', gap: 3 }}><Icon name="flag" size={13} /> {_dateShort(g.date)}</span>
          </div>
        </div>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
        <MoneyText value={g.current} size={21} color={done ? 'var(--income)' : 'var(--text)'} />
        <span className="num" style={{ fontSize: 13, color: 'var(--text-3)', fontWeight: 600 }}>/ Rp{g.target.toLocaleString('id-ID')}</span>
      </div>
      <ProgressBar value={g.current} max={g.target} color={done ? 'var(--income)' : color} h={8} />
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 13 }}>
        <span style={{ fontSize: 12.5, color: 'var(--text-2)' }}>{done ? '🎉 Target tercapai!' : <span className="num">Kurang Rp{sisa.toLocaleString('id-ID')}</span>}</span>
        <button className="tap" onClick={(e) => { e.stopPropagation(); onSisih(g); }} disabled={done} style={{
          display: 'inline-flex', alignItems: 'center', gap: 6, padding: '9px 15px', borderRadius: 12,
          background: done ? 'var(--surface-2)' : 'var(--primary-tint)', color: done ? 'var(--text-3)' : 'var(--primary)', fontWeight: 700, fontSize: 13.5,
        }}><Icon name="plus" size={15} strokeWidth={2.4} /> Sisihkan dana</button>
      </div>
    </div>
  );
}

function GoalsScreen({ goals, nav, onAddToGoal, onAdd, showToast }) {
  const ME = window.DK_DATA.ME;
  const [sel, setSel] = React.useState(null); // goal being funded
  const [wallet, setWallet] = React.useState(null);
  const [wSheet, setWSheet] = React.useState(false);

  const family = goals.filter(g => g.scope === 'family');
  const mine = goals.filter(g => g.scope === 'personal' && g.owner === ME);
  const others = goals.filter(g => g.scope === 'personal' && g.owner !== ME);

  const totalCurrent = goals.reduce((a, g) => a + g.current, 0);
  const totalTarget = goals.reduce((a, g) => a + g.target, 0);

  const openSisih = (g) => { setSel(g); setWallet(g.wallet); };
  const confirm = (amt) => {
    onAddToGoal(sel.id, amt, wallet);
    showToast('Berhasil menyisihkan ' + fmtShort(amt));
    setSel(null);
  };

  const Group = ({ title, list }) => list.length ? (
    <div style={{ marginTop: 18 }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-3)', marginBottom: 10 }}>{title}</div>
      {list.map(g => <GoalCard key={g.id} g={g} onSisih={openSisih} onOpen={(gg) => nav.push('goalDetail', { id: gg.id })} />)}
    </div>
  ) : null;

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title="Kantong Tujuan" onBack={nav.back} right={
          <button className="tap" onClick={onAdd} style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' }}><Icon name="plus" size={23} strokeWidth={2.2} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        <div style={{ borderRadius: 20, padding: 18, background: 'linear-gradient(158deg, var(--primary-600), var(--primary-700))', color: '#fff' }}>
          <div style={{ fontSize: 12.5, fontWeight: 600, opacity: 0.85 }}>Total terkumpul di semua kantong</div>
          <div className="num" style={{ fontSize: 29, fontWeight: 800, letterSpacing: '-0.02em', margin: '5px 0 10px' }}>Rp{totalCurrent.toLocaleString('id-ID')}</div>
          <div style={{ height: 7, borderRadius: 7, background: 'rgba(255,255,255,0.25)', overflow: 'hidden' }}>
            <div style={{ height: '100%', width: Math.round(totalCurrent / totalTarget * 100) + '%', background: '#fff', borderRadius: 7 }}></div>
          </div>
          <div className="num" style={{ fontSize: 12, opacity: 0.85, marginTop: 8 }}>dari total target Rp{totalTarget.toLocaleString('id-ID')}</div>
        </div>

        <Group title="Tujuan Bersama" list={family} />
        <Group title="Tujuan Saya" list={mine} />
        <Group title="Tujuan Anggota Lain" list={others} />
      </div>

      <AmountSheet
        open={!!sel}
        title={sel ? 'Sisihkan ke ' + sel.name : ''}
        subtitle={sel ? `Dana dipindah ke "${walletOf(sel.wallet).name}" dan progres target bertambah.` : ''}
        accent="var(--primary)"
        walletLabel={wallet ? walletOf(wallet).name : 'Pilih'}
        onPickWallet={() => setWSheet(true)}
        confirmLabel="Sisihkan"
        onConfirm={confirm}
        onClose={() => setSel(null)}
      />
      <WalletSheet open={wSheet} title="Sumber dana" onClose={() => setWSheet(false)} onPick={(id) => { setWallet(id); setWSheet(false); }} />
    </div>
  );
}

window.GoalsScreen = GoalsScreen;

// ── Goal Detail ──
function GoalDetailScreen({ goal, txns, nav, onAddToGoal, showToast }) {
  const g = goal;
  const [open, setOpen] = React.useState(false);
  const [wallet, setWallet] = React.useState(g.wallet);
  const [wSheet, setWSheet] = React.useState(false);
  const pct = Math.round((g.current / g.target) * 100);
  const sisa = Math.max(0, g.target - g.current);
  const done = g.current >= g.target;
  const color = `hsl(${g.hue} 55% 45%)`;
  const hist = txns.filter(t => t.ref === 'g:' + g.id);

  const confirm = (amt) => { onAddToGoal(g.id, amt, wallet); showToast('Berhasil menyisihkan ' + fmtShort(amt)); setOpen(false); };

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title="Detail Kantong" onBack={nav.back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        <div className="card" style={{ padding: 22, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <ProgressRing size={104} stroke={9} value={g.current} max={g.target} color={done ? 'var(--income)' : color} track="var(--surface-2)">
            <span style={{ color: done ? 'var(--income)' : 'var(--text)', fontSize: 24 }}>{pct}%</span>
          </ProgressRing>
          <div style={{ fontSize: 18, fontWeight: 800, marginTop: 16, display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 28, height: 28, borderRadius: 9, background: window.__dkDark ? `hsl(${g.hue} 30% 20%)` : `hsl(${g.hue} 48% 94%)`, color, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={g.icon} size={16} strokeWidth={2} /></span>
            {g.name}
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
            <ScopeBadge scope={g.scope === 'family' ? 'shared' : 'personal'} />
            <span style={{ fontSize: 12, color: 'var(--text-3)', display: 'inline-flex', alignItems: 'center', gap: 3 }}><Icon name="flag" size={13} /> {_dateShort(g.date)}</span>
          </div>
          <div className="num" style={{ fontSize: 30, fontWeight: 800, marginTop: 16, letterSpacing: '-0.02em' }}>
            <span style={{ fontSize: 18, opacity: 0.7 }}>Rp</span>{g.current.toLocaleString('id-ID')}
          </div>
          <div className="num" style={{ fontSize: 13, color: 'var(--text-3)', fontWeight: 600, marginTop: 2 }}>dari Rp{g.target.toLocaleString('id-ID')} · {done ? 'tercapai 🎉' : 'kurang Rp' + sisa.toLocaleString('id-ID')}</div>
          <div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 10 }}>Tersimpan di <b style={{ color: 'var(--text-2)' }}>{walletOf(g.wallet).name}</b></div>
        </div>

        <button className="tap" onClick={() => { setWallet(g.wallet); setOpen(true); }} disabled={done} style={{
          width: '100%', height: 52, borderRadius: 16, marginTop: 16, background: done ? 'var(--surface-2)' : 'var(--primary)', color: done ? 'var(--text-3)' : 'var(--on-primary)', fontWeight: 700, fontSize: 15.5,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, boxShadow: done ? 'none' : 'var(--shadow)',
        }}><Icon name="plus" size={20} strokeWidth={2.4} /> Sisihkan dana</button>

        <div style={{ fontSize: 14, fontWeight: 800, margin: '24px 0 6px' }}>Riwayat Kontribusi</div>
        {hist.length === 0
          ? <EmptyState icon="piggy" title="Belum ada kontribusi" sub="Mulai sisihkan dana untuk tujuan ini." />
          : <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
              {hist.map((tx, i) => <div key={tx.id} style={{ borderBottom: i < hist.length - 1 ? '1px solid var(--border)' : 'none' }}><TxRow tx={tx} onClick={() => nav.push('txDetail', { tx })} /></div>)}
            </div>}
      </div>

      <AmountSheet open={open} title={'Sisihkan ke ' + g.name} subtitle={`Dana dipindah ke "${walletOf(g.wallet).name}".`} accent="var(--primary)"
        walletLabel={wallet ? walletOf(wallet).name : 'Pilih'} onPickWallet={() => setWSheet(true)} confirmLabel="Sisihkan" onConfirm={confirm} onClose={() => setOpen(false)} />
      <WalletSheet open={wSheet} title="Sumber dana" onClose={() => setWSheet(false)} onPick={(id) => { setWallet(id); setWSheet(false); }} />
    </div>
  );
}

window.GoalDetailScreen = GoalDetailScreen;
