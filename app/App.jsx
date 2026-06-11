// App.jsx — DuitKita orchestrator
// Mounts into #root. Requires all other app/* scripts loaded first.

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "dark": false,
  "accent": "#047857",
  "numStyle": "tabular",
  "homeHeader": "gradient",
  "startScreen": "lock"
}/*EDITMODE-END*/;

const ACCENTS = {
  '#047857': { p: '#047857', p6: '#058564', p7: '#036249', tint: '#e6f2ed', tint2: '#d3e8e0', dP: '#14b083', dP6: '#16c091', dP7: '#0f9d75', dTint: '#11362c', dTint2: '#154437' },
  '#0d9488': { p: '#0d9488', p6: '#10a99b', p7: '#0b7d72', tint: '#e2f2f0', tint2: '#c9e7e3', dP: '#14b8a6', dP6: '#19c7b4', dP7: '#0f9c8d', dTint: '#0f3531', dTint2: '#15433d' },
  '#059669': { p: '#059669', p6: '#06a877', p7: '#04805a', tint: '#e3f4ec', tint2: '#caead9', dP: '#10c285', dP6: '#15cf90', dP7: '#0ba673', dTint: '#103328', dTint2: '#154535' },
};

function applyAccent(root, hex, dark) {
  const a = ACCENTS[hex] || ACCENTS['#047857'];
  root.style.setProperty('--primary', dark ? a.dP : a.p);
  root.style.setProperty('--primary-600', dark ? a.dP6 : a.p6);
  root.style.setProperty('--primary-700', dark ? a.dP7 : a.p7);
  root.style.setProperty('--primary-tint', dark ? a.dTint : a.tint);
  root.style.setProperty('--primary-tint-2', dark ? a.dTint2 : a.tint2);
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  window.__dkDark = t.dark;

  const [phase, setPhase] = React.useState(t.startScreen === 'app' ? 'app' : (t.startScreen === 'auth' ? 'auth' : 'lock'));
  const [tab, setTab] = React.useState('home');
  const [stack, setStack] = React.useState([]); // [{screen, params}]
  const [txns, setTxns] = React.useState(window.DK_DATA.transactions.slice());
  const [goals, setGoals] = React.useState(window.DK_DATA.goals.map(g => ({ ...g })));
  const [debts, setDebts] = React.useState(window.DK_DATA.debts.map(d => ({ ...d })));
  const [recurrings, setRecurrings] = React.useState(window.DK_DATA.recurrings.map(r => ({ ...r })));
  const [hidden, setHidden] = React.useState(false);
  const [add, setAdd] = React.useState(null); // {preset, edit} or null
  const [formSheet, setFormSheet] = React.useState(null); // 'goal' | 'debt' | 'recurring'
  const [toast, setToast] = React.useState(null);
  const [, force] = React.useReducer(x => x + 1, 0);
  const frameRef = React.useRef(null);

  // apply accent tweak to the live frame root
  React.useEffect(() => {
    if (frameRef.current) applyAccent(frameRef.current, t.accent, t.dark);
  });

  // live-switch entry screen when the tweak changes
  const firstRun = React.useRef(true);
  React.useEffect(() => {
    if (firstRun.current) { firstRun.current = false; return; }
    setStack([]); setTab('home'); setAdd(null);
    setPhase(t.startScreen === 'app' ? 'app' : (t.startScreen === 'auth' ? 'auth' : 'lock'));
  }, [t.startScreen]);

  const showToast = (msg) => { setToast(msg); clearTimeout(window.__tT); window.__tT = setTimeout(() => setToast(null), 2200); };

  // balance mutation helpers
  const applyDelta = (tx, sign) => {
    const w = walletOf(tx.wallet);
    const tw = tx.target ? walletOf(tx.target) : null;
    if (tx.type === 'income') w.balance += sign * tx.amount;
    else if (tx.type === 'expense') w.balance -= sign * tx.amount;
    else if (tx.type === 'transfer') { w.balance -= sign * tx.amount; if (tw) tw.balance += sign * tx.amount; }
    else if (tx.type === 'adjustment') w.balance += sign * tx.amount;
  };

  const nav = {
    push: (screen, params) => {
      if (screen === 'addEdit') { setAdd({ preset: params && params.preset, edit: params && params.tx }); return; }
      setStack(s => [...s, { screen, params: params || {} }]);
    },
    back: () => setStack(s => s.slice(0, -1)),
    tab: (id) => { setStack([]); setTab(id); },
  };

  const openTx = (tx) => nav.push('txDetail', { tx });

  const onSave = (tx, edit) => {
    if (edit) {
      applyDelta(edit, -1); applyDelta(tx, +1);
      setTxns(list => list.map(x => x.id === tx.id ? tx : x));
      showToast('Transaksi diperbarui');
    } else {
      applyDelta(tx, +1);
      setTxns(list => [tx, ...list].sort((a, b) => new Date(b.date) - new Date(a.date)));
      showToast('Transaksi tersimpan ✓');
    }
    setAdd(null);
    setStack(s => s.filter(x => x.screen !== 'txDetail')); // leave detail if editing
    force();
  };

  const onDelete = (tx) => {
    applyDelta(tx, -1);
    setTxns(list => list.filter(x => x.id !== tx.id));
    nav.back();
    showToast('Transaksi dihapus');
    force();
  };

  const onQuick = (action) => {
    if (action === 'fill') setAdd({ preset: { type: 'transfer', wallet: 'w1', target: 'w6' } });
    else if (action === 'transfer') setAdd({ preset: { type: 'transfer' } });
    else if (action === 'income') setAdd({ preset: { type: 'income' } });
    else if (action === 'scan') { setAdd({ preset: { type: 'expense' } }); showToast('Pindai struk (contoh)'); }
  };

  const onAdjust = (id) => setAdd({ preset: { type: 'adjustment', wallet: id } });

  const addTx = (tx) => { applyDelta(tx, +1); setTxns(list => [tx, ...list].sort((a, b) => new Date(b.date) - new Date(a.date))); };

  const onAddToGoal = (goalId, amount, walletId) => {
    const g = goals.find(x => x.id === goalId); if (!g) return;
    const dest = g.wallet;
    if (walletId && walletId !== dest) {
      addTx({ id: 'tx' + Date.now(), type: 'transfer', amount, wallet: walletId, target: dest, cat: null, date: new Date('2026-06-11T09:30:00').toISOString(), note: 'Sisihkan ke ' + g.name, by: window.DK_DATA.ME, forWhom: null, ref: 'g:' + goalId });
    }
    setGoals(list => list.map(x => x.id === goalId ? { ...x, current: Math.min(x.target, x.current + amount) } : x));
    force();
  };

  const onPayDebt = (debtId, amount, walletId) => {
    const d = debts.find(x => x.id === debtId); if (!d) return;
    const pay = Math.min(amount, d.amount - d.paid);
    addTx({
      id: 'tx' + Date.now(), type: d.type === 'payable' ? 'expense' : 'income', amount: pay, wallet: walletId, target: null,
      cat: d.type === 'payable' ? 'lainnya_e' : 'lainnya_i', date: new Date('2026-06-11T09:30:00').toISOString(),
      note: (d.type === 'payable' ? 'Bayar utang ' : 'Terima piutang ') + d.party, by: window.DK_DATA.ME, forWhom: null, ref: 'd:' + debtId,
    });
    setDebts(list => list.map(x => x.id === debtId ? { ...x, paid: x.paid + pay } : x));
    force();
  };

  const onToggleAuto = (id) => setRecurrings(list => list.map(r => r.id === id ? { ...r, auto: !r.auto } : r));
  const onRun = (r) => {
    addTx({ id: 'tx' + Date.now(), type: r.kind, amount: r.amount, wallet: r.wallet, target: null, cat: r.cat, date: new Date('2026-06-11T09:30:00').toISOString(), note: r.note, by: r.by, forWhom: null });
    force();
  };

  const onCreateGoal = (g) => { setGoals(l => [...l, g]); setFormSheet(null); showToast('Kantong "' + g.name + '" dibuat'); };
  const onCreateDebt = (d) => { setDebts(l => [...l, d]); setFormSheet(null); showToast(d.type === 'payable' ? 'Utang dicatat' : 'Piutang dicatat'); };
  const onCreateRecurring = (r) => { setRecurrings(l => [...l, r]); setFormSheet(null); showToast('Template "' + r.note + '" dibuat'); };

  // ── aggregates ──
  const W = window.DK_DATA.wallets, ME = window.DK_DATA.ME;
  const agg = React.useMemo(() => {
    const total = W.reduce((a, w) => a + w.balance, 0);
    const saldoSaya = W.filter(w => w.scope === 'personal' && w.owner === ME).reduce((a, w) => a + w.balance, 0);
    const kasBersama = W.filter(w => w.scope === 'shared').reduce((a, w) => a + w.balance, 0);
    const spentMonth = txns.filter(x => x.type === 'expense').reduce((a, x) => a + x.amount, 0);
    const budgetTotal = window.DK_DATA.budgets.reduce((a, b) => a + b.amount, 0);
    return { total, saldoSaya, kasBersama, spentMonth, budgetTotal };
  }, [txns, add]);

  // ── status bar appearance ──
  const top = stack[stack.length - 1];
  let statusLight = false;
  if (phase === 'lock') statusLight = true;
  else if (phase === 'app' && !top && tab === 'home') statusLight = true;
  if (add) statusLight = false;

  // ── render current main view ──
  let view;
  if (top) {
    if (top.screen === 'txDetail') view = <TxDetailScreen tx={top.params.tx} nav={nav} onDelete={onDelete} dark={t.dark} />;
    else if (top.screen === 'walletDetail') view = <WalletDetailScreen id={top.params.id} txns={txns} nav={nav} onAdjust={onAdjust} dark={t.dark} />;
    else if (top.screen === 'budget') view = <BudgetScreen txns={txns} nav={nav} />;
    else if (top.screen === 'notif') view = <NotifScreen nav={nav} />;
    else if (top.screen === 'goals') view = <GoalsScreen goals={goals} nav={nav} onAddToGoal={onAddToGoal} onAdd={() => setFormSheet('goal')} showToast={showToast} />;
    else if (top.screen === 'goalDetail') view = <GoalDetailScreen goal={goals.find(x => x.id === top.params.id)} txns={txns} nav={nav} onAddToGoal={onAddToGoal} showToast={showToast} />;
    else if (top.screen === 'debts') view = <DebtScreen debts={debts} nav={nav} onPayDebt={onPayDebt} onAdd={() => setFormSheet('debt')} showToast={showToast} />;
    else if (top.screen === 'debtDetail') view = <DebtDetailScreen debt={debts.find(x => x.id === top.params.id)} txns={txns} nav={nav} onPayDebt={onPayDebt} showToast={showToast} />;
    else if (top.screen === 'recurring') view = <RecurringScreen recurrings={recurrings} nav={nav} onToggleAuto={onToggleAuto} onRun={onRun} onAdd={() => setFormSheet('recurring')} showToast={showToast} />;
    else if (top.screen === 'report') view = <ReportScreen txns={txns} nav={nav} />;
  } else {
    if (tab === 'home') view = <HomeScreen agg={agg} txns={txns} goals={goals} debts={debts} hidden={hidden} setHidden={setHidden} nav={nav} openTx={openTx} onQuick={onQuick} />;
    else if (tab === 'txlist') view = <TxListScreen txns={txns} openTx={openTx} dark={t.dark} />;
    else if (tab === 'wallet') view = <WalletScreen agg={agg} nav={nav} onAddWallet={() => showToast('Tambah dompet (contoh)')} />;
    else if (tab === 'profile') view = <ProfileScreen dark={t.dark} onToggleDark={() => setTweak('dark', !t.dark)} onLogout={() => { setPhase('auth'); setTab('home'); setStack([]); }} nav={nav} />;
  }

  const showNav = phase === 'app' && !top && !add;

  return (
    <PhoneFrame
      ref={frameRef}
      dark={t.dark}
      statusLight={statusLight}
      nav={showNav ? <BottomNav active={tab} onTab={nav.tab} onAdd={() => setAdd({ preset: {} })} /> : null}
    >
      {/* main app */}
      {view}

      {/* add overlay */}
      {add && <AddTransaction preset={add.preset} edit={add.edit} dark={t.dark} onClose={() => setAdd(null)} onSave={onSave} />}

      {/* create-entity form sheets */}
      {formSheet === 'goal' && <AddGoalSheet open onClose={() => setFormSheet(null)} onSave={onCreateGoal} />}
      {formSheet === 'debt' && <AddDebtSheet open onClose={() => setFormSheet(null)} onSave={onCreateDebt} />}
      {formSheet === 'recurring' && <AddRecurringSheet open onClose={() => setFormSheet(null)} onSave={onCreateRecurring} />}

      {/* auth / lock overlays */}
      {phase === 'lock' && <AppLock onUnlock={() => setPhase('app')} onSwitch={() => setPhase('auth')} />}
      {phase === 'auth' && <AuthFlow onDone={() => setPhase('app')} />}

      {/* toast */}
      {toast && (
        <div style={{
          position: 'absolute', bottom: 96, left: '50%', transform: 'translateX(-50%)', zIndex: 95,
          background: 'var(--text)', color: 'var(--app-bg)', padding: '12px 20px', borderRadius: 14,
          fontSize: 14, fontWeight: 600, whiteSpace: 'nowrap', boxShadow: 'var(--shadow-lg)',
          animation: 'dk-rise .26s cubic-bezier(.22,1,.36,1)',
        }}>{toast}</div>
      )}

      <DKTweaks t={t} setTweak={setTweak} />
    </PhoneFrame>
  );
}

function DKTweaks({ t, setTweak }) {
  return (
    <TweaksPanel>
      <TweakSection label="Tampilan" />
      <TweakToggle label="Mode gelap" value={t.dark} onChange={(v) => setTweak('dark', v)} />
      <TweakColor label="Warna utama" value={t.accent}
        options={['#047857', '#0d9488', '#059669']}
        onChange={(v) => setTweak('accent', v)} />
      <TweakSection label="Layar awal" />
      <TweakRadio label="Mulai dari" value={t.startScreen}
        options={[{ value: 'lock', label: 'App Lock' }, { value: 'auth', label: 'Login' }, { value: 'app', label: 'Beranda' }]}
        onChange={(v) => setTweak('startScreen', v)} />
    </TweaksPanel>
  );
}

// PhoneFrame needs to forward ref to the .dk root for accent injection
ReactDOM.createRoot(document.getElementById('root')).render(<App />);
