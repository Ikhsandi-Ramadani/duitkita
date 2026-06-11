// screens-more.jsx — Transaksi Berulang + Laporan
// Exposes: RecurringScreen, ReportScreen

function RecurringScreen({ recurrings, nav, onToggleAuto, onRun, onAdd, showToast }) {
  const _date = (iso) => { const d = new Date(iso); const M = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']; return d.getDate() + ' ' + M[d.getMonth()]; };
  const totalIn = recurrings.filter(r => r.kind === 'income').reduce((a, r) => a + r.amount, 0);
  const totalOut = recurrings.filter(r => r.kind === 'expense').reduce((a, r) => a + r.amount, 0);

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title="Transaksi Berulang" onBack={nav.back} right={
          <button className="tap" onClick={onAdd} style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' }}><Icon name="plus" size={23} strokeWidth={2.2} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        <div style={{ display: 'flex', gap: 12, marginBottom: 18 }}>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600 }}>Masuk rutin / bln</div>
            <MoneyText value={totalIn} size={19} color="var(--income)" />
          </div>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600 }}>Keluar rutin / bln</div>
            <MoneyText value={totalOut} size={19} color="var(--expense)" />
          </div>
        </div>

        {recurrings.map(r => {
          const meta = txMeta(r.kind);
          const w = walletOf(r.wallet);
          return (
            <div key={r.id} className="card" style={{ padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                {r.kind === 'income'
                  ? <span style={{ width: 44, height: 44, borderRadius: 14, background: meta.tint, color: meta.color, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="income" size={22} strokeWidth={2} /></span>
                  : <CatIcon catKey={r.cat} />}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 15, fontWeight: 700 }}>{r.note}</div>
                  <div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 1 }}>{w.name} · {r.freq}</div>
                </div>
                <div className="num" style={{ fontSize: 15, fontWeight: 700, color: meta.color }}>{meta.sign}Rp{r.amount.toLocaleString('id-ID')}</div>
              </div>
              <div style={{ height: 1, background: 'var(--border)', margin: '13px 0' }}></div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: 12.5, color: 'var(--text-2)', display: 'inline-flex', alignItems: 'center', gap: 5, whiteSpace: 'nowrap' }}>
                  <Icon name="repeat" size={14} style={{ color: 'var(--text-3)' }} /> Berikutnya <b style={{ color: 'var(--text)' }}>{_date(r.next)}</b>
                </span>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <button className="tap" onClick={() => onToggleAuto(r.id)} style={{ display: 'inline-flex', alignItems: 'center', gap: 7 }}>
                    <span style={{ fontSize: 11.5, fontWeight: 700, color: r.auto ? 'var(--primary)' : 'var(--text-3)' }}>{r.auto ? 'Otomatis' : 'Ingatkan'}</span>
                    <span style={{ width: 38, height: 22, borderRadius: 14, background: r.auto ? 'var(--primary)' : 'var(--border-2)', position: 'relative', transition: 'background .2s' }}>
                      <span style={{ position: 'absolute', top: 2.5, left: r.auto ? 18 : 2.5, width: 17, height: 17, borderRadius: '50%', background: '#fff', transition: 'left .2s', boxShadow: '0 1px 2px rgba(0,0,0,0.2)' }}></span>
                    </span>
                  </button>
                </div>
              </div>
              <button className="tap" onClick={() => { onRun(r); showToast('Dicatat: ' + r.note); }} style={{
                marginTop: 12, width: '100%', height: 42, borderRadius: 12, background: 'var(--surface-2)', color: 'var(--text)', fontWeight: 700, fontSize: 13.5,
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7,
              }}><Icon name="check" size={17} strokeWidth={2.2} /> Catat sekarang</button>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ── Laporan ──
function ReportScreen({ txns, nav }) {
  const cashflow = window.DK_DATA.cashflow;
  const income = txns.filter(t => t.type === 'income').reduce((a, t) => a + t.amount, 0);
  const expense = txns.filter(t => t.type === 'expense').reduce((a, t) => a + t.amount, 0);

  // category breakdown (expense)
  const byCat = {};
  txns.forEach(t => { if (t.type === 'expense') byCat[t.cat] = (byCat[t.cat] || 0) + t.amount; });
  let slices = Object.entries(byCat).map(([cat, amt]) => ({ cat, amt, c: catOf(cat) })).sort((a, b) => b.amt - a.amt);
  const totalExp = slices.reduce((a, s) => a + s.amt, 0) || 1;
  // build conic gradient
  let acc = 0;
  const segs = slices.map(s => {
    const start = acc / totalExp * 100; acc += s.amt; const end = acc / totalExp * 100;
    const color = `hsl(${s.c.hue} 55% ${window.__dkDark ? 58 : 48}%)`;
    return { ...s, start, end, color, pct: Math.round(s.amt / totalExp * 100) };
  });
  const conic = 'conic-gradient(' + segs.map(s => `${s.color} ${s.start}% ${s.end}%`).join(', ') + ')';

  // per-member spending (attribution: forWhom || by)
  const perMember = window.DK_DATA.members.map(m => {
    const amt = txns.filter(t => t.type === 'expense' && (t.forWhom === m.id || (!t.forWhom && t.by === m.id))).reduce((a, t) => a + t.amount, 0);
    return { m, amt };
  }).sort((a, b) => b.amt - a.amt);
  const maxMember = Math.max(1, ...perMember.map(x => x.amt));

  const maxCf = Math.max(...cashflow.map(c => Math.max(c.income, c.expense)));

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title="Laporan" onBack={nav.back} right={
          <button className="tap" style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '8px 12px', borderRadius: 11, background: 'var(--surface-2)', color: 'var(--text-2)', fontWeight: 700, fontSize: 13 }}>Juni 2026 <Icon name="chevrondown" size={15} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        {/* income vs expense */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12, color: 'var(--text-3)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 5 }}><Icon name="income" size={14} style={{ color: 'var(--income)' }} /> Pemasukan</div>
            <MoneyText value={income} size={18} color="var(--income)" />
          </div>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12, color: 'var(--text-3)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 5 }}><Icon name="expense" size={14} style={{ color: 'var(--expense)' }} /> Pengeluaran</div>
            <MoneyText value={expense} size={18} color="var(--expense)" />
          </div>
        </div>

        {/* donut */}
        <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 14 }}>Pengeluaran per Kategori</div>
        <div className="card" style={{ padding: 18, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 22, display: 'flex', alignItems: 'center', gap: 18 }}>
          <div style={{ position: 'relative', width: 120, height: 120, flexShrink: 0 }}>
            <div style={{ width: 120, height: 120, borderRadius: '50%', background: conic }}></div>
            <div style={{ position: 'absolute', inset: 26, borderRadius: '50%', background: 'var(--surface)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ fontSize: 10.5, color: 'var(--text-3)', fontWeight: 600 }}>Total</span>
              <span className="num" style={{ fontSize: 13.5, fontWeight: 800 }}>{fmtShort(totalExp)}</span>
            </div>
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {segs.slice(0, 5).map(s => (
              <div key={s.cat} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ width: 10, height: 10, borderRadius: 3, background: s.color, flexShrink: 0 }}></span>
                <span style={{ flex: 1, fontSize: 12.5, fontWeight: 600, color: 'var(--text-2)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{s.c.name}</span>
                <span className="num" style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-3)' }}>{s.pct}%</span>
              </div>
            ))}
          </div>
        </div>

        {/* cashflow bars */}
        <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 14 }}>Arus Kas Bulanan</div>
        <div className="card" style={{ padding: '18px 16px 14px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 22 }}>
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 8, height: 130 }}>
            {cashflow.map(c => (
              <div key={c.m} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, height: '100%', justifyContent: 'flex-end' }}>
                <div style={{ display: 'flex', alignItems: 'flex-end', gap: 3, height: '100%' }}>
                  <div style={{ width: 9, borderRadius: 4, background: 'var(--income)', height: Math.max(3, c.income / maxCf * 100) + '%' }}></div>
                  <div style={{ width: 9, borderRadius: 4, background: 'var(--expense)', height: Math.max(3, c.expense / maxCf * 100) + '%' }}></div>
                </div>
                <span style={{ fontSize: 11, color: 'var(--text-3)', fontWeight: 600 }}>{c.m}</span>
              </div>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 16, justifyContent: 'center', marginTop: 14 }}>
            <span style={{ fontSize: 12, color: 'var(--text-2)', display: 'inline-flex', alignItems: 'center', gap: 5 }}><span style={{ width: 9, height: 9, borderRadius: 3, background: 'var(--income)' }}></span>Masuk</span>
            <span style={{ fontSize: 12, color: 'var(--text-2)', display: 'inline-flex', alignItems: 'center', gap: 5 }}><span style={{ width: 9, height: 9, borderRadius: 3, background: 'var(--expense)' }}></span>Keluar</span>
          </div>
        </div>

        {/* per member */}
        <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 14 }}>Pengeluaran per Anggota</div>
        <div className="card" style={{ padding: '6px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
          {perMember.map((x, i) => (
            <div key={x.m.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 0', borderBottom: i < perMember.length - 1 ? '1px solid var(--border)' : 'none' }}>
              <Avatar id={x.m.id} size={36} />
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ fontSize: 14, fontWeight: 600 }}>{x.m.name}</span>
                  <span className="num" style={{ fontSize: 13.5, fontWeight: 700 }}>Rp{x.amt.toLocaleString('id-ID')}</span>
                </div>
                <ProgressBar value={x.amt} max={maxMember} color={`hsl(${x.m.hue} 44% 50%)`} h={6} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { RecurringScreen, ReportScreen });
