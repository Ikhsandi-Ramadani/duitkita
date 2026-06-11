// icons.jsx — outline (stroke) icon set for DuitKita
// Usage: <Icon name="home" size={24} />  — inherits currentColor, stroke 1.75
// Exposes to window: Icon, ICON_NAMES

const _ICON_PATHS = {
  // ── bottom nav ──
  home: <><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/><path d="M9.5 21v-6h5v6"/></>,
  receipt: <><path d="M5 3h14v18l-2.5-1.6L14 21l-2-1.5L10 21l-2.5-1.6L5 21z"/><path d="M9 8h6"/><path d="M9 12h6"/></>,
  wallet: <><path d="M3 7.5A2.5 2.5 0 0 1 5.5 5H18a1 1 0 0 1 1 1v1"/><path d="M3 7.5V18a2 2 0 0 0 2 2h14a1 1 0 0 0 1-1V9a1 1 0 0 0-1-1H5a2 2 0 0 1-2-2"/><circle cx="16.5" cy="13.5" r="1.2" fill="currentColor" stroke="none"/></>,
  user: <><circle cx="12" cy="8" r="3.5"/><path d="M5 20c0-3.3 3.1-6 7-6s7 2.7 7 6"/></>,
  plus: <><path d="M12 5v14"/><path d="M5 12h14"/></>,

  // ── tx type ──
  income: <><path d="M12 19V6"/><path d="m6 11 6-6 6 6"/></>,
  expense: <><path d="M12 5v13"/><path d="m6 12 6 6 6-6"/></>,
  transfer: <><path d="M4 8h13l-3-3"/><path d="M20 16H7l3 3"/></>,
  adjustment: <><path d="M4 7h11"/><circle cx="18" cy="7" r="2"/><path d="M20 17H9"/><circle cx="6" cy="17" r="2"/></>,

  // ── categories ──
  utensils: <><path d="M6 3v8a2 2 0 0 0 4 0V3"/><path d="M8 11v10"/><path d="M16 3c-1.5 0-2.5 1.5-2.5 4s1 4 2.5 4"/><path d="M16 3v18"/></>,
  car: <><path d="M5 11l1.5-4.5A2 2 0 0 1 8.4 5h7.2a2 2 0 0 1 1.9 1.5L19 11"/><path d="M4 11h16v6H4z"/><circle cx="7.5" cy="17.5" r="1.3" fill="currentColor" stroke="none"/><circle cx="16.5" cy="17.5" r="1.3" fill="currentColor" stroke="none"/></>,
  fuel: <><rect x="4" y="4" width="9" height="16" rx="1.5"/><path d="M4 12h9"/><path d="M16 8l2 2v7a1.5 1.5 0 0 1-3 0v-5"/><path d="M16 7V5"/></>,
  signal: <><rect x="14" y="3" width="7" height="18" rx="1.5"/><path d="M17.5 17.5h.01"/><path d="M3 14a8 8 0 0 1 8 7"/><path d="M3 9a13 13 0 0 1 8 3"/></>,
  bag: <><path d="M5 8h14l-1 12H6z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/></>,
  health: <><path d="M3 12h3l2-5 3 9 2.5-6 1.5 2h6"/></>,
  book: <><path d="M5 4h11a2 2 0 0 1 2 2v14H7a2 2 0 0 0-2 2z"/><path d="M5 4v16"/><path d="M18 18H7"/></>,
  film: <><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 4v16"/><path d="M15 4v16"/><path d="M4 9h5"/><path d="M15 9h5"/><path d="M4 15h5"/><path d="M15 15h5"/></>,
  users: <><circle cx="9" cy="8" r="3"/><path d="M3 19c0-2.8 2.7-5 6-5s6 2.2 6 5"/><path d="M16 6a3 3 0 0 1 0 6"/><path d="M17 14.5c2 .7 3.5 2.4 3.5 4.5"/></>,
  handheart: <><path d="M11 9.5c-1-1.5-3.2-1.3-3.8.4-.5 1.4.6 2.6 1.4 3.3L11 15l2.4-1.8c.8-.7 1.9-1.9 1.4-3.3-.6-1.7-2.8-1.9-3.8-.4Z"/><path d="M3 16l3.5-1.5"/><path d="M3 20l6-2 4 1 7-3a1.3 1.3 0 0 0-1.2-2.2L16 15"/></>,
  dots: <><circle cx="6" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="18" cy="12" r="1.4" fill="currentColor" stroke="none"/></>,
  briefcase: <><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5.5A1.5 1.5 0 0 1 9.5 4h5A1.5 1.5 0 0 1 16 5.5V7"/><path d="M3 12h18"/></>,
  gift: <><rect x="4" y="9" width="16" height="11" rx="1"/><path d="M3 9h18v3H3z"/><path d="M12 9v11"/><path d="M12 9c-1-3-5-3-5-.5 0 1 1 1.5 5 .5Z"/><path d="M12 9c1-3 5-3 5-.5 0 1-1 1.5-5 .5Z"/></>,

  // ── wallet types ──
  bank: <><path d="M4 9 12 4l8 5"/><path d="M4 10h16"/><path d="M6 10v8"/><path d="M10 10v8"/><path d="M14 10v8"/><path d="M18 10v8"/><path d="M3.5 20h17"/></>,
  cash: <><rect x="3" y="6" width="18" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/><path d="M6 9.5v.01"/><path d="M18 14.5v.01"/></>,
  ewallet: <><rect x="6" y="3" width="12" height="18" rx="2.5"/><path d="M10 18h4"/></>,

  // ── ui ──
  search: <><circle cx="11" cy="11" r="6.5"/><path d="m20 20-3.5-3.5"/></>,
  filter: <><path d="M3 5h18l-7 8v6l-4-2v-4z"/></>,
  sliders: <><path d="M4 8h10"/><path d="M18 8h2"/><circle cx="16" cy="8" r="2"/><path d="M4 16h2"/><path d="M10 16h10"/><circle cx="8" cy="16" r="2"/></>,
  chevronright: <><path d="m9 6 6 6-6 6"/></>,
  chevronleft: <><path d="m15 6-6 6 6 6"/></>,
  chevrondown: <><path d="m6 9 6 6 6-6"/></>,
  back: <><path d="M19 12H5"/><path d="m11 6-6 6 6 6"/></>,
  eye: <><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="2.8"/></>,
  eyeoff: <><path d="M4 4l16 16"/><path d="M9.5 9.6A2.8 2.8 0 0 0 12 14.8c.7 0 1.4-.3 1.9-.8"/><path d="M6.7 6.8C3.9 8.3 2 12 2 12s3.5 7 10 7c1.7 0 3.2-.5 4.5-1.2"/><path d="M10 5.2A11 11 0 0 1 12 5c6.5 0 10 7 10 7a18 18 0 0 1-2.4 3.2"/></>,
  fingerprint: <><path d="M12 4a7 7 0 0 1 7 7v3"/><path d="M5 11a7 7 0 0 1 3-5.8"/><path d="M8 11a4 4 0 0 1 8 0v4a2 2 0 0 1-2 2"/><path d="M12 11v5"/><path d="M5 15v2"/></>,
  faceid: <><path d="M5 8V6.5A1.5 1.5 0 0 1 6.5 5H8"/><path d="M16 5h1.5A1.5 1.5 0 0 1 19 6.5V8"/><path d="M19 16v1.5a1.5 1.5 0 0 1-1.5 1.5H16"/><path d="M8 19H6.5A1.5 1.5 0 0 1 5 17.5V16"/><path d="M9 10v1"/><path d="M15 10v1"/><path d="M12 10v3l-1 1"/><path d="M9.5 15c.7.7 1.6 1 2.5 1s1.8-.3 2.5-1"/></>,
  lock: <><rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></>,
  camera: <><path d="M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1Z"/><circle cx="12" cy="13" r="3.2"/></>,
  note: <><path d="M5 4h14v11l-4 4H5z"/><path d="M19 15h-4v4"/><path d="M9 9h6"/><path d="M9 12h4"/></>,
  calendar: <><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M4 9h16"/><path d="M8 3v4"/><path d="M16 3v4"/></>,
  clock: <><circle cx="12" cy="12" r="8"/><path d="M12 8v4l3 2"/></>,
  check: <><path d="m5 12 5 5 9-10"/></>,
  checkcircle: <><circle cx="12" cy="12" r="8.5"/><path d="m8.5 12 2.5 2.5 4.5-5"/></>,
  x: <><path d="M6 6l12 12"/><path d="M18 6 6 18"/></>,
  bell: <><path d="M6 10a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z"/><path d="M10 20a2 2 0 0 0 4 0"/></>,
  shield: <><path d="M12 3 5 6v5c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6Z"/><path d="m9 12 2 2 4-4"/></>,
  edit: <><path d="M5 19h14"/><path d="M14 6l3 3-8 8H6v-3z"/></>,
  trash: <><path d="M4 7h16"/><path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/><path d="M6 7l1 12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-12"/><path d="M10 11v6"/><path d="M14 11v6"/></>,
  share: <><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="m8.2 10.8 7.6-3.6"/><path d="m8.2 13.2 7.6 3.6"/></>,
  qr: <><rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><path d="M14 14h2v2"/><path d="M20 14v6h-6"/><path d="M18 18h2"/></>,
  scan: <><path d="M4 8V6a2 2 0 0 1 2-2h2"/><path d="M16 4h2a2 2 0 0 1 2 2v2"/><path d="M20 16v2a2 2 0 0 1-2 2h-2"/><path d="M8 20H6a2 2 0 0 1-2-2v-2"/><path d="M4 12h16"/></>,
  backspace: <><path d="M9 5h11a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H9l-6-7z"/><path d="m13 9 4 6"/><path d="m17 9-4 6"/></>,
  plusbig: <><path d="M12 4v16"/><path d="M4 12h16"/></>,
  logout: <><path d="M14 4h4a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1h-4"/><path d="M10 12h9"/><path d="m13 8-4 4 4 4"/></>,
  moon: <><path d="M20 14A8 8 0 0 1 10 4a7 7 0 1 0 10 10Z"/></>,
  sun: <><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5 19 19M19 5l-1.5 1.5M6.5 17.5 5 19"/></>,
  tag: <><path d="M4 4h7l9 9-7 7-9-9z"/><circle cx="8.5" cy="8.5" r="1.3" fill="currentColor" stroke="none"/></>,
  category: <><rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/></>,
  pin: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
  info: <><circle cx="12" cy="12" r="8.5"/><path d="M12 11v5"/><path d="M12 8h.01"/></>,
  trend: <><path d="M4 17 10 11l3 3 7-7"/><path d="M15 7h5v5"/></>,
  more: <><circle cx="12" cy="6" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="18" r="1.4" fill="currentColor" stroke="none"/></>,
  warning: <><path d="M12 4 2.5 20h19z"/><path d="M12 10v4"/><path d="M12 17h.01"/></>,
  copy: <><rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"/></>,
  arrowright: <><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></>,
  target: <><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="1" fill="currentColor" stroke="none"/></>,
  repeat: <><path d="M17 3l3 3-3 3"/><path d="M20 6H9a4 4 0 0 0-4 4v1"/><path d="M7 21l-3-3 3-3"/><path d="M4 18h11a4 4 0 0 0 4-4v-1"/></>,
  chart: <><path d="M4 4v16h16"/><rect x="7" y="11" width="3" height="6" rx="0.5"/><rect x="12" y="7" width="3" height="10" rx="0.5"/><rect x="17" y="13" width="3" height="4" rx="0.5"/></>,
  coins: <><ellipse cx="9" cy="7" rx="5.5" ry="3"/><path d="M3.5 7v4c0 1.7 2.5 3 5.5 3s5.5-1.3 5.5-3V7"/><path d="M9 14c0 1.7 2.5 3 5.5 3s5.5-1.3 5.5-3v-4"/><path d="M14.5 10c2.7-.2 5-1.4 5-3"/></>,
  flag: <><path d="M5 21V4"/><path d="M5 4h12l-2 3.5L17 11H5"/></>,
  piggy: <><path d="M4 12a6 6 0 0 1 6-6h3a6 6 0 0 1 6 6v1.5l2 1v3l-2 .5-1 2h-3l-.5-1.5H9.5L9 20H6l-.5-2.5A6 6 0 0 1 4 13z"/><circle cx="9" cy="11.5" r="1" fill="currentColor" stroke="none"/><path d="M13 7V5"/></>,
  handshake: <><path d="M11 11l2 2 3-3 4 4-3 3-3-3"/><path d="M11 11 8 8 3 13l3 3 3-3"/><path d="M8 8l3-3 4 1"/></>,
};

function Icon({ name, size = 24, strokeWidth = 1.75, style, fill = false, ...rest }) {
  const path = _ICON_PATHS[name];
  if (!path) return <svg width={size} height={size} viewBox="0 0 24 24" style={style} {...rest}><circle cx="12" cy="12" r="2" fill="currentColor"/></svg>;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round"
      style={{ display: 'block', flexShrink: 0, ...style }} {...rest}>
      {path}
    </svg>
  );
}

window.Icon = Icon;
window.ICON_NAMES = Object.keys(_ICON_PATHS);
