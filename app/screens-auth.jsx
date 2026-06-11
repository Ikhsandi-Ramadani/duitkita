// screens-auth.jsx — App Lock + Login / Onboarding
// Exposes: AppLock, AuthFlow, BrandMark

function BrandMark({ size = 56, onPrimary }) {
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: 11 }}>
      <div style={{
        width: size, height: size, borderRadius: size * 0.32,
        background: onPrimary ? 'rgba(255,255,255,0.16)' : 'var(--primary)',
        border: onPrimary ? '1px solid rgba(255,255,255,0.25)' : 'none',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: '#fff', position: 'relative',
      }}>
        <Icon name="wallet" size={size * 0.5} strokeWidth={2} />
      </div>
    </div>
  );
}

// ── App Lock ──
function AppLock({ onUnlock, onSwitch }) {
  const [pin, setPin] = React.useState('');
  const [err, setErr] = React.useState(false);
  const me = memberOf(window.DK_DATA.ME);

  const push = (d) => {
    if (pin.length >= 6) return;
    const n = pin + d;
    setPin(n);
    if (n.length === 6) {
      setTimeout(() => { onUnlock(); }, 220);
    }
  };
  const back = () => setPin(p => p.slice(0, -1));
  const bio = () => setTimeout(onUnlock, 300);

  const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'bio', '0', 'back'];

  return (
    <div className="screen-in" style={{
      position: 'absolute', inset: 0, zIndex: 90,
      background: 'linear-gradient(165deg, var(--primary-600) 0%, var(--primary-700) 55%, #024c39 100%)',
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      padding: `${STATUS_H + 40}px 32px 36px`, color: '#fff',
    }}>
      <BrandMark size={58} onPrimary />
      <div style={{ fontSize: 22, fontWeight: 800, marginTop: 16, letterSpacing: '-0.01em' }}>DuitKita</div>
      <div style={{ fontSize: 13.5, color: 'rgba(255,255,255,0.78)', marginTop: 4 }}>Keuangan Keluarga Pratama</div>

      {/* avatar + greeting */}
      <div style={{ marginTop: 40, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
        <div style={{ boxShadow: '0 0 0 3px rgba(255,255,255,0.25)', borderRadius: '50%' }}><Avatar id={me.id} size={64} /></div>
        <div style={{ fontSize: 15.5, fontWeight: 600 }}>Halo, {me.name}</div>
      </div>

      <div style={{ fontSize: 13.5, color: 'rgba(255,255,255,0.8)', marginTop: 26 }}>Masukkan PIN kamu</div>
      {/* dots */}
      <div style={{ display: 'flex', gap: 16, marginTop: 16, animation: err ? 'shake .4s' : 'none' }}>
        {[0, 1, 2, 3, 4, 5].map(i => (
          <div key={i} style={{
            width: 13, height: 13, borderRadius: '50%',
            background: i < pin.length ? '#fff' : 'transparent',
            border: '1.5px solid rgba(255,255,255,0.6)',
            transition: 'background .15s',
          }}></div>
        ))}
      </div>

      <div style={{ flex: 1 }}></div>

      {/* keypad */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 14, width: '100%', maxWidth: 290, justifyItems: 'center' }}>
        {keys.map(k => {
          if (k === 'bio') return (
            <button key="bio" className="tap" onClick={bio} aria-label="Biometrik" style={{ width: 72, height: 72, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
              <Icon name="fingerprint" size={30} strokeWidth={1.8} />
            </button>
          );
          if (k === 'back') return (
            <button key="back" className="tap" onClick={back} aria-label="Hapus" style={{ width: 72, height: 72, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
              <Icon name="backspace" size={28} strokeWidth={1.8} />
            </button>
          );
          return (
            <button key={k} className="tap" onClick={() => push(k)} style={{
              width: 72, height: 72, borderRadius: '50%', background: 'rgba(255,255,255,0.13)',
              border: '1px solid rgba(255,255,255,0.12)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 26, fontWeight: 600, color: '#fff',
            }}><span className="num">{k}</span></button>
          );
        })}
      </div>

      <button className="tap" onClick={onSwitch} style={{ marginTop: 22, fontSize: 13.5, color: 'rgba(255,255,255,0.82)', fontWeight: 600 }}>
        Bukan {me.name}? Ganti akun
      </button>
    </div>
  );
}

// ── Login / Onboarding ──
function AuthFlow({ onDone }) {
  const [mode, setMode] = React.useState('login'); // login | create | join
  return (
    <div className="screen-in" style={{
      position: 'absolute', inset: 0, zIndex: 90, background: 'var(--app-bg)',
      display: 'flex', flexDirection: 'column',
    }}>
      {mode === 'login' && <LoginView onDone={onDone} go={setMode} />}
      {mode === 'create' && <CreateView onDone={onDone} back={() => setMode('login')} />}
      {mode === 'join' && <JoinView onDone={onDone} back={() => setMode('login')} />}
    </div>
  );
}

function TextField({ label, type = 'text', value, onChange, placeholder, icon }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-2)', marginBottom: 7 }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 52, borderRadius: 14, background: 'var(--surface)', border: '1px solid var(--border-2)', padding: '0 14px' }}>
        {icon && <Icon name={icon} size={19} style={{ color: 'var(--text-3)' }} />}
        <input type={type} value={value} onChange={e => onChange(e.target.value)} placeholder={placeholder} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontSize: 15, color: 'var(--text)' }} />
      </div>
    </div>
  );
}

function LoginView({ onDone, go }) {
  const [email, setEmail] = React.useState('budi@keluarga.id');
  const [pass, setPass] = React.useState('••••••••');
  return (
    <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: `${STATUS_H + 40}px 26px 36px` }}>
      <BrandMark size={56} />
      <div style={{ fontSize: 27, fontWeight: 800, marginTop: 22, letterSpacing: '-0.02em' }}>Masuk ke DuitKita</div>
      <div style={{ fontSize: 14.5, color: 'var(--text-2)', marginTop: 6, marginBottom: 28 }}>Kelola keuangan keluarga dalam satu tempat.</div>

      <TextField label="Email" value={email} onChange={setEmail} icon="user" placeholder="nama@email.com" />
      <TextField label="Kata sandi" type="password" value={pass} onChange={setPass} icon="lock" placeholder="••••••••" />
      <button className="tap" style={{ float: 'right', fontSize: 13, fontWeight: 600, color: 'var(--primary)', marginBottom: 18 }}>Lupa sandi?</button>

      <button className="tap" onClick={onDone} style={{ width: '100%', height: 54, borderRadius: 16, background: 'var(--primary)', color: 'var(--on-primary)', fontSize: 16, fontWeight: 700, boxShadow: 'var(--shadow)' }}>Masuk</button>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '26px 0' }}>
        <div style={{ flex: 1, height: 1, background: 'var(--border-2)' }}></div>
        <span style={{ fontSize: 12.5, color: 'var(--text-3)', fontWeight: 600 }}>Pertama kali pakai?</span>
        <div style={{ flex: 1, height: 1, background: 'var(--border-2)' }}></div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <button className="tap" onClick={() => go('create')} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: 16, borderRadius: 16, background: 'var(--surface)', border: '1px solid var(--border-2)', textAlign: 'left' }}>
          <span style={{ width: 44, height: 44, borderRadius: 13, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="users" size={22} /></span>
          <span style={{ flex: 1 }}><span style={{ display: 'block', fontSize: 15, fontWeight: 700 }}>Buat Keluarga Baru</span><span style={{ fontSize: 12.5, color: 'var(--text-3)' }}>Jadi pengelola keuangan keluarga</span></span>
          <Icon name="chevronright" size={19} style={{ color: 'var(--text-3)' }} />
        </button>
        <button className="tap" onClick={() => go('join')} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: 16, borderRadius: 16, background: 'var(--surface)', border: '1px solid var(--border-2)', textAlign: 'left' }}>
          <span style={{ width: 44, height: 44, borderRadius: 13, background: 'var(--surface-2)', color: 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="qr" size={22} /></span>
          <span style={{ flex: 1 }}><span style={{ display: 'block', fontSize: 15, fontWeight: 700 }}>Gabung Keluarga</span><span style={{ fontSize: 12.5, color: 'var(--text-3)' }}>Pakai kode undangan dari keluargamu</span></span>
          <Icon name="chevronright" size={19} style={{ color: 'var(--text-3)' }} />
        </button>
      </div>
    </div>
  );
}

function CreateView({ onDone, back }) {
  const [name, setName] = React.useState('');
  const [fam, setFam] = React.useState('');
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title="Buat Keluarga Baru" onBack={back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '10px 26px 30px' }}>
        <div style={{ fontSize: 14.5, color: 'var(--text-2)', lineHeight: 1.5, marginBottom: 24 }}>Kamu akan jadi <b style={{ color: 'var(--text)' }}>owner</b> — bisa mengundang anggota, membuat kas bersama, dan mengatur kategori.</div>
        <TextField label="Nama kamu" value={name} onChange={setName} icon="user" placeholder="Mis. Budi" />
        <TextField label="Nama keluarga" value={fam} onChange={setFam} icon="users" placeholder="Mis. Keluarga Pratama" />
        <div style={{ marginTop: 8, padding: 15, borderRadius: 14, background: 'var(--primary-tint)', display: 'flex', gap: 11 }}>
          <span style={{ color: 'var(--primary)', flexShrink: 0 }}><Icon name="info" size={20} /></span>
          <span style={{ fontSize: 13, color: 'var(--primary-700)', lineHeight: 1.5 }}>Setelah dibuat, kamu dapat <b>kode undangan</b> untuk dibagikan ke anggota keluarga.</span>
        </div>
      </div>
      <div style={{ padding: '14px 26px 26px' }}>
        <button className="tap" onClick={onDone} style={{ width: '100%', height: 54, borderRadius: 16, background: 'var(--primary)', color: 'var(--on-primary)', fontSize: 16, fontWeight: 700, boxShadow: 'var(--shadow)' }}>Buat & Mulai</button>
      </div>
    </div>
  );
}

function JoinView({ onDone, back }) {
  const [code, setCode] = React.useState(['', '', '', '', '', '']);
  const set = (i, v) => { const n = [...code]; n[i] = v.slice(-1).toUpperCase(); setCode(n); };
  const filled = code.every(c => c);
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: STATUS_H }}><TopBar title="Gabung Keluarga" onBack={back} /></div>
      <div className="dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: '10px 26px 30px' }}>
        <div style={{ fontSize: 14.5, color: 'var(--text-2)', lineHeight: 1.5, marginBottom: 26 }}>Masukkan <b style={{ color: 'var(--text)' }}>kode undangan</b> 6 digit dari pengelola keluargamu.</div>
        <div style={{ display: 'flex', gap: 9, justifyContent: 'space-between' }}>
          {code.map((c, i) => (
            <input key={i} value={c} onChange={e => set(i, e.target.value)} maxLength={1} style={{
              width: 46, height: 58, borderRadius: 14, textAlign: 'center', fontSize: 24, fontWeight: 800,
              border: '1.5px solid ' + (c ? 'var(--primary)' : 'var(--border-2)'), background: 'var(--surface)',
              color: 'var(--text)', outline: 'none',
            }} className="num" />
          ))}
        </div>
        <div style={{ textAlign: 'center', marginTop: 22, fontSize: 13, color: 'var(--text-3)' }}>Belum punya kode? Minta ke owner keluarga.</div>
      </div>
      <div style={{ padding: '14px 26px 26px' }}>
        <button className="tap" onClick={onDone} disabled={!filled} style={{ width: '100%', height: 54, borderRadius: 16, background: filled ? 'var(--primary)' : 'var(--surface-2)', color: filled ? 'var(--on-primary)' : 'var(--text-3)', fontSize: 16, fontWeight: 700 }}>Gabung Keluarga</button>
      </div>
    </div>
  );
}

Object.assign(window, { AppLock, AuthFlow, BrandMark });
