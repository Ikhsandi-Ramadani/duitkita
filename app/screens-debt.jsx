// screens-debt.jsx — Utang & Piutang
// Exposes: DebtScreen

function _dueInfo(iso) {
  const due = new Date(iso); const today = window.DK_DATA.TODAY;
  const d0 = new Date(due.getFullYear(), due.getMonth(), due.getDate());
  const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const days = Math.round((d0 - t0) / 86400000);
  const M = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  const label = due.getDate() + ' ' + M[due.getMonth()];
  let status, color;
  if (days < 0) { status = 'Terlambat ' + (-days) + ' hari'; color = 'var(--expense)'; }
  else if (days === 0) { status = 'Jatuh tempo hari ini'; color = 'var(--expense)'; }
  else if (days <= 7) { status = days + ' hari lagi'; color = '#c98a16'; }
  else { status = 'Jatuh tempo ' + label; color = 'var(--text-3)'; }
  return { label, status, color, days };
}

function DebtCard({ d, onAct, onOpen }) {
  const remaining = d.amount - d.paid;
  const pct = Math.round(d.paid / d.amount * 100);
  const done = remaining <= 0;
  const payable = d.type === 'payable';
  const accent = payable ? 'var(--expense)' : 'var(--income)';
  const tint = payable ? 'var(--expense-tint)' : 'var(--income-tint)';
  const due = _dueInfo(d.due);
  const owner = d.scope === 'personal' ? memberOf(d.owner) : null;
  return (
    <div className="card tap" onClick={() => onOpen(d)} style={{ padding: 16, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 12, cursor: 'pointer' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
        <span style={{ width: 44, height: 44, borderRadius: 13, background: tint, color: accent, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, fontWeight: 800, fontSize: 17 }}>
          {d.party.charAt(0)}
        </span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15.5, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{d.party}</div>
          <div style={{ fontSize: 12.5, color: 'var(--text-3)', marginTop: 1 }}>{d.note}</div>
        </div>
        {d.scope === 'family' ? <ScopeBadge scope="shared" /> : (owner && <Avatar id={owner.id} size={26} />)}
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
        <div>
          <div style={{ fontSize: 11.5, color: 'var(--text-3)', fontWeight: 600 }}>{done ? 'Lunas' : 'Sisa'}</div>
          <MoneyText value={done ? d.amount : remaining} size={20} color={done ? 'var(--income)' : accent} />
        </div>
        <span className="num" style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600 }}>dari Rp{d.amount.toLocaleString('id-ID')}</span>
      </div>
      <ProgressBar value={d.paid} max={d.amount} color={done ? 'var(--income)' : accent} h={7} />
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 13 }}>
        <span style={{ fontSize: 12.5, fontWeight: 600, color: done ? 'var(--income)' : due.color, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          {!done && <Icon name="clock" size={13} />}{done ? '✓ Selesai' : due.status}
        </span>
        {!done && (
          <button className="tap" onClick={(e) => { e.stopPropagation(); onAct(d); }} style={{
            display: 'inline-flex', alignItems: 'center', gap: 6, padding: '9px 16px', borderRadius: 12,
            background: accent, color: '#fff', fontWeight: 700, fontSize: 13.5,
          }}><Icon name={payable ? 'expense' : 'income'} size={15} strokeWidth={2.2} /> {payable ? 'Bayar' : 'Terima'}</button>
        )}
      </div>
    </div>
  );
}

function DebtScreen({ debts, nav, onPayDebt, onAdd, showToast }) {
  const [tab, setTab] = React.useState('payable');
  const [sel, setSel] = React.useState(null);
  const [wallet, setWallet] = React.useState(null);
  const [wSheet, setWSheet] = React.useState(false);

  const payables = debts.filter(d => d.type === 'payable');
  const receivables = debts.filter(d => d.type === 'receivable');
  const totalUtang = payables.reduce((a, d) => a + (d.amount - d.paid), 0);
  const totalPiutang = receivables.reduce((a, d) => a + (d.amount - d.paid), 0);
  const list = tab === 'payable' ? payables : receivables;

  const openAct = (d) => { setSel(d); setWallet(d.wallet); };
  const confirm = (amt) => {
    onPayDebt(sel.id, amt, wallet);
    showToast(sel.type === 'payable' ? 'Pembayaran tercatat' : 'Penerimaan tercatat');
    setSel(null);
  };

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}>
        <TopBar title="Utang & Piutang" onBack={nav.back} right={
          <button className="tap" onClick={onAdd} style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' }}><Icon name="plus" size={23} strokeWidth={2.2} /></button>
        } />
      </div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        {/* summary */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 18 }}>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 5 }}><span style={{ width: 8, height: 8, borderRadius: 3, background: 'var(--expense)' }}></span>Utang</div>
            <MoneyText value={totalUtang} size={20} color="var(--expense)" />
            <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 2 }}>harus dibayar</div>
          </div>
          <div className="card" style={{ flex: 1, padding: 15, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
            <div style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 5 }}><span style={{ width: 8, height: 8, borderRadius: 3, background: 'var(--income)' }}></span>Piutang</div>
            <MoneyText value={totalPiutang} size={20} color="var(--income)" />
            <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 2 }}>akan diterima</div>
          </div>
        </div>

        <div style={{ marginBottom: 16 }}>
          <Segmented value={tab} onChange={setTab} options={[
            { value: 'payable', label: 'Utang (' + payables.length + ')' },
            { value: 'receivable', label: 'Piutang (' + receivables.length + ')' },
          ]} />
        </div>

        {list.length === 0 && <EmptyState icon="coins" title="Belum ada catatan" />}
        {list.map(d => <DebtCard key={d.id} d={d} onAct={openAct} onOpen={(dd) => nav.push('debtDetail', { id: dd.id })} />)}
      </div>

      <AmountSheet
        open={!!sel}
        title={sel ? (sel.type === 'payable' ? 'Bayar ke ' + sel.party : 'Terima dari ' + sel.party) : ''}
        subtitle={sel ? (sel.type === 'payable' ? `Uang keluar dari dompet untuk melunasi. Sisa Rp${(sel.amount - sel.paid).toLocaleString('id-ID')}.` : `Uang masuk ke dompet. Sisa Rp${(sel.amount - sel.paid).toLocaleString('id-ID')}.`) : ''}
        accent={sel && sel.type === 'payable' ? 'var(--expense)' : 'var(--income)'}
        initial={sel ? sel.amount - sel.paid : 0}
        walletLabel={wallet ? walletOf(wallet).name : 'Pilih'}
        onPickWallet={() => setWSheet(true)}
        confirmLabel={sel && sel.type === 'payable' ? 'Bayar' : 'Terima'}
        onConfirm={confirm}
        onClose={() => setSel(null)}
      />
      <WalletSheet open={wSheet} title={sel && sel.type === 'payable' ? 'Bayar dari dompet' : 'Terima ke dompet'} onClose={() => setWSheet(false)} onPick={(id) => { setWallet(id); setWSheet(false); }} />
    </div>
  );
}

window.DebtScreen = DebtScreen;

// ── Debt Detail ──
function DebtDetailScreen({ debt, txns, nav, onPayDebt, showToast }) {
  const d = debt;
  const [open, setOpen] = React.useState(false);
  const [wallet, setWallet] = React.useState(d.wallet);
  const [wSheet, setWSheet] = React.useState(false);
  const remaining = d.amount - d.paid;
  const done = remaining <= 0;
  const payable = d.type === 'payable';
  const accent = payable ? 'var(--expense)' : 'var(--income)';
  const due = _dueInfo(d.due);
  const owner = d.scope === 'personal' ? memberOf(d.owner) : null;
  const hist = txns.filter(t => t.ref === 'd:' + d.id);

  const confirm = (amt) => { onPayDebt(d.id, amt, wallet); showToast(payable ? 'Pembayaran tercatat' : 'Penerimaan tercatat'); setOpen(false); };

  return (
    <div className="screen-in" style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title={payable ? 'Detail Utang' : 'Detail Piutang'} onBack={nav.back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 40px' }}>
        <div className="card" style={{ padding: 22, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', textAlign: 'center' }}>
          <div style={{ width: 60, height: 60, borderRadius: 20, margin: '0 auto 12px', background: payable ? 'var(--expense-tint)' : 'var(--income-tint)', color: accent, display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: 24 }}>{d.party.charAt(0)}</div>
          <div style={{ fontSize: 18, fontWeight: 800 }}>{d.party}</div>
          <div style={{ fontSize: 13, color: 'var(--text-3)', marginTop: 2 }}>{d.note}</div>
          <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginTop: 10 }}>
            {d.scope === 'family' ? <ScopeBadge scope="shared" /> : (owner && <span style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-2)', display: 'inline-flex', alignItems: 'center', gap: 5, background: 'var(--surface-2)', padding: '3px 9px', borderRadius: 100 }}><Avatar id={owner.id} size={16} /> {owner.name}</span>)}
            <span style={{ fontSize: 11.5, fontWeight: 600, color: done ? 'var(--income)' : due.color, background: 'var(--surface-2)', padding: '4px 9px', borderRadius: 100 }}>{done ? '✓ Lunas' : due.status}</span>
          </div>
          <div className="num" style={{ fontSize: 32, fontWeight: 800, marginTop: 16, color: done ? 'var(--income)' : accent, letterSpacing: '-0.02em' }}>
            <span style={{ fontSize: 18, opacity: 0.7 }}>Rp</span>{(done ? d.amount : remaining).toLocaleString('id-ID')}
          </div>
          <div className="num" style={{ fontSize: 13, color: 'var(--text-3)', fontWeight: 600, marginTop: 2 }}>{done ? 'sudah lunas' : 'sisa dari Rp' + d.amount.toLocaleString('id-ID')}</div>
          <div style={{ marginTop: 14 }}><ProgressBar value={d.paid} max={d.amount} color={done ? 'var(--income)' : accent} h={8} /></div>
        </div>

        {!done && (
          <button className="tap" onClick={() => { setWallet(d.wallet); setOpen(true); }} style={{
            width: '100%', height: 52, borderRadius: 16, marginTop: 16, background: accent, color: '#fff', fontWeight: 700, fontSize: 15.5,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, boxShadow: 'var(--shadow)',
          }}><Icon name={payable ? 'expense' : 'income'} size={20} strokeWidth={2.2} /> {payable ? 'Bayar cicilan' : 'Terima pembayaran'}</button>
        )}

        <div style={{ fontSize: 14, fontWeight: 800, margin: '24px 0 6px' }}>Riwayat Pembayaran</div>
        {hist.length === 0
          ? <EmptyState icon="coins" title="Belum ada pembayaran" />
          : <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>
              {hist.map((tx, i) => <div key={tx.id} style={{ borderBottom: i < hist.length - 1 ? '1px solid var(--border)' : 'none' }}><TxRow tx={tx} onClick={() => nav.push('txDetail', { tx })} /></div>)}
            </div>}
      </div>

      <AmountSheet open={open} title={payable ? 'Bayar ke ' + d.party : 'Terima dari ' + d.party} accent={accent} initial={remaining}
        subtitle={payable ? `Uang keluar dari dompet. Sisa Rp${remaining.toLocaleString('id-ID')}.` : `Uang masuk ke dompet. Sisa Rp${remaining.toLocaleString('id-ID')}.`}
        walletLabel={wallet ? walletOf(wallet).name : 'Pilih'} onPickWallet={() => setWSheet(true)} confirmLabel={payable ? 'Bayar' : 'Terima'} onConfirm={confirm} onClose={() => setOpen(false)} />
      <WalletSheet open={wSheet} title={payable ? 'Bayar dari dompet' : 'Terima ke dompet'} onClose={() => setWSheet(false)} onPick={(id) => { setWallet(id); setWSheet(false); }} />
    </div>
  );
}

window.DebtDetailScreen = DebtDetailScreen;
