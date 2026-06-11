// screens-home.jsx — Home (Beranda)
// Exposes: HomeScreen

function GlassCard({ label, value, hidden, icon, onClick }) {
  return (
    <button className="tap" onClick={onClick} style={{
      flex: 1, textAlign: 'left', borderRadius: 18, padding: '13px 14px',
      background: 'rgba(255,255,255,0.14)', border: '1px solid rgba(255,255,255,0.2)',
      backdropFilter: 'blur(6px)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
        <span style={{ color: 'rgba(255,255,255,0.85)' }}><Icon name={icon} size={15} strokeWidth={2} /></span>
        <span style={{ fontSize: 12.5, fontWeight: 600, color: 'rgba(255,255,255,0.85)' }}>{label}</span>
      </div>
      <div className="num" style={{ fontSize: 18.5, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>
        {hidden ? '••••••' : 'Rp' + value.toLocaleString('id-ID')}
      </div>
    </button>
  );
}

function HomeScreen({ agg, txns, goals, debts, hidden, setHidden, nav, openTx, onQuick }) {
  const me = memberOf(window.DK_DATA.ME);
  const recent = txns.slice(0, 5);
  const budgetPct = Math.round((agg.spentMonth / agg.budgetTotal) * 100);
  const over = agg.spentMonth > agg.budgetTotal;
  const goalSum = { cur: goals.reduce((a, g) => a + g.current, 0), tgt: goals.reduce((a, g) => a + g.target, 0) };
  const debtSum = {
    utang: debts.filter(d => d.type === 'payable').reduce((a, d) => a + (d.amount - d.paid), 0),
    piutang: debts.filter(d => d.type === 'receivable').reduce((a, d) => a + (d.amount - d.paid), 0),
  };

  return (
    <div className="dk-scroll screen-in" style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden' }}>
      {/* ── Emerald header ── */}
      <div style={{
        background: 'linear-gradient(158deg, var(--primary-600) 0%, var(--primary-700) 100%)',
        borderBottomLeftRadius: 30, borderBottomRightRadius: 30,
        padding: `${STATUS_H + 14}px 20px 22px`,
        position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', top: -60, right: -40, width: 200, height: 200, borderRadius: '50%', background: 'rgba(255,255,255,0.07)' }}></div>
        <div style={{ position: 'absolute', bottom: -70, left: -30, width: 160, height: 160, borderRadius: '50%', background: 'rgba(255,255,255,0.05)' }}></div>

        {/* greeting row */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
            <Avatar id={me.id} size={42} />
            <div>
              <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.8)', fontWeight: 500 }}>Selamat pagi,</div>
              <div style={{ fontSize: 17, color: '#fff', fontWeight: 700 }}>{me.name} 👋</div>
            </div>
          </div>
          <button className="tap" onClick={() => nav.push('notif')} style={{
            width: 42, height: 42, borderRadius: '50%', color: '#fff', position: 'relative',
            background: 'rgba(255,255,255,0.14)', display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="bell" size={21} strokeWidth={2} />
            <span style={{ position: 'absolute', top: 10, right: 11, width: 8, height: 8, borderRadius: '50%', background: '#ffd23d', border: '1.5px solid var(--primary-700)' }}></span>
          </button>
        </div>

        {/* total */}
        <div style={{ position: 'relative', marginTop: 22, marginBottom: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ fontSize: 13, color: 'rgba(255,255,255,0.82)', fontWeight: 600 }}>Total Kekayaan Keluarga</span>
            <button className="tap" onClick={() => setHidden(h => !h)} aria-label="Sembunyikan saldo" style={{ color: 'rgba(255,255,255,0.82)', display: 'flex' }}>
              <Icon name={hidden ? 'eyeoff' : 'eye'} size={17} strokeWidth={2} />
            </button>
          </div>
          <div className="num" style={{ fontSize: 40, fontWeight: 800, color: '#fff', marginTop: 6, letterSpacing: '-0.03em', lineHeight: 1 }}>
            {hidden ? 'Rp ••••••••' : <span><span style={{ fontSize: 24, fontWeight: 700, opacity: 0.82 }}>Rp</span>{agg.total.toLocaleString('id-ID')}</span>}
          </div>
        </div>

        {/* two sub-cards */}
        <div style={{ display: 'flex', gap: 12, position: 'relative' }}>
          <GlassCard label="Saldo Saya" value={agg.saldoSaya} hidden={hidden} icon="user" onClick={() => nav.tab('wallet')} />
          <GlassCard label="Kas Bersama" value={agg.kasBersama} hidden={hidden} icon="users" onClick={() => nav.tab('wallet')} />
        </div>
      </div>

      {/* ── Body ── */}
      <div style={{ padding: '18px 20px 110px' }}>
        {/* budget card */}
        <button className="tap card" onClick={() => nav.push('budget')} style={{
          width: '100%', textAlign: 'left', padding: 17, boxShadow: 'var(--shadow-sm)',
          border: '1px solid var(--border)', marginBottom: 16,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <span style={{ fontSize: 14.5, fontWeight: 700 }}>Pengeluaran Juni</span>
            <span style={{ fontSize: 12.5, color: over ? 'var(--expense)' : 'var(--text-3)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 3 }}>
              <span>{budgetPct + '% terpakai'}</span><Icon name="chevronright" size={15} />
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 9 }}>
            <MoneyText value={agg.spentMonth} size={23} color={over ? 'var(--expense)' : 'var(--text)'} />
            <span className="num" style={{ fontSize: 13, color: 'var(--text-3)', fontWeight: 600 }}>dari Rp{agg.budgetTotal.toLocaleString('id-ID')}</span>
          </div>
          <ProgressBar value={agg.spentMonth} max={agg.budgetTotal} over={over} h={9} />
        </button>

        {/* quick actions */}
        <div style={{ display: 'flex', gap: 10, marginBottom: 22 }}>
          {[
            { label: 'Isi Kas\nBersama', icon: 'users', action: 'fill' },
            { label: 'Transfer', icon: 'transfer', action: 'transfer' },
            { label: 'Pemasukan', icon: 'income', action: 'income' },
            { label: 'Scan\nStruk', icon: 'scan', action: 'scan' },
          ].map(q => (
            <button key={q.action} className="tap" onClick={() => onQuick(q.action)} style={{
              flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
            }}>
              <span style={{
                width: 52, height: 52, borderRadius: 17, background: 'var(--primary-tint)', color: 'var(--primary)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}><Icon name={q.icon} size={23} strokeWidth={2} /></span>
              <span style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-2)', textAlign: 'center', whiteSpace: 'pre-line', lineHeight: 1.25 }}>{q.label}</span>
            </button>
          ))}
        </div>

        {/* feature hub */}
        <div className="dk-scroll" style={{ display: 'flex', gap: 10, overflowX: 'auto', margin: '0 -20px 18px', padding: '0 20px' }}>
          {[
            { label: 'Anggaran', icon: 'sliders', s: 'budget' },
            { label: 'Tujuan', icon: 'target', s: 'goals' },
            { label: 'Utang', icon: 'coins', s: 'debts' },
            { label: 'Berulang', icon: 'repeat', s: 'recurring' },
            { label: 'Laporan', icon: 'chart', s: 'report' },
          ].map(m => (
            <button key={m.s} className="tap" onClick={() => nav.push(m.s)} style={{
              flexShrink: 0, width: 68, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7,
            }}>
              <span style={{ width: 56, height: 56, borderRadius: 18, background: 'var(--surface)', border: '1px solid var(--border)', color: 'var(--text)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-sm)' }}><Icon name={m.icon} size={23} strokeWidth={1.9} /></span>
              <span style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-2)' }}>{m.label}</span>
            </button>
          ))}
        </div>

        {/* target & utang summary */}
        <div className="card" style={{ display: 'flex', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 22, overflow: 'hidden' }}>
          <button className="tap" onClick={() => nav.push('goals')} style={{ flex: 1, padding: 15, textAlign: 'left', display: 'flex', alignItems: 'center', gap: 11 }}>
            <ProgressRing size={42} stroke={5} value={goalSum.cur} max={goalSum.tgt} color="var(--primary)" track="var(--surface-2)" />
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 12, color: 'var(--text-3)', fontWeight: 600 }}>Kantong Tujuan</div>
              <div className="num" style={{ fontSize: 15, fontWeight: 800, whiteSpace: 'nowrap' }}>{fmtShort(goalSum.cur)}</div>
            </div>
          </button>
          <div style={{ width: 1, background: 'var(--border)' }}></div>
          <button className="tap" onClick={() => nav.push('debts')} style={{ flex: 1, padding: 15, textAlign: 'left' }}>
            <div style={{ fontSize: 12, color: 'var(--text-3)', fontWeight: 600, marginBottom: 5 }}>Utang / Piutang</div>
            <div style={{ display: 'flex', gap: 10 }}>
              <span className="num" style={{ fontSize: 13.5, fontWeight: 800, color: 'var(--expense)' }}>−{fmtShort(debtSum.utang)}</span>
              <span className="num" style={{ fontSize: 13.5, fontWeight: 800, color: 'var(--income)' }}>+{fmtShort(debtSum.piutang)}</span>
            </div>
          </button>
        </div>

        {/* recent */}
        <ListHeader right={<button className="tap" onClick={() => nav.tab('txlist')} style={{ fontSize: 13, fontWeight: 700, color: 'var(--primary)' }}>Lihat semua</button>}>
          Transaksi Terbaru
        </ListHeader>
        <div className="card" style={{ padding: '4px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
          {recent.map((tx, i) => (
            <div key={tx.id} style={{ borderBottom: i < recent.length - 1 ? '1px solid var(--border)' : 'none' }}>
              <TxRow tx={tx} onClick={() => openTx(tx)} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

window.HomeScreen = HomeScreen;
