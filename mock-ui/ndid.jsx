// GridTokenX — Verify account with NDID (Thai National Digital ID).
// Modern-minimal refactor: whitespace, hairlines, one accent. Unlocks full
// settlement (THB withdrawals). States: select → pending → verified.

const N = {
  bg: '#0B0712',
  hair: 'rgba(255,255,255,0.08)',
  surface: 'rgba(255,255,255,0.04)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.5)',
  faint: 'rgba(244,241,250,0.3)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function NIcon({ d, c = N.text, s = 18, sw = 1.8, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const NP = {
  back: 'M15 6l-6 6 6 6',
  check: 'M5 12l5 5 9-10',
  tick: 'M4 12.5l5 5 11-12',
  bank: 'M4 9h16M5 9l7-5 7 5M6 9v8M10 9v8M14 9v8M18 9v8M4 20h16',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  lock: 'M6 11V8a6 6 0 0112 0v3M5 11h14v9H5z',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zM20 20l-4-4',
  shieldCheck: 'M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3zM9 11.5l2 2 4-4',
};

// Thai bank Identity Providers. Brand colors + monogram fallback.
// Drop official logo files at assets/banks/<id>.svg (or .png) to show real marks.
const BANKS = [
  { id: 'scb', name: 'SCB', full: 'Siam Commercial Bank', code: 'SCB', c: '#4E2E92' },
  { id: 'kbank', name: 'KBank', full: 'Kasikornbank', code: 'K', c: '#138F2C' },
  { id: 'bbl', name: 'Bangkok Bank', full: 'Bualuang', code: 'BBL', c: '#1A3F7A' },
  { id: 'ktb', name: 'Krungthai', full: 'KTB next', code: 'KTB', c: '#00A4E4' },
  { id: 'bay', name: 'Krungsri', full: 'Bank of Ayudhya', code: 'KMA', c: '#A88438' },
  { id: 'ttb', name: 'ttb', full: 'TMBThanachart', code: 'ttb', c: '#1652F0' },
];

// Register real logos here as you add files, e.g. { kbank: 'svg', scb: 'png' }.
// Until an id is listed, the brand-colored monogram tile is shown (no network fetch).
const BANK_LOGOS = {};

// Renders the bank's real logo from assets/banks/<id>.<ext> when registered above,
// falling back to a brand-colored monogram tile (official logos not bundled).
function BankMark({ bank, size = 40, radius = 12 }) {
  const [failed, setFailed] = React.useState(false);
  const ext = BANK_LOGOS[bank.id];
  const showImg = ext && !failed;
  return (
    <div style={{
      width: size, height: size, borderRadius: radius, flexShrink: 0, overflow: 'hidden',
      background: showImg ? '#fff' : bank.c, border: `1px solid ${bank.c}55`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
    }}>
      {showImg ? (
        <img
          src={`assets/banks/${bank.id}.${ext}`}
          alt={bank.name}
          onError={() => setFailed(true)}
          style={{ width: '78%', height: '78%', objectFit: 'contain' }}
        />
      ) : (
        <span style={{ color: '#fff', fontSize: bank.code.length > 2 ? size * 0.28 : size * 0.42, fontWeight: 800, letterSpacing: 0.2 }}>{bank.code}</span>
      )}
    </div>
  );
}

function VerifyNDID() {
  const [step, setStep] = React.useState('select'); // select | pending | verified
  const [bank, setBank] = React.useState(null);
  const [query, setQuery] = React.useState('');
  const timer = React.useRef(null);

  const start = () => {
    if (!bank) return;
    setStep('pending');
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setStep('verified'), 2800);
  };
  React.useEffect(() => () => clearTimeout(timer.current), []);
  const chosen = BANKS.find(b => b.id === bank);
  const q = query.trim().toLowerCase();
  const shown = q ? BANKS.filter(b => (b.name + ' ' + b.full).toLowerCase().includes(q)) : BANKS;

  return (
    <div style={{ position: 'absolute', inset: 0, background: N.bg, fontFamily: N.font, color: N.text, display: 'flex', flexDirection: 'column' }}>
      {/* minimal top bar — plain chevron */}
      <div style={{ paddingTop: 58, flexShrink: 0, padding: '58px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 24 }}>
        <NIcon d={NP.back} c={N.muted} s={22} sw={2} />
        {step === 'select' && (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12, fontWeight: 600, color: N.muted }}>
            <NIcon d={NP.lock} c={N.violetSoft} s={13} sw={2} /> Secured by NDID
          </span>
        )}
      </div>

      {/* ─────────── SELECT ─────────── */}
      {step === 'select' && (
        <React.Fragment>
          <div style={{ flex: 1, overflowY: 'auto', padding: '20px 24px 16px', display: 'flex', flexDirection: 'column' }}>
            {/* trust badge */}
            <div style={{ width: 56, height: 56, borderRadius: 18, background: 'rgba(155,107,255,0.12)', border: '1px solid rgba(155,107,255,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
              <NIcon d={NP.shieldCheck} c={N.violetSoft} s={28} sw={1.8} />
            </div>

            <h1 style={{ margin: 0, fontSize: 28, fontWeight: 700, letterSpacing: -0.7, lineHeight: 1.12 }}>Verify your identity</h1>
            <p style={{ margin: '10px 0 0', fontSize: 15, color: N.muted, lineHeight: 1.5 }}>
              Choose your bank to confirm your identity through <span style={{ color: N.text, fontWeight: 600 }}>NDID</span> and unlock full settlement.
            </p>

            {/* search */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 48, borderRadius: 13, background: N.surface, border: `1px solid ${N.hair}`, padding: '0 14px', margin: '22px 0 6px' }}>
              <NIcon d={NP.search} c={N.faint} s={18} sw={1.9} />
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search your bank"
                style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', color: N.text, fontFamily: N.font, fontSize: 15 }}
              />
            </div>

            {/* bank list — selectable cards */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginTop: 8 }}>
              {shown.map((b) => {
                const on = bank === b.id;
                return (
                  <button key={b.id} onClick={() => setBank(b.id)} style={{
                    width: '100%', display: 'flex', alignItems: 'center', gap: 13, padding: '12px 13px', cursor: 'pointer',
                    borderRadius: 14, fontFamily: N.font, textAlign: 'left', transition: 'all .15s',
                    background: on ? 'rgba(155,107,255,0.1)' : N.surface,
                    border: `1.5px solid ${on ? N.violet : N.hair}`,
                  }}>
                    <BankMark bank={b} size={40} radius={12} />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontSize: 15.5, fontWeight: 650 }}>{b.name}</div>
                      <div style={{ fontSize: 12.5, color: N.faint, marginTop: 1 }}>{b.full}</div>
                    </div>
                    <div style={{
                      width: 22, height: 22, borderRadius: '50%', flexShrink: 0,
                      border: `1.5px solid ${on ? N.violet : N.faint}`, background: on ? N.violet : 'transparent',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      {on && <NIcon d={NP.check} c="#fff" s={12} sw={2.6} />}
                    </div>
                  </button>
                );
              })}
              {shown.length === 0 && (
                <div style={{ textAlign: 'center', fontSize: 14, color: N.faint, padding: '24px 0' }}>No banks match “{query}”.</div>
              )}
            </div>

            <p style={{ margin: '20px 2px 0', fontSize: 12, color: N.faint, lineHeight: 1.5 }}>
              Available to Thai nationals with a registered Thai bank account. 🇹🇭
            </p>
          </div>

          {/* CTA */}
          <div style={{ flexShrink: 0, padding: '12px 24px 32px' }}>
            <button onClick={start} disabled={!bank} style={{
              width: '100%', height: 54, border: 'none', borderRadius: 14, cursor: bank ? 'pointer' : 'default',
              fontFamily: N.font, fontSize: 16.5, fontWeight: 700, color: '#fff',
              background: bank ? N.grad : 'rgba(255,255,255,0.07)', opacity: bank ? 1 : 0.55,
              transition: 'all .18s',
            }}>{bank ? `Continue with ${chosen.name}` : 'Select your bank'}</button>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, marginTop: 12, fontSize: 11.5, color: N.faint }}>
              <NIcon d={NP.lock} c={N.faint} s={12} sw={2} /> Bank-grade encrypted · we never see your password
            </div>
          </div>
        </React.Fragment>
      )}

      {/* ─────────── PENDING ─────────── */}
      {step === 'pending' && (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 36px 40px', textAlign: 'center' }}>
          <div style={{ position: 'relative', width: 84, height: 84, marginBottom: 30 }}>
            <div className="gtx-spin" style={{ position: 'absolute', inset: 0, borderRadius: '50%', border: '2px solid rgba(155,107,255,0.18)', borderTopColor: N.violet }} />
            <div style={{ position: 'absolute', inset: 14, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><BankMark bank={chosen} size={56} radius={16} /></div>
          </div>
          <h2 style={{ margin: 0, fontSize: 23, fontWeight: 700, letterSpacing: -0.5 }}>Approve in your {chosen.name} app</h2>
          <p style={{ margin: '14px 0 0', fontSize: 15, color: N.muted, lineHeight: 1.55, maxWidth: 280 }}>
            Open the {chosen.full} app and confirm your identity to finish verifying via NDID.
          </p>
          <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginTop: 28 }}>
            <span className="gtx-blink" style={{ width: 7, height: 7, borderRadius: '50%', background: N.violet }} />
            <span style={{ fontSize: 13.5, color: N.muted, fontWeight: 500 }}>Waiting for approval…</span>
          </div>
          <button onClick={() => setStep('select')} style={{ marginTop: 30, background: 'none', border: 'none', cursor: 'pointer', color: N.faint, fontFamily: N.font, fontSize: 14.5, fontWeight: 600 }}>Cancel</button>
        </div>
      )}

      {/* ─────────── VERIFIED ─────────── */}
      {step === 'verified' && (
        <React.Fragment>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', textAlign: 'center' }}>
            <div style={{ width: 80, height: 80, borderRadius: '50%', border: `1.5px solid ${N.violet}`, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 0 8px rgba(155,107,255,0.08)' }}>
              <NIcon d={NP.tick} c={N.violetSoft} s={38} sw={2} />
            </div>
            <h2 style={{ margin: '28px 0 0', fontSize: 26, fontWeight: 720, letterSpacing: -0.6 }}>You're verified</h2>
            <p style={{ margin: '14px 0 0', fontSize: 15.5, color: N.muted, lineHeight: 1.55, maxWidth: 290 }}>
              Verified with {chosen.full} via NDID. Full settlement is now unlocked.
            </p>
            <div style={{ width: '100%', marginTop: 30 }}>
              {['THB bank withdrawals enabled', 'Settlement limit ฿200,000 / month', 'Identity verified · KYC complete'].map((l, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '15px 2px', borderTop: i ? `1px solid ${N.hair}` : 'none' }}>
                  <NIcon d={NP.tick} c={N.violet} s={17} sw={2.2} />
                  <span style={{ flex: 1, textAlign: 'left', fontSize: 14.5, color: N.text }}>{l}</span>
                </div>
              ))}
            </div>
          </div>
          <div style={{ flexShrink: 0, padding: '12px 24px 32px' }}>
            <button style={{
              width: '100%', height: 54, border: 'none', borderRadius: 14, cursor: 'pointer',
              fontFamily: N.font, fontSize: 16.5, fontWeight: 700, color: '#fff', background: N.grad,
            }}>Done</button>
          </div>
        </React.Fragment>
      )}
    </div>
  );
}

Object.assign(window, { VerifyNDID });
