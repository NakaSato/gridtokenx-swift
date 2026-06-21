// GridTokenX — signup flow screens (dark + purple)
// Exports screens to window for index.html to mount inside <IOSDevice dark>.

const GTX = {
  bg: '#0B0712',
  bg2: '#0E0A18',
  surface: 'rgba(255,255,255,0.045)',
  surfaceBorder: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.52)',
  faint: 'rgba(244,241,250,0.34)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  fontStack: '-apple-system, "SF Pro Text", system-ui, sans-serif',
};

// ── shared atoms ─────────────────────────────────────────────
function Glow() {
  return (
    <div style={{
      position: 'absolute', top: -160, left: '50%', transform: 'translateX(-50%)',
      width: 520, height: 420, pointerEvents: 'none',
      background: 'radial-gradient(circle at center, rgba(140,90,255,0.40) 0%, rgba(140,90,255,0.10) 38%, rgba(11,7,18,0) 68%)',
      filter: 'blur(6px)', zIndex: 0,
    }} />
  );
}

function Screen({ children, pad = 24 }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: GTX.bg,
      fontFamily: GTX.fontStack, color: GTX.text, overflow: 'hidden',
    }}>
      <Glow />
      <div style={{
        position: 'relative', zIndex: 1, height: '100%', boxSizing: 'border-box',
        padding: `92px ${pad}px 44px`, display: 'flex', flexDirection: 'column',
      }}>{children}</div>
    </div>
  );
}

function Logo({ size = 40 }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
      <div style={{
        width: size, height: size, borderRadius: size * 0.3, background: GTX.grad,
        boxShadow: '0 6px 20px rgba(124,58,237,0.5)', position: 'relative',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: size * 0.11,
        }}>
          {[0, 1, 2, 3].map(i => (
            <div key={i} style={{
              width: size * 0.14, height: size * 0.14, borderRadius: 2,
              background: i === 0 ? '#fff' : 'rgba(255,255,255,0.62)',
            }} />
          ))}
        </div>
      </div>
      <span style={{ fontSize: size * 0.5, fontWeight: 700, letterSpacing: -0.4 }}>
        GridToken<span style={{ color: GTX.violetSoft }}>X</span>
      </span>
    </div>
  );
}

function BackChevron() {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: 12, background: GTX.surface,
      border: `1px solid ${GTX.surfaceBorder}`, display: 'flex',
      alignItems: 'center', justifyContent: 'center', flexShrink: 0,
    }}>
      <svg width="9" height="16" viewBox="0 0 9 16" fill="none">
        <path d="M8 1L1.5 8 8 15" stroke={GTX.violetSoft} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </div>
  );
}

function PrimaryBtn({ children }) {
  return (
    <div style={{
      height: 56, borderRadius: 16, background: GTX.grad, color: '#fff',
      fontSize: 17, fontWeight: 650, display: 'flex', alignItems: 'center',
      justifyContent: 'center', boxShadow: '0 10px 28px rgba(124,58,237,0.42)',
      letterSpacing: -0.2,
    }}>{children}</div>
  );
}

function Field({ label, value, placeholder, trailing, focus }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      <span style={{ fontSize: 13, fontWeight: 600, color: GTX.muted, letterSpacing: 0.1 }}>{label}</span>
      <div style={{
        height: 56, borderRadius: 14, background: GTX.surface,
        border: `1px solid ${focus ? GTX.violet : GTX.surfaceBorder}`,
        boxShadow: focus ? '0 0 0 4px rgba(155,107,255,0.16)' : 'none',
        display: 'flex', alignItems: 'center', padding: '0 16px', gap: 10,
      }}>
        <span style={{
          flex: 1, fontSize: 16, letterSpacing: -0.2,
          color: value ? GTX.text : GTX.faint,
        }}>{value || placeholder}{focus && <span style={{ color: GTX.violet, fontWeight: 300 }}> |</span>}</span>
        {trailing}
      </div>
    </div>
  );
}

// ── 1 · Welcome ──────────────────────────────────────────────
function WelcomeBg() {
  const canvasRef = React.useRef(null);
  React.useEffect(() => {
    const cvs = canvasRef.current;
    if (!cvs) return;
    const W = cvs.width = cvs.offsetWidth;
    const H = cvs.height = cvs.offsetHeight;
    const ctx = cvs.getContext('2d');

    // power-flow lines: each is a diagonal route with racing streaks
    const LINES = [
      { y0: H*0.08, y1: H*0.22, col: '#A974FF', w: 1.4, spd: 1.6, n: 3 },
      { y0: H*0.28, y1: H*0.18, col: '#C9B4FF', w: 0.9, spd: 2.2, n: 2 },
      { y0: H*0.40, y1: H*0.48, col: '#7C3AED', w: 1.8, spd: 1.3, n: 4 },
      { y0: H*0.55, y1: H*0.38, col: '#9B6BFF', w: 1.1, spd: 1.9, n: 3 },
      { y0: H*0.65, y1: H*0.72, col: '#A974FF', w: 1.0, spd: 2.5, n: 2 },
      { y0: H*0.80, y1: H*0.62, col: '#C9B4FF', w: 0.8, spd: 1.7, n: 3 },
      { y0: H*0.90, y1: H*0.95, col: '#7C3AED', w: 0.7, spd: 2.8, n: 2 },
    ].map(l => ({
      ...l,
      streaks: Array.from({ length: l.n }, (_, k) => ({
        t: k / l.n,
        tail: 0.05 + Math.random() * 0.07,
      })),
    }));

    let raf, last = 0;
    function draw(ts) {
      const dt = Math.min((ts - last) / 1000, 0.05);
      last = ts;
      ctx.clearRect(0, 0, W, H);

      LINES.forEach(l => {
        // faint base line
        ctx.save();
        ctx.globalAlpha = 0.08;
        ctx.strokeStyle = l.col;
        ctx.lineWidth = l.w;
        ctx.beginPath(); ctx.moveTo(0, l.y0); ctx.lineTo(W, l.y1); ctx.stroke();
        ctx.restore();

        // advance & draw streaks
        l.streaks.forEach(s => {
          s.t += l.spd * dt * 0.15;
          if (s.t > 1 + s.tail) s.t = -s.tail;

          const t1 = Math.min(s.t, 1);
          const t0 = Math.max(s.t - s.tail, 0);
          if (t1 <= t0) return;

          const ax = t0 * W, ay = l.y0 + (l.y1 - l.y0) * t0;
          const bx = t1 * W, by = l.y0 + (l.y1 - l.y0) * t1;

          // outer glow
          const gOuter = ctx.createLinearGradient(ax, ay, bx, by);
          gOuter.addColorStop(0, l.col + '00');
          gOuter.addColorStop(1, l.col + '44');
          ctx.save();
          ctx.strokeStyle = gOuter;
          ctx.lineWidth = l.w + 12;
          ctx.globalAlpha = 0.22;
          ctx.lineCap = 'round';
          ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by); ctx.stroke();
          ctx.restore();

          // mid glow
          const gMid = ctx.createLinearGradient(ax, ay, bx, by);
          gMid.addColorStop(0, l.col + '00');
          gMid.addColorStop(1, l.col + 'BB');
          ctx.save();
          ctx.strokeStyle = gMid;
          ctx.lineWidth = l.w + 3;
          ctx.globalAlpha = 0.55;
          ctx.lineCap = 'round';
          ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by); ctx.stroke();
          ctx.restore();

          // bright core
          const gCore = ctx.createLinearGradient(ax, ay, bx, by);
          gCore.addColorStop(0, l.col + '00');
          gCore.addColorStop(1, '#ffffff');
          ctx.save();
          ctx.strokeStyle = gCore;
          ctx.lineWidth = l.w;
          ctx.globalAlpha = 1;
          ctx.lineCap = 'round';
          ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by); ctx.stroke();
          ctx.restore();

          // leading hot dot
          ctx.save();
          ctx.shadowBlur = 18; ctx.shadowColor = l.col;
          ctx.fillStyle = '#fff';
          ctx.globalAlpha = 0.95;
          ctx.beginPath(); ctx.arc(bx, by, l.w * 2, 0, Math.PI * 2); ctx.fill();
          ctx.restore();
        });
      });

      raf = requestAnimationFrame(draw);
    }
    raf = requestAnimationFrame(draw);
    return () => cancelAnimationFrame(raf);
  }, []);

  return <canvas ref={canvasRef} style={{ position:'absolute', inset:0, width:'100%', height:'100%' }} />;
}

function Welcome() {
  return (
    <div style={{ position:'absolute', inset:0, background: GTX.bg, fontFamily: GTX.fontStack, color: GTX.text, overflow:'hidden' }}>
      {/* animated background */}
      <WelcomeBg />

      {/* brand icon — half-visible top-right */}
      <img
        src="uploads/favicon.ico"
        alt=""
        style={{
          position: 'absolute', top: -60, right: -60,
          width: 220, height: 220,
          opacity: 0.22, pointerEvents: 'none',
          filter: 'blur(0.5px) saturate(0) sepia(1) hue-rotate(220deg) brightness(0.8) saturate(3)',
        }}
      />
      {/* bottom fade so text stays readable */}
      <div style={{ position:'absolute', bottom:0, left:0, right:0, height:'55%', background:`linear-gradient(transparent, ${GTX.bg} 55%)`, pointerEvents:'none' }} />

      {/* content */}
      <div style={{ position:'absolute', bottom:0, left:0, right:0, padding:'0 24px 44px', display:'flex', flexDirection:'column' }}>
        <h1 style={{ margin:'0 0 18px', fontSize:58, fontWeight:800, lineHeight:1.02, letterSpacing:-2 }}>
          Trade clean energy,<br/>
          <span style={{ background: GTX.grad, WebkitBackgroundClip:'text', WebkitTextFillColor:'transparent' }}>peer to peer.</span>
        </h1>
        <p style={{ margin:'0 0 30px', fontSize:19, lineHeight:1.55, color: GTX.muted }}>
          Buy and sell solar power directly with your community — settled on-chain in real time.
        </p>
        <div style={{ display:'flex', flexDirection:'column', gap:13 }}>
          <PrimaryBtn>Create account</PrimaryBtn>
          <div style={{ textAlign:'center', fontSize:15.5, color: GTX.muted }}>
            Already trading?{' '}<span style={{ color: GTX.violetSoft, fontWeight:600 }}>Sign in</span>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── 2 · Create account ───────────────────────────────────────
function CreateAccount() {
  return (
    <Screen>
      <BackChevron />
      <h1 style={{ margin: '26px 0 8px', fontSize: 28, fontWeight: 700, letterSpacing: -0.6 }}>Create your account</h1>
      <p style={{ margin: 0, fontSize: 15.5, color: GTX.muted, lineHeight: 1.45 }}>Start trading energy in under a minute.</p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 18, marginTop: 30 }}>
        <Field label="EMAIL" value="maya.chen@gmail.com" focus />
        <Field label="PASSWORD" value="••••••••••" trailing={
          <span style={{ fontSize: 14, fontWeight: 600, color: GTX.violetSoft }}>Show</span>
        } />
      </div>

      <div style={{ flex: 1 }} />

      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <PrimaryBtn>Continue</PrimaryBtn>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ flex: 1, height: 1, background: GTX.surfaceBorder }} />
          <span style={{ fontSize: 13, color: GTX.faint }}>or</span>
          <div style={{ flex: 1, height: 1, background: GTX.surfaceBorder }} />
        </div>
        <div style={{
          height: 54, borderRadius: 16, background: GTX.surface,
          border: `1px solid ${GTX.surfaceBorder}`, display: 'flex', gap: 10,
          alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 600,
        }}>
          <div style={{ width: 18, height: 18, borderRadius: 5, background: GTX.grad }} />
          Continue with wallet
        </div>
        <p style={{ margin: 0, textAlign: 'center', fontSize: 12.5, color: GTX.faint, lineHeight: 1.5 }}>
          By continuing you agree to our <span style={{ color: GTX.muted }}>Terms</span> & <span style={{ color: GTX.muted }}>Privacy Policy</span>.
        </p>
      </div>
    </Screen>
  );
}

// ── 3 · Verify code ──────────────────────────────────────────
function Verify() {
  const digits = ['4', '1', '9', '', '', ''];
  return (
    <Screen>
      <BackChevron />
      <h1 style={{ margin: '26px 0 8px', fontSize: 28, fontWeight: 700, letterSpacing: -0.6 }}>Check your email</h1>
      <p style={{ margin: 0, fontSize: 15.5, color: GTX.muted, lineHeight: 1.45 }}>
        We sent a 6-digit code to<br/><span style={{ color: GTX.text, fontWeight: 600 }}>maya.chen@gmail.com</span>
      </p>

      <div style={{ display: 'flex', gap: 10, marginTop: 34 }}>
        {digits.map((d, i) => {
          const active = i === 3;
          return (
            <div key={i} style={{
              flex: 1, height: 62, borderRadius: 14,
              background: d ? 'rgba(155,107,255,0.12)' : GTX.surface,
              border: `1.5px solid ${active ? GTX.violet : d ? 'rgba(155,107,255,0.45)' : GTX.surfaceBorder}`,
              boxShadow: active ? '0 0 0 4px rgba(155,107,255,0.16)' : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 26, fontWeight: 600,
            }}>
              {d}
              {active && <span style={{ color: GTX.violet, fontWeight: 300, fontSize: 24 }}>|</span>}
            </div>
          );
        })}
      </div>

      <div style={{ marginTop: 22, fontSize: 14.5, color: GTX.muted }}>
        Didn't get it? <span style={{ color: GTX.faint }}>Resend in 0:24</span>
      </div>

      <div style={{ flex: 1 }} />
      <PrimaryBtn>Verify</PrimaryBtn>
    </Screen>
  );
}

// ── 4 · Profile + role ───────────────────────────────────────
function Profile() {
  const RoleCard = ({ title, desc, selected, dot }) => (
    <div style={{
      borderRadius: 16, padding: '16px 16px', display: 'flex', gap: 13, alignItems: 'center',
      background: selected ? 'rgba(155,107,255,0.12)' : GTX.surface,
      border: `1.5px solid ${selected ? GTX.violet : GTX.surfaceBorder}`,
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 11, flexShrink: 0,
        background: selected ? GTX.grad : 'rgba(255,255,255,0.06)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <div style={{ width: 12, height: 12, borderRadius: 3, background: '#fff', transform: dot }} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 16.5, fontWeight: 650, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontSize: 13.5, color: GTX.muted, marginTop: 2 }}>{desc}</div>
      </div>
      <div style={{
        width: 22, height: 22, borderRadius: 11, flexShrink: 0,
        border: `1.5px solid ${selected ? GTX.violet : GTX.faint}`,
        background: selected ? GTX.violet : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {selected && <svg width="11" height="9" viewBox="0 0 11 9" fill="none"><path d="M1 4.5L4 7.5L10 1" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}
      </div>
    </div>
  );
  return (
    <Screen>
      <BackChevron />
      <h1 style={{ margin: '26px 0 8px', fontSize: 28, fontWeight: 700, letterSpacing: -0.6 }}>Tell us about you</h1>
      <p style={{ margin: 0, fontSize: 15.5, color: GTX.muted, lineHeight: 1.45 }}>This sets up your trading profile.</p>

      <div style={{ marginTop: 26 }}>
        <Field label="DISPLAY NAME" value="Maya Chen" />
      </div>

      <div style={{ fontSize: 13, fontWeight: 600, color: GTX.muted, margin: '26px 0 12px', letterSpacing: 0.1 }}>
        HOW WILL YOU USE GRIDTOKENX?
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <RoleCard title="Sell energy" desc="I produce solar or wind I want to trade." selected dot="rotate(45deg)" />
        <RoleCard title="Buy energy" desc="I want to source clean power locally." dot="none" />
      </div>

      <div style={{ flex: 1 }} />
      <PrimaryBtn>Continue</PrimaryBtn>
    </Screen>
  );
}

// ── 5 · Success ──────────────────────────────────────────────
function Success() {
  return (
    <Screen>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
        <div style={{
          width: 96, height: 96, borderRadius: 30, background: GTX.grad,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 16px 50px rgba(124,58,237,0.55)',
        }}>
          <svg width="44" height="36" viewBox="0 0 44 36" fill="none">
            <path d="M4 19L16 31L40 5" stroke="#fff" strokeWidth="5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <h1 style={{ margin: '34px 0 0', fontSize: 30, fontWeight: 700, letterSpacing: -0.7 }}>You're all set</h1>
        <p style={{ margin: '14px 0 0', fontSize: 16.5, color: GTX.muted, lineHeight: 1.5, maxWidth: 290 }}>
          Welcome to GridTokenX, Maya. Your wallet is ready and the marketplace is live.
        </p>
        <div style={{
          display: 'flex', gap: 10, marginTop: 28,
        }}>
          {[['12.4', 'kWh credits'], ['0.0', 'GTX balance'], ['8', 'sellers nearby']].map(([n, l]) => (
            <div key={l} style={{
              padding: '12px 14px', borderRadius: 14, background: GTX.surface,
              border: `1px solid ${GTX.surfaceBorder}`, minWidth: 84,
            }}>
              <div style={{ fontSize: 19, fontWeight: 700, color: GTX.violetSoft }}>{n}</div>
              <div style={{ fontSize: 11.5, color: GTX.muted, marginTop: 3 }}>{l}</div>
            </div>
          ))}
        </div>
      </div>
      <PrimaryBtn>Enter GridTokenX</PrimaryBtn>
    </Screen>
  );
}

Object.assign(window, { Welcome, CreateAccount, Verify, Profile, Success });
