// GridTokenX — Register new meter ID by scanning its serial barcode.
// Dark + purple system. Exports RegisterDevice to window.

const R = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  border: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.54)',
  faint: 'rgba(244,241,250,0.32)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  up: '#2FD08A',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};
const SERIAL = 'GTX-5821-4490-1123';

function RIcon({ d, c = R.violetSoft, s = 18, sw = 2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const RP = {
  back: 'M15 6l-6 6 6 6',
  meter: 'M12 3a9 9 0 00-9 9 9 9 0 003 6.7M12 3a9 9 0 019 9 9 9 0 01-3 6.7M12 12l4-3',
  check: 'M5 12l5 5 9-10',
  flash: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  scan: 'M4 7V5a1 1 0 011-1h2M17 4h2a1 1 0 011 1v2M20 17v2a1 1 0 01-1 1h-2M7 20H5a1 1 0 01-1-1v-2',
  keyboard: 'M3 6h18v12H3zM7 10h.01M11 10h.01M15 10h.01M7 14h10',
};

// barcode = vertical bars (simple rects)
function Barcode({ dark }) {
  const widths = [3, 1, 2, 1, 1, 3, 1, 2, 2, 1, 1, 3, 2, 1, 1, 2, 3, 1, 1, 2, 1, 3, 1, 2, 1, 1, 2, 3, 1, 1, 2, 1];
  return (
    <div style={{ display: 'flex', alignItems: 'stretch', gap: 2, height: 56 }}>
      {widths.map((w, i) => (
        <div key={i} style={{ width: w * 2, background: i % 2 === 0 ? (dark ? '#0B0712' : '#15101F') : 'transparent', borderRadius: 0.5 }} />
      ))}
    </div>
  );
}

function Corner({ pos }) {
  const base = { position: 'absolute', width: 30, height: 30, borderColor: R.violet, borderStyle: 'solid', borderWidth: 0 };
  const m = {
    tl: { top: 14, left: 14, borderTopWidth: 3, borderLeftWidth: 3, borderTopLeftRadius: 10 },
    tr: { top: 14, right: 14, borderTopWidth: 3, borderRightWidth: 3, borderTopRightRadius: 10 },
    bl: { bottom: 14, left: 14, borderBottomWidth: 3, borderLeftWidth: 3, borderBottomLeftRadius: 10 },
    br: { bottom: 14, right: 14, borderBottomWidth: 3, borderRightWidth: 3, borderBottomRightRadius: 10 },
  };
  return <div style={{ ...base, ...m[pos] }} />;
}

function RegisterDevice() {
  const [found, setFound] = React.useState(false);
  const [code, setCode] = React.useState('');
  const timer = React.useRef(null);
  const codeRef = React.useRef(null);
  const CODE_LEN = 6;

  const startScan = React.useCallback(() => {
    setFound(false);
    setCode('');
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setFound(true), 2000);
  }, []);

  React.useEffect(() => { startScan(); return () => clearTimeout(timer.current); }, [startScan]);
  React.useEffect(() => { if (found && codeRef.current) codeRef.current.focus(); }, [found]);

  const onCode = (e) => setCode(e.target.value.replace(/\D/g, '').slice(0, CODE_LEN));
  const codeComplete = code.length === CODE_LEN;

  return (
    <div style={{ position: 'absolute', inset: 0, background: R.bg, fontFamily: R.font, color: R.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 4px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: R.surface, border: `1px solid ${R.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <RIcon d={RP.back} s={18} />
        </div>
        <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Register meter</span>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '10px 16px 12px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <p style={{ margin: '0 2px', fontSize: 15, color: R.muted, lineHeight: 1.45 }}>
          Scan the barcode on the back of your smart meter to link it to your account.
        </p>

        {/* scanner viewport */}
        <div style={{
          position: 'relative', height: 280, borderRadius: 22, overflow: 'hidden',
          background: 'radial-gradient(120% 90% at 50% 30%, #1a1330 0%, #0a0712 75%)',
          border: `1px solid ${found ? 'rgba(47,208,138,0.5)' : R.border}`,
          boxShadow: found ? '0 0 0 3px rgba(47,208,138,0.18)' : 'none', transition: 'all .3s',
        }}>
          {/* faint device surface grid */}
          <div style={{ position: 'absolute', inset: 0, opacity: 0.5, backgroundImage: 'repeating-linear-gradient(0deg, rgba(255,255,255,0.04) 0 1px, transparent 1px 34px), repeating-linear-gradient(90deg, rgba(255,255,255,0.04) 0 1px, transparent 1px 34px)' }} />

          {/* the meter label being scanned */}
          <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%,-50%)', width: 200, padding: '14px 16px 12px', borderRadius: 10, background: '#EDE9F2', boxShadow: '0 14px 30px rgba(0,0,0,0.5)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ fontSize: 10, fontWeight: 800, color: '#15101F', letterSpacing: 0.5 }}>GRIDTOKENX</span>
              <span style={{ fontSize: 8.5, color: '#6b6478' }}>METER · v2</span>
            </div>
            <Barcode />
            <div style={{ marginTop: 7, fontSize: 10.5, fontFamily: R.mono, color: '#15101F', letterSpacing: 1, textAlign: 'center', fontWeight: 600 }}>{SERIAL}</div>
          </div>

          {/* corner brackets */}
          <Corner pos="tl" /><Corner pos="tr" /><Corner pos="bl" /><Corner pos="br" />

          {/* scan line */}
          {!found && (
            <div className="gtx-scan" style={{ position: 'absolute', left: 22, right: 22, height: 2, borderRadius: 2, background: R.violet, boxShadow: `0 0 14px 2px ${R.violet}` }} />
          )}

          {/* found check overlay */}
          {found && (
            <div style={{ position: 'absolute', top: 14, right: 14, width: 30, height: 30, borderRadius: '50%', background: R.up, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 12px rgba(47,208,138,0.5)' }}>
              <RIcon d={RP.check} c="#053123" s={16} sw={2.6} />
            </div>
          )}

          {/* flash toggle */}
          <div style={{ position: 'absolute', bottom: 14, left: '50%', transform: 'translateX(-50%)', width: 40, height: 40, borderRadius: '50%', background: 'rgba(11,7,18,0.6)', backdropFilter: 'blur(8px)', border: `1px solid ${R.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <RIcon d={RP.flash} c={R.violetSoft} s={18} fill="none" />
          </div>
        </div>

        {/* status / detected result */}
        {!found ? (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, fontSize: 14.5, color: R.muted }}>
            <span className="gtx-blink" style={{ width: 7, height: 7, borderRadius: '50%', background: R.violet }} />
            Scanning for barcode…
          </div>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px', borderRadius: 16, background: 'rgba(47,208,138,0.1)', border: '1px solid rgba(47,208,138,0.35)' }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0, background: R.grad, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <RIcon d={RP.meter} c="#fff" s={20} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 650 }}>GridTokenX Meter found</div>
              <div style={{ fontSize: 13, fontFamily: R.mono, color: R.muted, marginTop: 2, letterSpacing: 0.5 }}>{SERIAL}</div>
            </div>
            <RIcon d={RP.check} c={R.up} s={20} sw={2.4} />
          </div>
        )}

        {!found ? (
          <React.Fragment>
            {/* divider */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ flex: 1, height: 1, background: R.border }} />
              <span style={{ fontSize: 12.5, color: R.faint }}>or enter manually</span>
              <div style={{ flex: 1, height: 1, background: R.border }} />
            </div>

            {/* manual entry */}
            <div style={{ height: 56, borderRadius: 14, background: R.surface, border: `1px solid ${R.border}`, display: 'flex', alignItems: 'center', padding: '0 16px', gap: 10 }}>
              <RIcon d={RP.keyboard} c={R.faint} s={18} sw={1.8} />
              <span style={{ flex: 1, fontSize: 16, fontFamily: R.mono, letterSpacing: 1, color: R.faint }}>GTX-____-____-____</span>
            </div>
          </React.Fragment>
        ) : (
          /* activation code step */
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <div>
              <div style={{ fontSize: 15, fontWeight: 700 }}>Enter activation code</div>
              <div style={{ fontSize: 13.5, color: R.muted, marginTop: 3, lineHeight: 1.4 }}>Type the 6-digit code shown on your meter's display or setup card.</div>
            </div>

            {/* hidden capture input over the cells */}
            <div style={{ position: 'relative' }} onClick={() => codeRef.current && codeRef.current.focus()}>
              <input
                ref={codeRef}
                value={code}
                onChange={onCode}
                inputMode="numeric"
                autoComplete="one-time-code"
                maxLength={CODE_LEN}
                style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0, border: 'none', background: 'transparent', cursor: 'text', fontSize: 16 }}
              />
              <div style={{ display: 'flex', gap: 8, pointerEvents: 'none' }}>
                {Array.from({ length: CODE_LEN }).map((_, i) => {
                  const ch = code[i];
                  const active = i === code.length;
                  return (
                    <div key={i} style={{
                      flex: 1, height: 56, borderRadius: 12,
                      background: ch ? 'rgba(155,107,255,0.12)' : R.surface,
                      border: `1.5px solid ${active ? R.violet : ch ? 'rgba(155,107,255,0.45)' : R.border}`,
                      boxShadow: active ? '0 0 0 4px rgba(155,107,255,0.16)' : 'none',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 22, fontWeight: 700, fontFamily: R.mono, color: R.text,
                    }}>
                      {ch || (active ? <span style={{ color: R.violet, fontWeight: 300 }}>|</span> : '')}
                    </div>
                  );
                })}
              </div>
            </div>

            <div style={{ fontSize: 13, color: R.muted, marginTop: 2 }}>
              Can't find it? <span style={{ color: R.violetSoft, fontWeight: 600 }}>Resend to meter</span>
            </div>
          </div>
        )}
      </div>

      {/* CTA */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${R.border}`, background: R.bg, display: 'flex', gap: 10 }}>
        {found && (
          <button onClick={startScan} style={{
            width: 56, height: 56, flexShrink: 0, borderRadius: 16, cursor: 'pointer',
            border: `1px solid ${R.border}`, background: R.surface, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <RIcon d={RP.scan} c={R.violetSoft} s={22} />
          </button>
        )}
        <button disabled={!codeComplete} style={{
          flex: 1, height: 56, border: 'none', borderRadius: 16, cursor: codeComplete ? 'pointer' : 'default',
          fontFamily: R.font, fontSize: 17, fontWeight: 700, color: '#fff',
          background: codeComplete ? R.grad : 'rgba(255,255,255,0.08)', opacity: codeComplete ? 1 : 0.6,
          boxShadow: codeComplete ? '0 10px 26px rgba(124,58,237,0.42)' : 'none',
        }}>{!found ? 'Searching…' : codeComplete ? 'Activate meter' : 'Enter activation code'}</button>
      </div>
    </div>
  );
}

Object.assign(window, { RegisterDevice });
