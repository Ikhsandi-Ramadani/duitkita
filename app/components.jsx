// components.jsx — shared display components (TxRow, MoneyText, ProgressBar, EmptyState)
// Exposes: TxRow, MoneyText, ProgressBar, EmptyState, ListHeader

// big money text with currency prefix sized down
function MoneyText({ value, size = 34, weight = 800, sign = '', color, prefixSize }) {
  const ps = prefixSize || size * 0.56;
  const abs = Math.abs(Math.round(value)).toLocaleString('id-ID');
  return (
    <span className="num" style={{ color, fontWeight: weight, fontSize: size, lineHeight: 1, whiteSpace: 'nowrap', letterSpacing: '-0.02em' }}>
      {sign}<span style={{ fontSize: ps, fontWeight: weight - 100, opacity: 0.78, marginRight: 1 }}>Rp</span>{abs}
    </span>
  );
}

function ProgressBar({ value, max, color = 'var(--primary)', track = 'var(--surface-2)', h = 8, over }) {
  const pct = Math.min(100, (value / max) * 100);
  return (
    <div style={{ height: h, borderRadius: h, background: track, overflow: 'hidden' }}>
      <div style={{
        height: '100%', width: pct + '%', borderRadius: h,
        background: over ? 'var(--expense)' : color,
        transition: 'width .6s cubic-bezier(.22,1,.36,1)',
      }}></div>
    </div>
  );
}

// transaction row — icon w/ recorder badge, title, subtitle, amount
function TxRow({ tx, onClick, showWallet = true, compact = false }) {
  const meta = txMeta(tx.type);
  const cat = tx.cat ? catOf(tx.cat) : null;
  const w = walletOf(tx.wallet);
  const tw = tx.target ? walletOf(tx.target) : null;
  const isTypeIcon = tx.type === 'transfer' || tx.type === 'adjustment';

  let title;
  if (tx.type === 'transfer') title = 'Transfer';
  else if (tx.type === 'adjustment') title = 'Penyesuaian saldo';
  else title = cat ? cat.name : meta.label;

  let sub;
  if (tx.type === 'transfer') sub = `${w ? w.name : ''} → ${tw ? tw.name : ''}`;
  else sub = showWallet ? (w ? w.name : '') : (tx.note || '');
  const forWhom = tx.forWhom ? memberOf(tx.forWhom) : null;

  return (
    <button className="tap" onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 13, width: '100%',
      padding: compact ? '9px 0' : '11px 0', textAlign: 'left', background: 'none',
    }}>
      <div style={{ position: 'relative' }}>
        {isTypeIcon ? (
          <div style={{
            width: 44, height: 44, borderRadius: 14, flexShrink: 0,
            background: meta.tint, color: meta.color,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><Icon name={meta.icon} size={22} strokeWidth={2} /></div>
        ) : <CatIcon catKey={tx.cat} />}
        {/* recorder avatar badge */}
        <div style={{ position: 'absolute', right: -4, bottom: -4 }}>
          <Avatar id={tx.by} size={19} ring />
        </div>
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--text)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</div>
        <div style={{ fontSize: 12.5, color: 'var(--text-3)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', marginTop: 1 }}>
          {sub}{forWhom ? ` · untuk ${forWhom.name}` : ''}{tx.receipt ? ' · 📎' : ''}
        </div>
      </div>

      <div style={{ textAlign: 'right', flexShrink: 0 }}>
        <div className="num" style={{ fontSize: 15, fontWeight: 700, color: meta.color, letterSpacing: '-0.01em' }}>
          {meta.sign}Rp{Math.abs(tx.amount).toLocaleString('id-ID')}
        </div>
        <div style={{ fontSize: 11.5, color: 'var(--text-3)', marginTop: 2 }}>{timeLabel(tx.date)}</div>
      </div>
    </button>
  );
}

function EmptyState({ icon = 'receipt', title, sub }) {
  return (
    <div style={{ padding: '50px 30px', textAlign: 'center', color: 'var(--text-3)' }}>
      <div style={{
        width: 64, height: 64, borderRadius: 22, margin: '0 auto 16px',
        background: 'var(--surface-2)', color: 'var(--text-3)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><Icon name={icon} size={30} /></div>
      <div style={{ fontSize: 15.5, fontWeight: 700, color: 'var(--text-2)' }}>{title}</div>
      {sub && <div style={{ fontSize: 13.5, marginTop: 4, lineHeight: 1.5 }}>{sub}</div>}
    </div>
  );
}

function ListHeader({ children, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-3)', textTransform: 'none', letterSpacing: '0.01em' }}>{children}</div>
      {right}
    </div>
  );
}

// circular progress ring (SVG)
function ProgressRing({ size = 56, stroke = 6, value, max, color = 'var(--primary)', track = 'var(--surface-2)', children }) {
  const r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  const pct = Math.max(0, Math.min(1, value / max));
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={track} strokeWidth={stroke} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeDasharray={circ} strokeDashoffset={circ * (1 - pct)} strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset .7s cubic-bezier(.22,1,.36,1)' }} />
      </svg>
      {children && <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: size * 0.26, fontWeight: 800 }} className="num">{children}</div>}
    </div>
  );
}

// amount entry sheet — quick chips + wallet pick (for sisihkan dana / bayar utang)
function AmountSheet({ open, title, subtitle, accent = 'var(--primary)', initial = 0, walletLabel, walletId, onPickWallet, confirmLabel = 'Konfirmasi', onConfirm, onClose }) {
  const [amt, setAmt] = React.useState(initial);
  React.useEffect(() => { if (open) setAmt(initial); }, [open]);
  if (!open) return null;
  const chips = [50000, 100000, 250000, 500000, 1000000];
  return (
    <Sheet open={open} onClose={onClose} title={title}>
      <div style={{ padding: '4px 22px 26px' }}>
        {subtitle && <div style={{ fontSize: 13.5, color: 'var(--text-2)', marginBottom: 16, lineHeight: 1.45 }}>{subtitle}</div>}
        <div style={{ textAlign: 'center', padding: '6px 0 16px' }}>
          <div className="num" style={{ fontSize: 38, fontWeight: 800, color: amt ? accent : 'var(--text-3)', letterSpacing: '-0.02em' }}>
            <span style={{ fontSize: 22, opacity: 0.7 }}>Rp</span>{amt.toLocaleString('id-ID')}
          </div>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginBottom: 8 }}>
          {chips.map(c => (
            <button key={c} className="tap" onClick={() => setAmt(a => a + c)} style={{
              padding: '9px 14px', borderRadius: 12, background: 'var(--surface-2)', color: 'var(--text-2)', fontWeight: 700, fontSize: 13.5,
            }}>+{fmtShort(c)}</button>
          ))}
          <button className="tap" onClick={() => setAmt(0)} style={{ padding: '9px 14px', borderRadius: 12, background: 'transparent', color: 'var(--text-3)', fontWeight: 700, fontSize: 13.5 }}>Reset</button>
        </div>
        {walletLabel !== undefined && (
          <button className="tap" onClick={onPickWallet} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 10, padding: '13px 15px', borderRadius: 14, background: 'var(--surface-2)', marginTop: 8, textAlign: 'left' }}>
            <Icon name="wallet" size={19} style={{ color: 'var(--text-3)' }} />
            <span style={{ fontSize: 13.5, color: 'var(--text-2)', fontWeight: 500 }}>Dari dompet</span>
            <span style={{ flex: 1 }}></span>
            <span style={{ fontSize: 14, fontWeight: 700 }}>{walletLabel}</span>
            <Icon name="chevronright" size={16} style={{ color: 'var(--text-3)' }} />
          </button>
        )}
        <button className="tap" onClick={() => amt > 0 && onConfirm(amt)} disabled={!amt} style={{
          marginTop: 14, width: '100%', height: 54, borderRadius: 16,
          background: amt ? accent : 'var(--surface-2)', color: amt ? '#fff' : 'var(--text-3)', fontSize: 16, fontWeight: 700,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}><Icon name="check" size={20} strokeWidth={2.4} /> {confirmLabel}</button>
      </div>
    </Sheet>
  );
}

Object.assign(window, { TxRow, MoneyText, ProgressBar, EmptyState, ListHeader, ProgressRing, AmountSheet });
