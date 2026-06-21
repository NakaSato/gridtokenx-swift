// GridTokenX — 01 · Welcome launch animation
// Scenes (inside <Stage>): grid ignites → logo splash → headline → CTA settle.
// Exports WelcomeAnimScene to window. Canvas 440×952 (phone 9:19.5-ish).

const A = {
  bg: '#0B0712',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.55)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
};
const PAD = 28;
const CW = 440;

// ── Power-flow background (self-contained rAF, opacity gated by timeline) ──
function PowerFlowBg() {
  const t = useTime();
  const canvasRef = React.useRef(null);
  React.useEffect(() => {
    const cvs = canvasRef.current;
    if (!cvs) return;
    const W = cvs.width = CW;
    const H = cvs.height = 952;
    const ctx = cvs.getContext('2d');
    const LINES = [
      { y0: H*0.08, y1: H*0.22, col: '#A974FF', w: 1.6, spd: 1.6, n: 3 },
      { y0: H*0.28, y1: H*0.18, col: '#C9B4FF', w: 1.0, spd: 2.2, n: 2 },
      { y0: H*0.40, y1: H*0.48, col: '#7C3AED', w: 2.0, spd: 1.3, n: 4 },
      { y0: H*0.55, y1: H*0.38, col: '#9B6BFF', w: 1.2, spd: 1.9, n: 3 },
      { y0: H*0.65, y1: H*0.72, col: '#A974FF', w: 1.1, spd: 2.5, n: 2 },
      { y0: H*0.80, y1: H*0.62, col: '#C9B4FF', w: 0.9, spd: 1.7, n: 3 },
      { y0: H*0.90, y1: H*0.95, col: '#7C3AED', w: 0.8, spd: 2.8, n: 2 },
    ].map(l => ({ ...l, streaks: Array.from({ length: l.n }, (_, k) => ({ t: k / l.n, tail: 0.05 + Math.random() * 0.07 })) }));

    let raf, last = 0;
    function draw(ts) {
      const dt = Math.min((ts - last) / 1000, 0.05); last = ts;
      ctx.clearRect(0, 0, W, H);
      LINES.forEach(l => {
        ctx.save(); ctx.globalAlpha = 0.08; ctx.strokeStyle = l.col; ctx.lineWidth = l.w;
        ctx.beginPath(); ctx.moveTo(0, l.y0); ctx.lineTo(W, l.y1); ctx.stroke(); ctx.restore();
        l.streaks.forEach(s => {
          s.t += l.spd * dt * 0.15;
          if (s.t > 1 + s.tail) s.t = -s.tail;
          const t1 = Math.min(s.t, 1), t0 = Math.max(s.t - s.tail, 0);
          if (t1 <= t0) return;
          const ax = t0 * W, ay = l.y0 + (l.y1 - l.y0) * t0;
          const bx = t1 * W, by = l.y0 + (l.y1 - l.y0) * t1;
          const seg = (lw, alpha, end) => {
            const g = ctx.createLinearGradient(ax, ay, bx, by);
            g.addColorStop(0, l.col + '00'); g.addColorStop(1, end);
            ctx.save(); ctx.strokeStyle = g; ctx.lineWidth = lw; ctx.globalAlpha = alpha; ctx.lineCap = 'round';
            ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by); ctx.stroke(); ctx.restore();
          };
          seg(l.w + 12, 0.22, l.col + '44');
          seg(l.w + 3, 0.55, l.col + 'BB');
          seg(l.w, 1, '#ffffff');
          ctx.save(); ctx.shadowBlur = 18; ctx.shadowColor = l.col; ctx.fillStyle = '#fff'; ctx.globalAlpha = 0.95;
          ctx.beginPath(); ctx.arc(bx, by, l.w * 2, 0, Math.PI * 2); ctx.fill(); ctx.restore();
        });
      });
      raf = requestAnimationFrame(draw);
    }
    raf = requestAnimationFrame(draw);
    return () => cancelAnimationFrame(raf);
  }, []);

  const bgOpacity = animate({ from: 0, to: 1, start: 0.2, end: 2.4, ease: Easing.easeOutCubic })(t);
  const glow = animate({ from: 0, to: 1, start: 0, end: 2.0, ease: Easing.easeOutCubic })(t);
  return (
    <div style={{ position: 'absolute', inset: 0 }}>
      {/* ambient radial glow that expands on ignition */}
      <div style={{
        position: 'absolute', top: '34%', left: '50%',
        width: 560, height: 560, marginLeft: -280, marginTop: -280, borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(124,58,237,0.35) 0%, transparent 62%)',
        transform: `scale(${0.4 + glow * 0.9})`, opacity: glow * 0.9, pointerEvents: 'none',
      }} />
      <canvas ref={canvasRef} style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: bgOpacity }} />
      {/* bottom fade for text legibility */}
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: '58%', background: `linear-gradient(transparent, ${A.bg} 64%)`, pointerEvents: 'none' }} />
    </div>
  );
}

// ── Ignition flash ──
function Ignition() {
  const t = useTime();
  if (t > 1.1) return null;
  const grow = animate({ from: 0, to: 1, start: 0.1, end: 0.5, ease: Easing.easeOutExpo })(t);
  const fade = animate({ from: 1, to: 0, start: 0.45, end: 1.05, ease: Easing.easeInCubic })(t);
  return (
    <div style={{ position: 'absolute', top: '34%', left: '50%', transform: `translate(-50%,-50%) scaleX(${grow})`, width: CW, height: 3, opacity: fade,
      background: 'linear-gradient(90deg, transparent, #C9B4FF, #fff, #C9B4FF, transparent)', boxShadow: '0 0 24px 6px rgba(201,180,255,0.8)', pointerEvents: 'none' }} />
  );
}

// ── Logo splash (assembles, holds, dissolves up) ──
function LogoSplash() {
  const t = useTime();
  if (t < 1.5 || t > 4.6) return null;
  const sqScale = animate({ from: 0.3, to: 1, start: 1.7, end: 2.5, ease: Easing.easeOutBack })(t);
  const sqOpacity = animate({ from: 0, to: 1, start: 1.7, end: 2.2, ease: Easing.easeOutCubic })(t);
  const wordOpacity = animate({ from: 0, to: 1, start: 2.55, end: 3.1, ease: Easing.easeOutCubic })(t);
  const wordTy = animate({ from: 14, to: 0, start: 2.55, end: 3.1, ease: Easing.easeOutCubic })(t);
  // group exit
  const exitOp = animate({ from: 1, to: 0, start: 3.8, end: 4.4, ease: Easing.easeInCubic })(t);
  const exitTy = animate({ from: 0, to: -54, start: 3.8, end: 4.5, ease: Easing.easeInCubic })(t);
  const S = 80;
  return (
    <div style={{ position: 'absolute', top: '40%', left: 0, right: 0, transform: `translateY(${exitTy}px)`, opacity: exitOp, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 18, pointerEvents: 'none' }}>
      <div style={{ width: S, height: S, borderRadius: S * 0.3, background: A.grad, boxShadow: '0 12px 40px rgba(124,58,237,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', transform: `scale(${sqScale})`, opacity: sqOpacity }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: S * 0.11 }}>
          {[0, 1, 2, 3].map(i => {
            const dp = animate({ from: 0, to: 1, start: 2.25 + i * 0.09, end: 2.55 + i * 0.09, ease: Easing.easeOutBack })(t);
            return <div key={i} style={{ width: S * 0.15, height: S * 0.15, borderRadius: 3, background: i === 0 ? '#fff' : 'rgba(255,255,255,0.65)', transform: `scale(${dp})`, opacity: dp }} />;
          })}
        </div>
      </div>
      <span style={{ fontFamily: A.font, fontSize: 30, fontWeight: 700, letterSpacing: -0.6, color: A.text, opacity: wordOpacity, transform: `translateY(${wordTy}px)` }}>
        GridToken<span style={{ color: A.violetSoft }}>X</span>
      </span>
    </div>
  );
}

// ── Welcome content (headline, subtitle, CTA) ──
function WelcomeContent() {
  const t = useTime();
  const l1 = {
    o: animate({ from: 0, to: 1, start: 4.6, end: 5.2, ease: Easing.easeOutCubic })(t),
    y: animate({ from: 30, to: 0, start: 4.6, end: 5.2, ease: Easing.easeOutCubic })(t),
  };
  const l2 = {
    o: animate({ from: 0, to: 1, start: 4.85, end: 5.5, ease: Easing.easeOutCubic })(t),
    y: animate({ from: 30, to: 0, start: 4.85, end: 5.5, ease: Easing.easeOutCubic })(t),
    sweep: animate({ from: 100, to: 0, start: 4.85, end: 6.0, ease: Easing.easeOutCubic })(t),
  };
  const sub = {
    o: animate({ from: 0, to: 1, start: 5.8, end: 6.4, ease: Easing.easeOutCubic })(t),
    y: animate({ from: 22, to: 0, start: 5.8, end: 6.4, ease: Easing.easeOutCubic })(t),
  };
  const btn = {
    o: animate({ from: 0, to: 1, start: 6.6, end: 7.1, ease: Easing.easeOutCubic })(t),
    y: animate({ from: 40, to: 0, start: 6.6, end: 7.3, ease: Easing.easeOutBack })(t),
  };
  const sign = {
    o: animate({ from: 0, to: 1, start: 7.35, end: 7.85, ease: Easing.easeOutCubic })(t),
    y: animate({ from: 16, to: 0, start: 7.35, end: 7.85, ease: Easing.easeOutCubic })(t),
  };
  // button settle pulse (after 7.6)
  const pulse = t > 7.6 ? 0.42 + 0.22 * Math.sin((t - 7.6) * 3.2) : 0.42;

  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: `0 ${PAD}px 48px`, fontFamily: A.font, color: A.text }}>
      <h1 style={{ margin: '0 0 18px', fontSize: 58, fontWeight: 800, lineHeight: 1.02, letterSpacing: -2 }}>
        <span style={{ display: 'block', opacity: l1.o, transform: `translateY(${l1.y}px)` }}>Trade clean energy,</span>
        <span style={{
          display: 'block', opacity: l2.o, transform: `translateY(${l2.y}px)`,
          background: 'linear-gradient(100deg, #7C3AED 0%, #A974FF 35%, #C9B4FF 50%, #A974FF 65%, #7C3AED 100%)',
          backgroundSize: '220% 100%', backgroundPositionX: `${l2.sweep}%`,
          WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text',
        }}>peer to peer.</span>
      </h1>
      <p style={{ margin: '0 0 30px', fontSize: 19, lineHeight: 1.55, color: A.muted, opacity: sub.o, transform: `translateY(${sub.y}px)` }}>
        Buy and sell solar power directly with your community — settled on-chain in real time.
      </p>
      <div style={{ opacity: btn.o, transform: `translateY(${btn.y}px)`, height: 60, borderRadius: 17, background: A.grad, color: '#fff', fontSize: 18, fontWeight: 650, display: 'flex', alignItems: 'center', justifyContent: 'center', letterSpacing: -0.2, boxShadow: `0 12px 32px rgba(124,58,237,${pulse})` }}>
        Create account
      </div>
      <div style={{ textAlign: 'center', marginTop: 16, fontSize: 16.5, color: A.muted, opacity: sign.o, transform: `translateY(${sign.y}px)` }}>
        Already trading? <span style={{ color: A.violetSoft, fontWeight: 600 }}>Sign in</span>
      </div>
    </div>
  );
}

// ── status bar (static iOS-ish chrome for realism) ──
function StatusBar() {
  return (
    <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 54, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 30px', fontFamily: A.font, color: A.text, fontSize: 16, fontWeight: 600, zIndex: 5 }}>
      <span>9:41</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <svg width="18" height="12" viewBox="0 0 18 12" fill="none"><rect x="0" y="7" width="3" height="5" rx="1" fill="#F4F1FA"/><rect x="5" y="4" width="3" height="8" rx="1" fill="#F4F1FA"/><rect x="10" y="1" width="3" height="11" rx="1" fill="#F4F1FA"/><rect x="15" y="1" width="3" height="11" rx="1" fill="rgba(244,241,250,0.4)"/></svg>
        <svg width="22" height="12" viewBox="0 0 22 12" fill="none"><rect x="1" y="1" width="18" height="10" rx="3" stroke="rgba(244,241,250,0.5)"/><rect x="3" y="3" width="13" height="6" rx="1.5" fill="#F4F1FA"/><rect x="20" y="4" width="1.5" height="4" rx="0.75" fill="rgba(244,241,250,0.5)"/></svg>
      </div>
    </div>
  );
}

function WelcomeAnimScene() {
  return (
    <div style={{ position: 'absolute', inset: 0, background: A.bg, overflow: 'hidden' }}>
      <PowerFlowBg />
      <Ignition />
      <StatusBar />
      <LogoSplash />
      <WelcomeContent />
      {/* home indicator */}
      <div style={{ position: 'absolute', bottom: 9, left: '50%', transform: 'translateX(-50%)', width: 138, height: 5, borderRadius: 3, background: 'rgba(244,241,250,0.5)', zIndex: 6 }} />
    </div>
  );
}

Object.assign(window, { WelcomeAnimScene });
