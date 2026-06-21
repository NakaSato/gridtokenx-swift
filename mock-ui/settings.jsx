// GridTokenX — mobile Settings page with live Dark/Light theme.
// Exports SettingsPage + ThemedSettings (manages theme + device chrome) to window.

const SET_DARK = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  border: 'rgba(255,255,255,0.08)',
  rowSep: 'rgba(255,255,255,0.07)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.5)',
  faint: 'rgba(244,241,250,0.3)',
  link: '#C9B4FF',
  seg: 'rgba(255,255,255,0.06)',
};
const SET_LIGHT = {
  bg: '#EEE9F6',
  surface: '#FFFFFF',
  border: 'rgba(24,14,46,0.08)',
  rowSep: 'rgba(24,14,46,0.07)',
  text: '#1B1430',
  muted: 'rgba(27,20,48,0.55)',
  faint: 'rgba(27,20,48,0.32)',
  link: '#7C3AED',
  seg: 'rgba(24,14,46,0.05)',
};
const SET = {
  violet: '#9B6BFF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  down: '#FF5C6C',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

const ThemeCtx = React.createContext(SET_DARK);

function SIcon({ d, c = '#fff', s = 16, sw = 1.9 }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const GG = {
  meter: 'M12 3a9 9 0 00-9 9 9 9 0 003 6.7M12 3a9 9 0 019 9 9 9 0 01-3 6.7M12 12l4-3',
  zone: 'M12 21s7-5.6 7-11a7 7 0 10-14 0c0 5.4 7 11 7 11zM12 11a2 2 0 100-4 2 2 0 000 4z',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  chart: 'M4 19V5M4 19h16M8 15l3-4 3 2 4-6',
  card: 'M3 7h18v10H3zM3 10h18',
  coin: 'M12 3a9 9 0 100 18 9 9 0 000-18zM9 12h6M12 9v6',
  face: 'M4 8V6a2 2 0 012-2h2M16 4h2a2 2 0 012 2v2M20 16v2a2 2 0 01-2 2h-2M8 20H6a2 2 0 01-2-2v-2M9 10h.01M15 10h.01M9 15s1 1.5 3 1.5 3-1.5 3-1.5',
  lock: 'M6 11V8a6 6 0 0112 0v3M5 11h14v9H5z',
  key: 'M15 7a4 4 0 11-3.9 5H7v3H4v-3l3-3h4.1A4 4 0 0115 7z',
  bell: 'M6 9a6 6 0 1112 0c0 5 2 6 2 6H4s2-1 2-6zM10 20a2 2 0 004 0',
  alert: 'M12 8v5M12 16h.01M12 3l9 16H3l9-16z',
  grid: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z',
  moon: 'M20 14a8 8 0 11-9.9-9.9A7 7 0 1020 14z',
  globe: 'M12 3a9 9 0 100 18 9 9 0 000-18zM3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18',
  help: 'M9 9a3 3 0 114 2.8c-.8.4-1 .9-1 1.7M12 17h.01',
  doc: 'M6 3h8l4 4v14H6zM14 3v4h4',
  out: 'M15 12H4M11 8l-4 4 4 4M14 4h4a2 2 0 012 2v12a2 2 0 01-2 2h-4',
  chev: 'M9 6l6 6-6 6',
  back: 'M15 6l-6 6 6 6',
  camera: 'M3 8h3l1.5-2h9L18 8h3v12H3zM12 11a3.5 3.5 0 100 7 3.5 3.5 0 000-7z',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zM4 21a8 8 0 0116 0',
  at: 'M12 8a4 4 0 100 8 4 4 0 000-8zM16 12v1.5a2.5 2.5 0 005 0V12a9 9 0 10-3.5 7.1',
  mail: 'M3 6h18v12H3zM3 7l9 6 9-6',
  phone: 'M7 3h10v18H7zM10 18h4',
  textedit: 'M4 7V5h16v2M9 19h6M12 5v14',
};

// ── Profile edit page (theme-aware) ──
function ProfileEdit({ onBack }) {
  const S = React.useContext(ThemeCtx);
  const [f, setF] = React.useState({
    name: 'Maya Chen', username: 'mayachen', email: 'maya.chen@gmail.com',
    phone: '+66 89 123 4567', bio: 'Solar prosumer in Bangkok, trading clean energy with my neighbours.',
  });
  const set = (k) => (e) => setF(s => ({ ...s, [k]: e.target.value }));

  const Field = ({ icon, label, k, prefix, multiline }) => (
    <div>
      <div style={{ fontSize: 12, fontWeight: 600, color: S.muted, marginBottom: 7, marginLeft: 2 }}>{label}</div>
      <div style={{ display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 10, padding: multiline ? '13px 14px' : '0 14px', minHeight: 50, borderRadius: 13, background: S.surface, border: `1px solid ${S.border}` }}>
        <SIcon d={icon} c={S.muted} s={17} sw={1.8} />
        {prefix && <span style={{ fontSize: 15.5, color: S.muted, fontFamily: SET.font }}>{prefix}</span>}
        {multiline ? (
          <textarea value={f[k]} onChange={set(k)} rows={3} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', color: S.text, fontFamily: SET.font, fontSize: 15.5, resize: 'none', lineHeight: 1.4 }} />
        ) : (
          <input value={f[k]} onChange={set(k)} style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', color: S.text, fontFamily: SET.font, fontSize: 15.5, marginLeft: prefix ? -4 : 0 }} />
        )}
      </div>
    </div>
  );

  return (
    <div style={{ position: 'absolute', inset: 0, background: S.bg, fontFamily: SET.font, color: S.text, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 8px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 11, background: S.surface, border: `1px solid ${S.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <SIcon d={GG.back} c={S.link} s={18} sw={2} />
        </button>
        <span style={{ flex: 1, fontSize: 20, fontWeight: 700, letterSpacing: -0.3 }}>Edit profile</span>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10, padding: '6px 0 4px' }}>
          <div style={{ position: 'relative' }}>
            <div style={{ width: 88, height: 88, borderRadius: '50%', background: SET.grad, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 32, fontWeight: 700, color: '#fff', boxShadow: '0 8px 22px rgba(124,58,237,0.45)' }}>MC</div>
            <div style={{ position: 'absolute', bottom: -2, right: -2, width: 32, height: 32, borderRadius: '50%', background: SET.violet, border: `3px solid ${S.bg}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <SIcon d={GG.camera} c="#fff" s={15} sw={1.8} />
            </div>
          </div>
          <button style={{ background: 'none', border: 'none', cursor: 'pointer', color: S.link, fontFamily: SET.font, fontSize: 14, fontWeight: 600 }}>Change photo</button>
        </div>

        <Field icon={GG.user} label="Display name" k="name" />
        <Field icon={GG.at} label="Username" k="username" prefix="@" />
        <Field icon={GG.mail} label="Email" k="email" />
        <Field icon={GG.phone} label="Phone" k="phone" />
        <Field icon={GG.textedit} label="Bio" k="bio" multiline />

        <div style={{ fontSize: 12, color: S.faint, lineHeight: 1.5, padding: '0 2px' }}>Your role (Prosumer) and verified status come from NDID and can't be edited here.</div>
      </div>

      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${S.rowSep}`, background: S.bg }}>
        <button onClick={onBack} style={{ width: '100%', height: 54, border: 'none', borderRadius: 15, cursor: 'pointer', fontFamily: SET.font, fontSize: 16.5, fontWeight: 700, color: '#fff', background: SET.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)' }}>Save changes</button>
      </div>
    </div>
  );
}

function Toggle({ on, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 50, height: 30, borderRadius: 999, border: 'none', cursor: 'pointer', padding: 2,
      background: on ? SET.grad : 'rgba(140,140,150,0.32)', transition: 'background .2s', flexShrink: 0,
      display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start', alignItems: 'center',
    }}>
      <span style={{ width: 26, height: 26, borderRadius: '50%', background: '#fff', boxShadow: '0 2px 5px rgba(0,0,0,0.3)' }} />
    </button>
  );
}

function MiniSeg({ value, options, onChange }) {
  const S = React.useContext(ThemeCtx);
  return (
    <div style={{ display: 'flex', gap: 3, padding: 3, borderRadius: 10, background: S.seg }}>
      {options.map(([k, l]) => {
        const on = value === k;
        return (
          <button key={k} onClick={() => onChange(k)} style={{
            border: 'none', cursor: 'pointer', padding: '5px 12px', borderRadius: 7,
            fontFamily: SET.font, fontSize: 12.5, fontWeight: 650, transition: 'all .15s',
            background: on ? SET.grad : 'transparent', color: on ? '#fff' : S.muted,
          }}>{l}</button>
        );
      })}
    </div>
  );
}

function Row({ icon, title, detail, toggle, on, onToggle, danger, right, last, onClick }) {
  const S = React.useContext(ThemeCtx);
  return (
    <div style={{ position: 'relative' }}>
      <div onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 14px', minHeight: 52, cursor: onClick ? 'pointer' : 'default' }}>
        {icon && (
          <div style={{ width: 30, height: 30, borderRadius: 8, flexShrink: 0, background: danger ? 'rgba(255,92,108,0.16)' : SET.grad, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <SIcon d={icon} c={danger ? SET.down : '#fff'} s={16} />
          </div>
        )}
        <span style={{ flex: 1, fontSize: 15.5, color: danger ? SET.down : S.text, fontWeight: danger ? 600 : 400 }}>{title}</span>
        {right ? right
          : detail ? (
            <React.Fragment>
              <span style={{ fontSize: 14.5, color: S.muted, fontFamily: /[0-9฿]/.test(detail) ? SET.mono : SET.font }}>{detail}</span>
              <SIcon d={GG.chev} c={S.faint} s={15} sw={2} />
            </React.Fragment>
          )
          : toggle ? <Toggle on={on} onClick={onToggle} />
          : (!danger && <SIcon d={GG.chev} c={S.faint} s={15} sw={2} />)}
      </div>
      {!last && <div style={{ position: 'absolute', left: icon ? 56 : 14, right: 0, bottom: 0, height: 1, background: S.rowSep }} />}
    </div>
  );
}

function Section({ header, children }) {
  const S = React.useContext(ThemeCtx);
  return (
    <div>
      {header && <div style={{ fontSize: 12.5, fontWeight: 600, color: S.muted, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 6px 8px' }}>{header}</div>}
      <div style={{ borderRadius: 18, background: S.surface, border: `1px solid ${S.border}`, overflow: 'hidden', boxShadow: header === undefined ? 'none' : '0 1px 2px rgba(0,0,0,0.04)' }}>{children}</div>
    </div>
  );
}

function SettingsPage({ theme = 'dark', setTheme = () => {} }) {
  const S = theme === 'light' ? SET_LIGHT : SET_DARK;
  const [t, setT] = React.useState({ autoSell: true, faceId: true, fills: true, alerts: false, grid: true });
  const flip = (k) => setT(s => ({ ...s, [k]: !s[k] }));

  const ZONES = [
    ['intra', 'Intra Zone', 'Trade only within your local zone'],
    ['inter', 'Inter Zone', 'Trade across neighbouring zones'],
    ['open', 'Open Market', 'Match with anyone on the grid'],
  ];
  const [zone, setZone] = React.useState('intra');
  const [zonePicker, setZonePicker] = React.useState(false);
  const [editing, setEditing] = React.useState(false);
  const zoneLabel = ZONES.find(z => z[0] === zone)[1];

  return (
    <ThemeCtx.Provider value={S}>
      {editing ? <ProfileEdit onBack={() => setEditing(false)} /> : (
      <div style={{ position: 'absolute', inset: 0, background: S.bg, fontFamily: SET.font, color: S.text, display: 'flex', flexDirection: 'column' }}>
        {/* top bar */}
        <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 8px', display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 38, height: 38, borderRadius: 11, background: S.surface, border: `1px solid ${S.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <SIcon d={GG.out} c={S.link} s={17} sw={2} />
          </div>
          <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Settings</span>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 40px', display: 'flex', flexDirection: 'column', gap: 22 }}>
          {/* profile card */}
          <div onClick={() => setEditing(true)} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 16px', borderRadius: 18, background: S.surface, border: `1px solid ${S.border}`, cursor: 'pointer' }}>
            <div style={{ width: 52, height: 52, borderRadius: '50%', background: SET.grad, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 19, fontWeight: 700, color: '#fff', boxShadow: '0 6px 16px rgba(124,58,237,0.4)' }}>MC</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 17, fontWeight: 700 }}>Maya Chen</div>
              <div style={{ fontSize: 13, color: S.muted, marginTop: 2 }}>Prosumer · Zone 2 · Verified</div>
            </div>
            <SIcon d={GG.chev} c={S.faint} s={16} sw={2} />
          </div>

          <Section header="Energy & grid">
            <Row icon={GG.meter} title="Linked meter" detail="Solar 5.2 kW" />
            <Row icon={GG.zone} title="Trading zone" detail={zoneLabel} onClick={() => setZonePicker(true)} />
            <Row icon={GG.bolt} title="Auto-sell surplus" toggle on={t.autoSell} onToggle={() => flip('autoSell')} />
            <Row icon={GG.chart} title="Default sell price" detail="฿4.50/kWh" last />
          </Section>

          <Section header="Wallet & payments">
            <Row icon={GG.card} title="Payout method" detail="SCB ••4192" />
            <Row icon={GG.coin} title="Currency" detail="THB ฿" />
            <Row icon={GG.bolt} title="Auto-withdraw" detail="Off" last />
          </Section>

          <Section header="Security">
            <Row icon={GG.face} title="Face ID unlock" toggle on={t.faceId} onToggle={() => flip('faceId')} />
            <Row icon={GG.lock} title="Two-factor auth" detail="On" />
            <Row icon={GG.key} title="Recovery phrase" last />
          </Section>

          <Section header="Notifications">
            <Row icon={GG.bell} title="Trade fills" toggle on={t.fills} onToggle={() => flip('fills')} />
            <Row icon={GG.alert} title="Price alerts" toggle on={t.alerts} onToggle={() => flip('alerts')} />
            <Row icon={GG.grid} title="Grid events" toggle on={t.grid} onToggle={() => flip('grid')} last />
          </Section>

          <Section header="Preferences">
            <Row icon={GG.moon} title="Appearance" right={<MiniSeg value={theme} options={[['dark', 'Dark'], ['light', 'Light']]} onChange={setTheme} />} />
            <Row icon={GG.globe} title="Language" detail="English" last />
          </Section>

          <Section header="About">
            <Row icon={GG.help} title="Help & support" />
            <Row icon={GG.doc} title="Terms & privacy" last />
          </Section>

          <Section>
            <Row icon={GG.out} title="Sign out" danger last />
          </Section>

          <div style={{ textAlign: 'center', fontSize: 12, color: S.faint, fontFamily: SET.mono }}>GridTokenX · v2.2.0</div>
        </div>

        {/* Trading zone picker sheet */}
        {zonePicker && (
          <div onClick={() => setZonePicker(false)} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 20, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
            <div onClick={(e) => e.stopPropagation()} style={{ background: S.bg, borderTopLeftRadius: 24, borderTopRightRadius: 24, borderTop: `1px solid ${S.border}`, padding: '10px 16px 32px' }}>
              <div style={{ width: 38, height: 5, borderRadius: 3, background: S.rowSep, margin: '0 auto 14px' }} />
              <div style={{ fontSize: 17, fontWeight: 700, padding: '0 2px 4px' }}>Trading zone</div>
              <div style={{ fontSize: 13, color: S.muted, padding: '0 2px 14px', lineHeight: 1.4 }}>Choose how far your buy & sell orders can reach.</div>
              <div style={{ borderRadius: 16, background: S.surface, border: `1px solid ${S.border}`, overflow: 'hidden' }}>
                {ZONES.map(([k, l, desc], i) => {
                  const on = zone === k;
                  return (
                    <div key={k} onClick={() => { setZone(k); setZonePicker(false); }} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', cursor: 'pointer', borderTop: i ? `1px solid ${S.rowSep}` : 'none' }}>
                      <div style={{ width: 24, height: 24, borderRadius: 7, flexShrink: 0, background: on ? SET.grad : 'rgba(127,127,140,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 800, color: on ? '#fff' : S.muted, fontFamily: SET.mono }}>{i + 1}</div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 15.5, fontWeight: 650, color: S.text }}>{l}</div>
                        <div style={{ fontSize: 12.5, color: S.muted, marginTop: 1 }}>{desc}</div>
                      </div>
                      {on && <SIcon d={GG.check || 'M4 12.5l5 5 11-12'} c={SET.violet} s={20} sw={2.4} />}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
      )}
    </ThemeCtx.Provider>
  );
}

// wrapper that also re-themes the device chrome (status bar + home indicator)
function ThemedSettings() {
  const [theme, setTheme] = React.useState('dark');
  return (
    <window.IOSDevice dark={theme === 'dark'}>
      <SettingsPage theme={theme} setTheme={setTheme} />
    </window.IOSDevice>
  );
}

Object.assign(window, { SettingsPage, ThemedSettings, ProfileEdit });
