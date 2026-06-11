// frame.jsx — phone shell, status bar, bottom nav, FAB
// Exposes: PhoneFrame, StatusBar, BottomNav, useFitScale, STATUS_H, NAV_H

const STATUS_H = 46;
const NAV_H = 76;

// fit a fixed W×H stage into the viewport
function useFitScale(W, H, pad = 24) {
  const [scale, setScale] = React.useState(1);
  React.useEffect(() => {
    const fit = () => {
      const sw = (window.innerWidth - pad * 2) / W;
      const sh = (window.innerHeight - pad * 2) / H;
      setScale(Math.min(1, sw, sh));
    };
    fit();
    window.addEventListener('resize', fit);
    return () => window.removeEventListener('resize', fit);
  }, [W, H, pad]);
  return scale;
}

function StatusBar({ light }) {
  const c = light ? '#ffffff' : 'var(--text)';
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: STATUS_H, zIndex: 100,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 22px', pointerEvents: 'none',
    }}>
      <span className="num" style={{ fontSize: 14.5, fontWeight: 700, color: c, letterSpacing: '0.01em' }}>9:30</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: c }}>
        {/* signal */}
        <svg width="17" height="13" viewBox="0 0 17 13" fill={c}><rect x="0" y="9" width="3" height="4" rx="1"/><rect x="4.5" y="6" width="3" height="7" rx="1"/><rect x="9" y="3" width="3" height="10" rx="1"/><rect x="13.5" y="0" width="3" height="13" rx="1"/></svg>
        {/* wifi */}
        <svg width="16" height="13" viewBox="0 0 16 13" fill={c}><path d="M8 12.5 5.3 9.6a3.8 3.8 0 0 1 5.4 0L8 12.5Z"/><path d="M8 6.2c1.9 0 3.7.8 5 2.1l1.4-1.5A9.1 9.1 0 0 0 8 4 9.1 9.1 0 0 0 1.6 6.8L3 8.3A7.1 7.1 0 0 1 8 6.2Z" opacity="0.95"/></svg>
        {/* battery */}
        <svg width="26" height="13" viewBox="0 0 26 13" fill="none"><rect x="0.5" y="0.5" width="22" height="12" rx="3.5" stroke={c} opacity="0.5"/><rect x="2.5" y="2.5" width="15" height="8" rx="2" fill={c}/><rect x="24" y="4" width="2" height="5" rx="1" fill={c} opacity="0.5"/></svg>
      </div>
    </div>
  );
}

const PhoneFrame = React.forwardRef(function PhoneFrame({ children, statusLight, dark, nav, fab }, ref) {
  const W = 390, H = 846;
  const scale = useFitScale(W, H, 26);
  return (
    <div style={{
      position: 'fixed', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: dark ? '#070b09' : '#dfe5e1',
      backgroundImage: dark
        ? 'radial-gradient(circle at 50% 0%, #14201a 0%, #070b09 70%)'
        : 'radial-gradient(circle at 50% 0%, #eef2ef 0%, #d6ddd8 75%)',
    }}>
      <div style={{ width: W * scale, height: H * scale }}>
        <div ref={ref} className="dk" data-dark={dark ? 'true' : 'false'} style={{
          width: W, height: H, transform: `scale(${scale})`, transformOrigin: 'top left',
          position: 'relative', borderRadius: 46, overflow: 'hidden',
          background: 'var(--app-bg)',
          border: dark ? '9px solid #1c2622' : '9px solid #111714',
          boxShadow: '0 40px 90px rgba(0,0,0,0.34), 0 8px 24px rgba(0,0,0,0.2)',
        }}>
          <StatusBar light={statusLight} />
          {/* content */}
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
            {children}
          </div>
          {fab}
          {nav}
        </div>
      </div>
    </div>
  );
});

const NAV_ITEMS = [
  { id: 'home', label: 'Beranda', icon: 'home' },
  { id: 'txlist', label: 'Transaksi', icon: 'receipt' },
  { id: '_fab', label: '', icon: 'plus' },
  { id: 'wallet', label: 'Dompet', icon: 'wallet' },
  { id: 'profile', label: 'Profil', icon: 'user' },
];

function BottomNav({ active, onTab, onAdd }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 30,
      height: NAV_H, paddingBottom: 14,
      background: 'var(--surface)',
      borderTop: '1px solid var(--border)',
      boxShadow: '0 -6px 24px rgba(0,0,0,0.05)',
      display: 'flex', alignItems: 'flex-start',
    }}>
      {NAV_ITEMS.map(item => {
        if (item.id === '_fab') {
          return (
            <div key="_fab" style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
              <button className="tap" onClick={onAdd} aria-label="Tambah transaksi" style={{
                width: 60, height: 60, borderRadius: 22, marginTop: -22,
                background: 'var(--primary)', color: 'var(--on-primary)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: 'var(--shadow-primary)',
              }}>
                <Icon name="plus" size={30} strokeWidth={2.4} />
              </button>
            </div>
          );
        }
        const on = active === item.id;
        return (
          <button key={item.id} className="tap" onClick={() => onTab(item.id)} style={{
            flex: 1, paddingTop: 12, display: 'flex', flexDirection: 'column',
            alignItems: 'center', gap: 4, color: on ? 'var(--primary)' : 'var(--text-3)',
          }}>
            <Icon name={item.icon} size={24} strokeWidth={on ? 2.3 : 1.9} />
            <span style={{ fontSize: 11, fontWeight: on ? 700 : 600 }}>{item.label}</span>
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, { PhoneFrame, StatusBar, BottomNav, useFitScale, STATUS_H, NAV_H });
