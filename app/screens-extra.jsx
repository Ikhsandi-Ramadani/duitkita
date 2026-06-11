// screens-extra.jsx — Budget + Notifikasi (secondary screens)
// Exposes: BudgetScreen, NotifScreen

function BudgetScreen({ txns, nav }) {
  const budgets = window.DK_DATA.budgets;
  const spentByCat = {};
  txns.forEach(t => { if (t.type === 'expense') spentByCat[t.cat] = (spentByCat[t.cat] || 0) + t.amount; });
  const totalBudget = budgets.reduce((a, b) => a + b.amount, 0);
  const totalSpent = budgets.reduce((a, b) => a + (spentByCat[b.cat] || 0), 0);
  const pct = Math.round((totalSpent / totalBudget) * 100);

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title="Anggaran Juni" onBack={nav.back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        <div style={{ borderRadius: 22, padding: 20, background: 'linear-gradient(158deg, var(--primary-600), var(--primary-700))', color: '#fff', marginBottom: 22 }}>
          <div style={{ fontSize: 13, fontWeight: 600, opacity: 0.85 }}>Total terpakai bulan ini</div>
          <div className="num" style={{ fontSize: 32, fontWeight: 800, letterSpacing: '-0.02em', margin: '5px 0 4px' }}>Rp{totalSpent.toLocaleString('id-ID')}</div>
          <div className="num" style={{ fontSize: 13, opacity: 0.85 }}>dari anggaran Rp{totalBudget.toLocaleString('id-ID')} · sisa Rp{(totalBudget - totalSpent).toLocaleString('id-ID')}</div>
          <div style={{ marginTop: 14, height: 9, borderRadius: 9, background: 'rgba(255,255,255,0.25)', overflow: 'hidden' }}>
            <div style={{ height: '100%', width: Math.min(100, pct) + '%', background: '#fff', borderRadius: 9 }}></div>
          </div>
        </div>

        <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 12 }}>Per Kategori</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {budgets.map(b => {
            const spent = spentByCat[b.cat] || 0;
            const p = Math.round((spent / b.amount) * 100);
            const over = spent > b.amount;
            const c = catOf(b.cat);
            return (
              <div key={b.cat}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 9 }}>
                  <CatIcon catKey={b.cat} size={40} iconSize={20} />
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14.5, fontWeight: 700 }}>{c.name}</div>
                    <div className="num" style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 1 }}>Rp{spent.toLocaleString('id-ID')} / Rp{b.amount.toLocaleString('id-ID')}</div>
                  </div>
                  <span className="num" style={{ fontSize: 13.5, fontWeight: 700, color: over ? 'var(--expense)' : 'var(--text-2)' }}>{p}%</span>
                </div>
                <ProgressBar value={spent} max={b.amount} over={over} h={8} />
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function NotifScreen({ nav }) {
  const items = [
    { icon: 'warning', color: 'var(--expense)', tint: 'var(--expense-tint)', title: 'Budget Makanan hampir habis', sub: '82% dari anggaran Juni terpakai', time: 'Hari ini, 08:20' },
    { icon: 'transfer', color: 'var(--transfer)', tint: 'var(--transfer-tint)', title: 'Budi mengisi Kas Belanja', sub: '+Rp2.000.000 ke Kas Belanja', time: 'Kemarin, 20:10' },
    { icon: 'income', color: 'var(--income)', tint: 'var(--income-tint)', title: 'Gaji masuk', sub: 'Rp14.500.000 ke BCA Budi', time: 'Selasa, 09:00' },
    { icon: 'bell', color: 'var(--adjust)', tint: 'var(--adjust-tint)', title: 'Tagihan Internet jatuh tempo', sub: 'IndiHome · Rp230.000 · 3 hari lagi', time: 'Senin, 07:00' },
  ];
  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title="Notifikasi" onBack={nav.back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        {items.map((n, i) => (
          <div key={i} className="card" style={{ display: 'flex', gap: 13, padding: 15, marginBottom: 11, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <span style={{ width: 42, height: 42, borderRadius: 13, background: n.tint, color: n.color, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={n.icon} size={21} strokeWidth={1.9} /></span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14.5, fontWeight: 700 }}>{n.title}</div>
              <div style={{ fontSize: 13, color: 'var(--text-2)', marginTop: 2 }}>{n.sub}</div>
              <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 6 }}>{n.time}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { BudgetScreen, NotifScreen });
