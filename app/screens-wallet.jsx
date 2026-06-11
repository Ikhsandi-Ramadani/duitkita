// screens-wallet.jsx — Dompet + Detail Dompet
// Exposes: WalletScreen, WalletDetailScreen

function WalletCard({ w, onClick, showOwner }) {
  return (
    <button className="tap card" onClick={onClick} style={{
      width: '100%', display: 'flex', alignItems: 'center', gap: 14, padding: 15, textAlign: 'left',
      border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 10,
    }}>
      <span style={{
        width: 46, height: 46, borderRadius: 14, flexShrink: 0,
        background: w.scope === 'shared' ? 'var(--primary-tint)' : 'var(--surface-2)',
        color: w.scope === 'shared' ? 'var(--primary)' : 'var(--text-2)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><Icon name={walletTypeIcon(w.type)} size={24} strokeWidth={1.9} /></span>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{w.name}</div>
        <div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 2, display: 'flex', alignItems: 'center', gap: 6 }}>
          {walletTypeLabel(w.type)}
          {showOwner && <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>· <Avatar id={w.owner} size={15} /> {memberOf(w.owner).name}</span>}
        </div>
      </div>
      <div style={{ textAlign: 'right' }}>
        <div className="num" style={{ fontSize: 16, fontWeight: 800, letterSpacing: '-0.02em' }}>Rp{w.balance.toLocaleString('id-ID')}</div>
        <Icon name="chevronright" size={16} style={{ color: 'var(--text-3)', display: 'inline-block', marginTop: 2 }} />
      </div>
    </button>
  );
}

function GroupTitle({ children, total, sub }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', margin: '20px 0 11px' }}>
      <div>
        <div style={{ fontSize: 14.5, fontWeight: 800 }}>{children}</div>
        {sub && <div style={{ fontSize: 12, color: 'var(--text-3)', marginTop: 1 }}>{sub}</div>}
      </div>
      {total != null && <span className="num" style={{ fontSize: 13.5, fontWeight: 700, color: 'var(--text-2)' }}>Rp{total.toLocaleString('id-ID')}</span>}
    </div>
  );
}

function WalletScreen({ agg, nav, onAddWallet }) {
  const W = window.DK_DATA.wallets;
  const ME = window.DK_DATA.ME;
  const mine = W.filter(w => w.scope === 'personal' && w.owner === ME);
  const shared = W.filter(w => w.scope === 'shared');
  const sum = (l) => l.reduce((a, w) => a + w.balance, 0);
  const others = window.DK_DATA.members.filter(m => m.id !== ME).map(m => ({
    m, list: W.filter(w => w.scope === 'personal' && w.owner === m.id),
  }));

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ padding: `${STATUS_H + 8}px 20px 0`, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontSize: 24, fontWeight: 800, letterSpacing: '-0.02em' }}>Dompet</div>
        <button className="tap" onClick={onAddWallet} style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '8px 13px', borderRadius: 12, background: 'var(--primary-tint)', color: 'var(--primary)', fontWeight: 700, fontSize: 13.5 }}>
          <Icon name="plus" size={17} strokeWidth={2.4} /> Dompet
        </button>
      </div>

      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '14px 20px 110px' }}>
        {/* total summary */}
        <div style={{ borderRadius: 20, padding: 18, background: 'linear-gradient(158deg, var(--primary-600), var(--primary-700))', color: '#fff', marginBottom: 4 }}>
          <div style={{ fontSize: 12.5, fontWeight: 600, color: 'rgba(255,255,255,0.82)' }}>Total Kekayaan Keluarga</div>
          <div className="num" style={{ fontSize: 30, fontWeight: 800, letterSpacing: '-0.02em', margin: '5px 0 14px' }}>Rp{agg.total.toLocaleString('id-ID')}</div>
          <div style={{ display: 'flex', gap: 22 }}>
            <div><div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.78)' }}>Saldo Saya</div><div className="num" style={{ fontSize: 15, fontWeight: 700 }}>Rp{agg.saldoSaya.toLocaleString('id-ID')}</div></div>
            <div style={{ width: 1, background: 'rgba(255,255,255,0.2)' }}></div>
            <div><div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.78)' }}>Kas Bersama</div><div className="num" style={{ fontSize: 15, fontWeight: 700 }}>Rp{agg.kasBersama.toLocaleString('id-ID')}</div></div>
          </div>
        </div>

        <GroupTitle total={sum(mine)} sub="Dikelola olehmu">Dompet Saya</GroupTitle>
        {mine.map(w => <WalletCard key={w.id} w={w} onClick={() => nav.push('walletDetail', { id: w.id })} />)}

        <GroupTitle total={sum(shared)} sub="Milik keluarga — semua bisa pakai">Kas Bersama</GroupTitle>
        {shared.map(w => <WalletCard key={w.id} w={w} onClick={() => nav.push('walletDetail', { id: w.id })} />)}

        {others.map(({ m, list }) => list.length ? (
          <div key={m.id}>
            <GroupTitle total={sum(list)} sub="Hanya bisa dilihat">Dompet {m.name}</GroupTitle>
            {list.map(w => <WalletCard key={w.id} w={w} onClick={() => nav.push('walletDetail', { id: w.id })} />)}
          </div>
        ) : null)}
      </div>
    </div>
  );
}

// ── Detail ──
function WalletDetailScreen({ id, txns, nav, onAdjust, dark }) {
  const w = walletOf(id);
  const ME = window.DK_DATA.ME;
  const canEdit = w.scope === 'shared' || w.owner === ME;
  const list = txns.filter(t => t.wallet === id || t.target === id);

  // group by day
  const groups = [];
  list.forEach(tx => {
    const key = relDay(tx.date);
    let g = groups.find(x => x.key === key);
    if (!g) { g = { key, items: [] }; groups.push(g); }
    g.items.push(tx);
  });

  const shared = w.scope === 'shared';

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title={w.name} onBack={nav.back} right={
          <button className="tap" style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-2)' }}><Icon name="more" size={22} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        {/* balance hero */}
        <div style={{ borderRadius: 22, padding: '22px 20px', marginBottom: 18, color: shared ? '#fff' : 'var(--text)',
          background: shared ? 'linear-gradient(158deg, var(--primary-600), var(--primary-700))' : 'var(--surface)',
          border: shared ? 'none' : '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
            <span style={{ width: 40, height: 40, borderRadius: 12, background: shared ? 'rgba(255,255,255,0.18)' : 'var(--surface-2)', color: shared ? '#fff' : 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name={walletTypeIcon(w.type)} size={22} strokeWidth={1.9} />
            </span>
            <div>
              <div style={{ fontSize: 13.5, fontWeight: 600, opacity: shared ? 0.85 : 1, color: shared ? '#fff' : 'var(--text-2)' }}>{walletTypeLabel(w.type)} · {shared ? 'Bersama' : memberOf(w.owner).name}</div>
            </div>
          </div>
          <div style={{ fontSize: 12.5, fontWeight: 600, opacity: shared ? 0.82 : 0.7, color: shared ? '#fff' : 'var(--text-3)' }}>Saldo saat ini</div>
          <div className="num" style={{ fontSize: 36, fontWeight: 800, letterSpacing: '-0.03em', marginTop: 4 }}>
            <span style={{ fontSize: 22, opacity: 0.72 }}>Rp</span>{w.balance.toLocaleString('id-ID')}
          </div>
        </div>

        {/* actions */}
        {canEdit ? (
          <div style={{ display: 'flex', gap: 12, marginBottom: 8 }}>
            <button className="tap" onClick={() => nav.push('addEdit', { tx: null, preset: { type: 'expense', wallet: id } })} style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--primary)', color: 'var(--on-primary)', fontWeight: 700, fontSize: 14.5, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
              <Icon name="plus" size={19} strokeWidth={2.4} /> Transaksi
            </button>
            <button className="tap" onClick={() => onAdjust(id)} style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--surface)', border: '1px solid var(--border-2)', color: 'var(--text)', fontWeight: 700, fontSize: 14.5, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
              <Icon name="adjustment" size={19} /> Sesuaikan
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginBottom: 8, padding: '12px 15px', borderRadius: 14, background: 'var(--surface-2)', color: 'var(--text-3)' }}>
            <Icon name="eye" size={18} /><span style={{ fontSize: 13 }}>Dompet anggota lain — hanya bisa dilihat.</span>
          </div>
        )}

        <div style={{ fontSize: 14, fontWeight: 800, margin: '22px 0 6px' }}>Riwayat</div>
        {groups.length === 0 && <EmptyState title="Belum ada transaksi" />}
        {groups.map(g => (
          <div key={g.key} style={{ marginTop: 10 }}>
            <div style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--text-3)', marginBottom: 2 }}>{g.key}</div>
            <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
              {g.items.map((tx, i) => (
                <div key={tx.id} style={{ borderBottom: i < g.items.length - 1 ? '1px solid var(--border)' : 'none' }}>
                  <TxRow tx={tx} onClick={() => nav.push('txDetail', { tx })} />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { WalletScreen, WalletDetailScreen });
