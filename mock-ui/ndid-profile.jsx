// GridTokenX — NDID Verified Identity page (screen 14).
// Displayed after NDID approval: citizen ID, name, DOB, issuer, KYC level.
// Interactive: privacy mask toggle per field, re-verify CTA.
// Exports NDIDProfile to window.

const NV = {
  bg: '#0B0712',
  hair: 'rgba(255,255,255,0.08)',
  surface: 'rgba(255,255,255,0.045)',
  surface2: 'rgba(255,255,255,0.07)',
  border: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.5)',
  faint: 'rgba(244,241,250,0.3)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  up: '#2FD08A',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function VIcon({ d, c = NV.text, s = 18, sw = 1.8 }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const VP = {
  back: 'M15 6l-6 6 6 6',
  tick: 'M4 12.5l5 5 11-12',
  shield: 'M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z',
  shieldCheck: 'M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3zM9 11.5l2 2 4-4',
  eye: 'M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7zM12 9a3 3 0 100 6 3 3 0 000-6z',
  eyeOff: 'M17.9 17.9A10.9 10.9 0 0112 19c-7 0-11-7-11-7a18.5 18.5 0 015.1-5.9M9.9 4.2A11 11 0 0112 4c7 0 11 7 11 7a18.5 18.5 0 01-2.2 2.9M1 1l22 22',
  refresh: 'M23 4v6h-6M1 20v-6h6M3.5 9A9 9 0 0121 12.5M20.5 15A9 9 0 013 11.5',
  bank: 'M4 9h16M5 9l7-5 7 5M6 9v8M10 9v8M14 9v8M18 9v8M4 20h16',
  copy: 'M9 9h10v10H9zM5 15V5h10',
  chev: 'M9 6l6 6-6 6',
};

// Thai bank used for verification
const IDP = { name: 'KBank', full: 'Kasikornbank', c: '#2FAE4A' };

function MaskToggle({ masked, onToggle }) {
  return (
    <button onClick={onToggle} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center' }}>
      <VIcon d={masked ? VP.eyeOff : VP.eye} c={NV.faint} s={17} sw={1.7} />
    </button>
  );
}

function DataRow({ label, value, masked, onToggle, mono, last, copy }) {
  const display = masked ? value.replace(/[^\s\-/]/g, '•') : value;
  return (
    <div style={{ position: 'relative' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '13px 0' }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 11.5, color: NV.faint, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4, fontWeight: 600 }}>{label}</div>
          <div style={{ fontSize: 16, fontWeight: 600, fontFamily: mono ? NV.mono : NV.font, letterSpacing: mono ? 1 : 0, color: NV.text }}>{display}</div>
        </div>
        <div style={{ display: 'flex', gap: 4 }}>
          {copy && !masked && <button style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4 }}><VIcon d={VP.copy} c={NV.faint} s={17} sw={1.7} /></button>}
          {onToggle && <MaskToggle masked={masked} onToggle={onToggle} />}
        </div>
      </div>
      {!last && <div style={{ height: 1, background: NV.hair }} />}
    </div>
  );
}

function NDIDProfile() {
  const [masked, setMasked] = React.useState({ id: true, dob: true, phone: true, name: false });
  const toggle = (k) => setMasked(m => ({ ...m, [k]: !m[k] }));
  const anyHidden = masked.id || masked.dob || masked.phone || masked.name;
  const toggleAll = () => { const v = anyHidden ? false : true; setMasked({ id: v, dob: v, phone: v, name: v }); };

  return (
    <div style={{ position: 'absolute', inset: 0, background: NV.bg, fontFamily: NV.font, color: NV.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 20px 6px', display: 'flex', alignItems: 'center', gap: 13 }}>
        <VIcon d={VP.back} c={NV.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 17, fontWeight: 650 }}>Verified identity</span>
        <button onClick={toggleAll} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 11px', borderRadius: 999, border: `1px solid ${NV.border}`, background: NV.surface, cursor: 'pointer', color: NV.violetSoft, fontFamily: NV.font, fontSize: 12.5, fontWeight: 600 }}>
          <VIcon d={anyHidden ? VP.eye : VP.eyeOff} c={NV.violetSoft} s={15} sw={1.8} />{anyHidden ? 'Show' : 'Hide'}
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 20px 28px', display: 'flex', flexDirection: 'column', gap: 20 }}>

        {/* identity card hero */}
        <div style={{ borderRadius: 22, padding: '20px 20px', background: NV.grad, boxShadow: '0 14px 40px rgba(124,58,237,0.4)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -40, right: -24, width: 160, height: 160, borderRadius: '50%', background: 'rgba(255,255,255,0.1)' }} />
          <div style={{ position: 'absolute', bottom: -50, left: -30, width: 130, height: 130, borderRadius: '50%', background: 'rgba(255,255,255,0.07)' }} />
          {/* guilloché security pattern */}
          <svg viewBox="0 0 200 200" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.14, pointerEvents: 'none' }}>
            {[0,1,2,3,4,5,6,7].map(i => <ellipse key={i} cx={100 + i*6} cy={100} rx={92 - i*9} ry={64 - i*6} fill="none" stroke="#fff" strokeWidth="0.6" transform={`rotate(${i*7} 100 100)`} />)}
          </svg>
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
              <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 1, color: 'rgba(255,255,255,0.85)' }}>NATIONAL DIGITAL ID</div>
              <span style={{ fontSize: 11, fontWeight: 700, padding: '4px 9px', borderRadius: 999, background: 'rgba(255,255,255,0.22)', color: '#fff' }}>🇹🇭 THAILAND</span>
            </div>
            {/* avatar */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <div style={{ width: 54, height: 54, borderRadius: '50%', background: 'rgba(255,255,255,0.22)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 700, color: '#fff', flexShrink: 0 }}>MC</div>
              <div>
                <div style={{ fontSize: 19, fontWeight: 750, letterSpacing: -0.3 }}>Maya Chen</div>
                <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.78)', marginTop: 2 }}>เมย่า เฉิน</div>
              </div>
            </div>
            {/* verified chip */}
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 16, padding: '6px 12px', borderRadius: 999, background: 'rgba(47,208,138,0.25)', border: '1px solid rgba(47,208,138,0.45)' }}>
              <VIcon d={VP.tick} c="#2FD08A" s={13} sw={2.6} />
              <span style={{ fontSize: 12.5, fontWeight: 700, color: '#fff' }}>KYC verified · Full settlement</span>
            </div>
            {/* issued / valid */}
            <div style={{ display: 'flex', gap: 22, marginTop: 16 }}>
              <div><div style={{ fontSize: 9, letterSpacing: 1, color: 'rgba(255,255,255,0.6)', fontWeight: 700 }}>ISSUED</div><div style={{ fontSize: 13, fontWeight: 600, fontFamily: NV.mono, marginTop: 2 }}>18 Jun 2026</div></div>
              <div><div style={{ fontSize: 9, letterSpacing: 1, color: 'rgba(255,255,255,0.6)', fontWeight: 700 }}>VALID THRU</div><div style={{ fontSize: 13, fontWeight: 600, fontFamily: NV.mono, marginTop: 2 }}>06/29</div></div>
            </div>
          </div>
          {/* holographic seal */}
          <div style={{ position: 'absolute', bottom: 16, right: 16, width: 46, height: 46, borderRadius: '50%', background: 'conic-gradient(from 0deg, #C9B4FF, #A974FF, #7CA8FF, #2FD08A, #C9B4FF)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.3)' }}>
            <div style={{ width: 38, height: 38, borderRadius: '50%', background: 'rgba(124,58,237,0.55)', backdropFilter: 'blur(2px)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <VIcon d={VP.shieldCheck} c="#fff" s={22} sw={1.8} />
            </div>
          </div>
        </div>

        {/* citizen data */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: NV.faint, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 }}>Identity data</div>
          <div style={{ borderRadius: 18, background: NV.surface, border: `1px solid ${NV.border}`, padding: '0 16px' }}>
            <DataRow label="Citizen ID" value="1-2345-67890-12-3" masked={masked.id} onToggle={() => toggle('id')} mono copy />
            <DataRow label="Full name (English)" value="Maya Chen" masked={masked.name} onToggle={() => toggle('name')} />
            <DataRow label="Full name (Thai)" value="เมย่า เฉิน" masked={masked.name} />
            <DataRow label="Date of birth" value="12 / 08 / 1990" masked={masked.dob} onToggle={() => toggle('dob')} mono />
            <DataRow label="Phone number" value="+66 89 123 4567" masked={masked.phone} onToggle={() => toggle('phone')} mono last />
          </div>
        </div>

        {/* verification details */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: NV.faint, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 }}>Verification details</div>
          <div style={{ borderRadius: 18, background: NV.surface, border: `1px solid ${NV.border}`, overflow: 'hidden' }}>
            {[
              ['Identity provider', <span style={{ display: 'flex', alignItems: 'center', gap: 7 }}><VIcon d={VP.bank} c={IDP.c} s={15} sw={1.8} />{IDP.full}</span>],
              ['Verified on', '18 Jun 2026'],
              ['KYC level', <span style={{ color: NV.violetSoft, fontWeight: 700 }}>Level 2 — Full settlement</span>],
              ['NDID ref', <span style={{ fontFamily: NV.mono, fontSize: 13 }}>NDID-8F4A2E91</span>],
            ].map(([l, v], i, a) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', padding: '13px 16px', borderTop: i ? `1px solid ${NV.hair}` : 'none' }}>
                <span style={{ flex: 1, fontSize: 14, color: NV.muted }}>{l}</span>
                <span style={{ fontSize: 14, fontWeight: 600, textAlign: 'right' }}>{v}</span>
              </div>
            ))}
          </div>
        </div>

        {/* unlocked features */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: NV.faint, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 }}>Unlocked</div>
          <div style={{ borderRadius: 18, background: NV.surface, border: `1px solid ${NV.border}`, overflow: 'hidden' }}>
            {['THB bank withdrawals', 'Settlement up to ฿200,000/mo', 'On-chain identity proof'].map((l, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 16px', borderTop: i ? `1px solid ${NV.hair}` : 'none' }}>
                <VIcon d={VP.tick} c={NV.up} s={16} sw={2.2} />
                <span style={{ fontSize: 14.5 }}>{l}</span>
              </div>
            ))}
          </div>
        </div>

        {/* re-verify row */}
        <button style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, height: 48, borderRadius: 14, border: `1px solid ${NV.border}`, background: 'none', cursor: 'pointer', color: NV.muted, fontFamily: NV.font, fontSize: 14.5, fontWeight: 600 }}>
          <VIcon d={VP.refresh} c={NV.faint} s={17} sw={1.9} />
          Re-verify identity
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { NDIDProfile });
