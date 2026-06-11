// screens-profile.jsx — Profil / Pengaturan
// Exposes: ProfileScreen

function SettingRow({ icon, label, value, onClick, danger, toggle, toggleOn, onToggle, last, lock }) {
  const color = danger ? 'var(--expense)' : 'var(--text)';
  return (
    <div className="tap" onClick={toggle ? onToggle : onClick} style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: '13px 0', cursor: 'pointer',
      borderBottom: last ? 'none' : '1px solid var(--border)',
    }}>
      <span style={{ width: 36, height: 36, borderRadius: 11, background: danger ? 'var(--expense-tint)' : 'var(--surface-2)', color: danger ? 'var(--expense)' : 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon name={icon} size={19} strokeWidth={1.9} />
      </span>
      <span style={{ flex: 1, fontSize: 15, fontWeight: 600, color }}>{label}</span>
      {lock && <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-3)', background: 'var(--surface-2)', padding: '3px 8px', borderRadius: 8 }}>Owner</span>}
      {value && <span style={{ fontSize: 13.5, color: 'var(--text-3)', fontWeight: 600 }}>{value}</span>}
      {toggle ? (
        <span style={{ width: 46, height: 28, borderRadius: 16, background: toggleOn ? 'var(--primary)' : 'var(--border-2)', position: 'relative', transition: 'background .2s', flexShrink: 0 }}>
          <span style={{ position: 'absolute', top: 3, left: toggleOn ? 21 : 3, width: 22, height: 22, borderRadius: '50%', background: '#fff', transition: 'left .2s', boxShadow: '0 1px 3px rgba(0,0,0,0.2)' }}></span>
        </span>
      ) : (!value && !danger && <Icon name="chevronright" size={18} style={{ color: 'var(--text-3)' }} />)}
    </div>
  );
}

function SectionCard({ title, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      {title && <div style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--text-3)', padding: '0 4px 8px' }}>{title}</div>}
      <div className="card" style={{ padding: '2px 16px', border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)' }}>{children}</div>
    </div>
  );
}

function ProfileScreen({ dark, onToggleDark, onLogout, nav }) {
  const me = memberOf(window.DK_DATA.ME);
  const members = window.DK_DATA.members;
  const [invite, setInvite] = React.useState(false);

  return (
    <div className="screen-in dk-scroll" style={{ flex: 1, overflowY: 'auto', padding: `${STATUS_H + 8}px 20px 110px` }}>
      <div style={{ fontSize: 24, fontWeight: 800, letterSpacing: '-0.02em', marginBottom: 18 }}>Profil</div>

      {/* profile card */}
      <div className="card" style={{ padding: 18, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', display: 'flex', alignItems: 'center', gap: 15, marginBottom: 18 }}>
        <Avatar id={me.id} size={60} />
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ fontSize: 18, fontWeight: 800 }}>{me.full}</span>
            <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--primary)', background: 'var(--primary-tint)', padding: '3px 8px', borderRadius: 8 }}>Owner</span>
          </div>
          <div style={{ fontSize: 13.5, color: 'var(--text-3)', marginTop: 3 }}>{me.email}</div>
        </div>
        <button className="tap" onClick={() => {}} style={{ width: 38, height: 38, borderRadius: '50%', background: 'var(--surface-2)', color: 'var(--text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="edit" size={18} /></button>
      </div>

      {/* household / members */}
      <div className="card" style={{ padding: 17, border: '1px solid var(--border)', boxShadow: 'var(--shadow-sm)', marginBottom: 18 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ width: 38, height: 38, borderRadius: 12, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="users" size={20} /></span>
            <div><div style={{ fontSize: 15.5, fontWeight: 700 }}>Keluarga Pratama</div><div style={{ fontSize: 12.5, color: 'var(--text-3)' }}>{members.length} anggota</div></div>
          </div>
          <button className="tap" onClick={() => setInvite(true)} style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '7px 12px', borderRadius: 11, background: 'var(--primary-tint)', color: 'var(--primary)', fontWeight: 700, fontSize: 13 }}><Icon name="plus" size={15} strokeWidth={2.4} /> Undang</button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {members.map((m, i) => (
            <div key={m.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '9px 0', borderTop: i ? '1px solid var(--border)' : 'none' }}>
              <Avatar id={m.id} size={36} />
              <span style={{ flex: 1, fontSize: 14.5, fontWeight: 600 }}>{m.name}{m.id === me.id ? ' (kamu)' : ''}</span>
              <span style={{ fontSize: 12, fontWeight: 600, color: m.role === 'owner' ? 'var(--primary)' : 'var(--text-3)' }}>{m.role === 'owner' ? 'Owner' : 'Anggota'}</span>
            </div>
          ))}
        </div>
      </div>

      <SectionCard title="AKUN">
        <SettingRow icon="user" label="Edit profil" />
        <SettingRow icon="pin" label="Ganti PIN" />
        <SettingRow icon="shield" label="Keamanan & biometrik" last />
      </SectionCard>

      <SectionCard title="KELOLA KELUARGA">
        <SettingRow icon="users" label="Kelola anggota" lock />
        <SettingRow icon="category" label="Kelola kategori" lock />
        <SettingRow icon="wallet" label="Kelola dompet" lock last />
      </SectionCard>

      <SectionCard title="APLIKASI">
        <SettingRow icon={dark ? 'moon' : 'sun'} label="Mode gelap" toggle toggleOn={dark} onToggle={onToggleDark} />
        <SettingRow icon="bell" label="Notifikasi" value="Aktif" />
        <SettingRow icon="info" label="Tentang DuitKita" value="v1.4" last />
      </SectionCard>

      <button className="tap" onClick={onLogout} style={{ width: '100%', height: 52, borderRadius: 16, background: 'var(--expense-tint)', color: 'var(--expense)', fontWeight: 700, fontSize: 15, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
        <Icon name="logout" size={20} /> Keluar
      </button>

      {/* invite sheet */}
      <Sheet open={invite} onClose={() => setInvite(false)} title="Undang anggota keluarga">
        <div style={{ padding: '6px 22px 30px', textAlign: 'center' }}>
          <p style={{ fontSize: 14, color: 'var(--text-2)', lineHeight: 1.5, marginTop: 0 }}>Bagikan kode ini agar anggota keluarga bisa gabung.</p>
          <div style={{ display: 'flex', gap: 9, justifyContent: 'center', margin: '18px 0' }}>
            {'PRT4K9'.split('').map((c, i) => (
              <span key={i} className="num" style={{ width: 44, height: 56, borderRadius: 13, background: 'var(--primary-tint)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, fontWeight: 800 }}>{c}</span>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 12 }}>
            <button className="tap" style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--surface-2)', color: 'var(--text)', fontWeight: 700, fontSize: 14.5, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}><Icon name="copy" size={18} /> Salin</button>
            <button className="tap" style={{ flex: 1, height: 50, borderRadius: 15, background: 'var(--primary)', color: 'var(--on-primary)', fontWeight: 700, fontSize: 14.5, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}><Icon name="share" size={18} /> Bagikan</button>
          </div>
        </div>
      </Sheet>
    </div>
  );
}

window.ProfileScreen = ProfileScreen;
