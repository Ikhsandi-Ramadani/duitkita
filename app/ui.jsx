// ui.jsx — shared lookups + primitives for DuitKita
// Exposes: memberOf, walletOf, catOf, txMeta, walletBalance, ownerLabel,
//          Avatar, ScopeDot, CatIcon, Sheet, TopBar, Segmented, Toast

const { members: _M, wallets: _W, categories: _C } = window.DK_DATA;

const memberOf = (id) => _M.find(m => m.id === id);
const walletOf = (id) => _W.find(w => w.id === id);
const catOf = (key) => _C.find(c => c.key === key);

// member avatar color (consistent chroma/lightness, vary hue)
const memberColor = (m, kind) => {
  const h = m ? m.hue : 200;
  if (kind === 'tint') return `hsl(${h} 42% 90%)`;
  if (kind === 'tintDark') return `hsl(${h} 30% 24%)`;
  return `hsl(${h} 44% 46%)`;
};

// transaction visual metadata
function txMeta(type) {
  switch (type) {
    case 'income': return { label: 'Pemasukan', color: 'var(--income)', tint: 'var(--income-tint)', icon: 'income', sign: '+' };
    case 'expense': return { label: 'Pengeluaran', color: 'var(--expense)', tint: 'var(--expense-tint)', icon: 'expense', sign: '−' };
    case 'transfer': return { label: 'Transfer', color: 'var(--transfer)', tint: 'var(--transfer-tint)', icon: 'transfer', sign: '' };
    case 'adjustment': return { label: 'Penyesuaian', color: 'var(--adjust)', tint: 'var(--adjust-tint)', icon: 'adjustment', sign: '' };
    default: return { label: type, color: 'var(--text-2)', tint: 'var(--surface-2)', icon: 'dots', sign: '' };
  }
}

const walletTypeLabel = (t) => ({ cash: 'Tunai', bank: 'Bank', ewallet: 'E-Wallet' }[t] || t);
const walletTypeIcon = (t) => ({ cash: 'cash', bank: 'bank', ewallet: 'ewallet' }[t] || 'wallet');

function ownerLabel(w) {
  if (w.scope === 'shared') return 'Bersama';
  const m = memberOf(w.owner);
  return m ? m.name : 'Pribadi';
}

// ── Avatar ──
function Avatar({ id, size = 36, ring = false, dark }) {
  const m = memberOf(id);
  const bg = memberColor(m);
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', flexShrink: 0,
      background: bg, color: '#fff',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontWeight: 700, fontSize: size * 0.4, letterSpacing: '-0.02em',
      boxShadow: ring ? '0 0 0 2.5px var(--surface)' : 'none',
    }}>{m ? m.init : '?'}</div>
  );
}

// scope dot/badge: personal vs shared
function ScopeBadge({ scope, owner }) {
  const shared = scope === 'shared';
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '3px 9px 3px 7px', borderRadius: 100,
      fontSize: 11.5, fontWeight: 600,
      background: shared ? 'var(--primary-tint)' : 'var(--surface-2)',
      color: shared ? 'var(--primary)' : 'var(--text-2)',
    }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: shared ? 'var(--primary)' : 'var(--text-3)' }}></span>
      {shared ? 'Bersama' : 'Pribadi'}
    </span>
  );
}

// ── Category icon chip ──
function CatIcon({ catKey, size = 44, iconSize = 22 }) {
  const c = catOf(catKey);
  const h = c ? c.hue : 200;
  const dark = window.__dkDark;
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.32, flexShrink: 0,
      background: dark ? `hsl(${h} 30% 20%)` : `hsl(${h} 48% 94%)`,
      color: dark ? `hsl(${h} 58% 66%)` : `hsl(${h} 55% 42%)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <Icon name={c ? c.icon : 'dots'} size={iconSize} strokeWidth={1.9} />
    </div>
  );
}

// ── Bottom Sheet ──
function Sheet({ open, onClose, children, height = 'auto', title, full = false }) {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: 60,
      background: 'rgba(8,16,12,0.42)', backdropFilter: 'blur(2px)',
      display: 'flex', alignItems: 'flex-end',
      animation: 'dk-fade .2s ease',
    }}>
      <div onClick={e => e.stopPropagation()} className="sheet-in" style={{
        width: '100%', background: 'var(--surface)',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        maxHeight: full ? '94%' : '88%', height,
        display: 'flex', flexDirection: 'column', overflow: 'hidden',
        boxShadow: '0 -10px 40px rgba(0,0,0,0.2)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 10, flexShrink: 0 }}>
          <div style={{ width: 40, height: 4.5, borderRadius: 3, background: 'var(--border-2)' }}></div>
        </div>
        {title && (
          <div style={{ padding: '12px 22px 6px', fontSize: 18, fontWeight: 700, flexShrink: 0 }}>{title}</div>
        )}
        <div className="dk-scroll" style={{ overflowY: 'auto', flex: 1 }}>{children}</div>
      </div>
    </div>
  );
}

// ── Sub-screen top bar ──
function TopBar({ title, onBack, right, transparent }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 6,
      padding: '8px 12px', minHeight: 56, flexShrink: 0,
      background: transparent ? 'transparent' : 'var(--app-bg)',
    }}>
      {onBack && (
        <button className="tap" onClick={onBack} aria-label="Kembali" style={{
          width: 40, height: 40, borderRadius: '50%', display: 'flex',
          alignItems: 'center', justifyContent: 'center', color: 'var(--text)',
        }}>
          <Icon name="back" size={23} strokeWidth={2} />
        </button>
      )}
      <div style={{ flex: 1, fontSize: 18, fontWeight: 700, paddingLeft: onBack ? 2 : 10 }}>{title}</div>
      {right}
    </div>
  );
}

// ── Segmented control ──
function Segmented({ options, value, onChange, size = 'md' }) {
  return (
    <div style={{
      display: 'flex', gap: 4, padding: 4, borderRadius: 14,
      background: 'var(--surface-2)',
    }}>
      {options.map(o => {
        const active = o.value === value;
        return (
          <button key={o.value} className="tap" onClick={() => onChange(o.value)} style={{
            flex: 1, padding: size === 'sm' ? '7px 4px' : '10px 6px', borderRadius: 11,
            fontSize: size === 'sm' ? 13 : 14, fontWeight: 600,
            color: active ? (o.color || 'var(--text)') : 'var(--text-2)',
            background: active ? 'var(--surface)' : 'transparent',
            boxShadow: active ? 'var(--shadow-sm)' : 'none',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          }}>{o.icon && <Icon name={o.icon} size={16} strokeWidth={2} />}{o.label}</button>
        );
      })}
    </div>
  );
}

Object.assign(window, {
  memberOf, walletOf, catOf, memberColor, txMeta, walletTypeLabel, walletTypeIcon, ownerLabel,
  Avatar, ScopeBadge, CatIcon, Sheet, TopBar, Segmented,
});
