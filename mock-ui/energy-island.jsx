// GridTokenX — Dynamic Island energy live-activity (buy / sell)
// Renders into <IOSDevice island={...}>. Exports compact + expanded variants.
// Dark + purple; green=sell/earn, red/violet=buy/spend.

const DI = {
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.6)',
  faint: 'rgba(244,241,250,0.4)',
  up: '#2FD08A',       // sell / earning
  down: '#FF5C6C',     // buy / spending
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  gold: '#FFD166',
  mono: '"SF Mono", ui-monospace, monospace',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
};

function DIcon({ d, c, s = 16, sw = 2.2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const DP = {
  up: 'M12 19V5M5 12l7-7 7 7',
  down: 'M12 5v14M5 12l7 7 7-7',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  sun: 'M12 5V3M12 21v-2M5 12H3M21 12h-2M6.4 6.4L5 5M18.6 6.4L20 5M6.4 17.6L5 19M18.6 17.6L20 19M12 8a4 4 0 100 8 4 4 0 000-8z',
  send: 'M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z',
  receive: 'M12 4v12M6 10l6 6 6-6M5 20h14',
  check: 'M5 12.5l5 5 11-12',
};

// tiny animated equalizer bars (energy flowing)
function FlowBars({ color, n = 4 }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 2, height: 14 }}>
      {Array.from({ length: n }).map((_, i) => (
        <div key={i} style={{
          width: 2.5, borderRadius: 2, background: color,
          height: [6, 12, 8, 14][i % 4],
          animation: `diflow 0.9s ease-in-out ${i * 0.12}s infinite alternate`,
        }} />
      ))}
    </div>
  );
}

const DI_KEYFRAMES = `@keyframes diflow { from { transform: scaleY(0.45); opacity:.6 } to { transform: scaleY(1); opacity:1 } }
@keyframes dipop { 0% { transform: scale(0.3); opacity: 0 } 60% { transform: scale(1.12) } 100% { transform: scale(1); opacity: 1 } }
@keyframes didraw { to { stroke-dashoffset: 0 } }
@keyframes difade { from { opacity: 0; transform: translateY(4px) } to { opacity: 1; transform: translateY(0) } }
@keyframes diexpand { from { transform: scale(0.86); opacity: 0 } to { transform: scale(1); opacity: 1 } }`;

// success check disc (animated draw)
function CheckDisc({ size = 40, color = DI.up }) {
  return (
    <div style={{ width: size, height: size, borderRadius: '50%', flexShrink: 0, background: `${color}22`, border: `1.5px solid ${color}`, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: 'dipop 0.5s cubic-bezier(.2,.8,.3,1.2) both' }}>
      <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none">
        <path d={DP.check} stroke={color} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" style={{ strokeDasharray: 30, strokeDashoffset: 30, animation: 'didraw 0.4s 0.25s ease-out forwards' }} />
      </svg>
    </div>
  );
}

// ── COMPACT — pill with indicators on both sides ──
function EnergyIslandCompact({ side = 'sell' }) {
  const selling = side === 'sell';
  const c = selling ? DI.up : DI.down;
  return (
    <div style={{ width: 126, height: 37, borderRadius: 24, background: '#000', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 13px', fontFamily: DI.font }}>
      <style>{DI_KEYFRAMES}</style>
      <DIcon d={DP.bolt} c={c} s={15} sw={2.2} fill={c} />
      <FlowBars color={c} n={4} />
    </div>
  );
}

// ── MINIMAL+ — two stacked rounded blobs (true DI separated state) ──
function EnergyIslandSplit() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontFamily: DI.font }}>
      {/* main pill */}
      <div style={{ height: 37, borderRadius: 24, background: '#000', display: 'flex', alignItems: 'center', gap: 7, padding: '0 14px' }}>
        <DIcon d={DP.bolt} c={DI.up} s={15} sw={2.2} fill={DI.up} />
        <span style={{ fontSize: 13.5, fontWeight: 700, color: '#fff', fontFamily: DI.mono }}>+฿4.31</span>
      </div>
      {/* detached blob */}
      <div style={{ width: 37, height: 37, borderRadius: '50%', background: '#000', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <FlowBars color={DI.up} n={3} />
      </div>
    </div>
  );
}

// ── EXPANDED — full live activity ──
function EnergyIslandExpanded({ mode = 'sell' }) {
  const selling = mode === 'sell';
  const c = selling ? DI.up : DI.down;
  const title = selling ? 'Selling energy' : 'Buying energy';
  const rate = selling ? '+฿4.31' : '−฿4.28';
  const kwh = selling ? '5.4' : '3.2';
  const pct = selling ? 68 : 42;

  return (
    <div style={{ width: 360, borderRadius: 34, background: '#000', padding: '14px 18px 16px', fontFamily: DI.font, boxShadow: '0 18px 50px rgba(0,0,0,0.6)' }}>
      <style>{DI_KEYFRAMES}</style>
      {/* header row */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 40, height: 40, borderRadius: 13, flexShrink: 0, background: `${c}1F`, border: `1px solid ${c}55`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <DIcon d={DP.bolt} c={c} s={20} sw={2.2} fill={c} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
            <span style={{ fontSize: 15, fontWeight: 700, color: '#fff' }}>{title}</span>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: c, animation: 'diflow 1s ease-in-out infinite alternate' }} />
          </div>
          <div style={{ fontSize: 12.5, color: DI.muted, marginTop: 2 }}>Zone 2 · GridTokenX</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 18, fontWeight: 800, fontFamily: DI.mono, color: c }}>{rate}</div>
          <div style={{ fontSize: 11.5, color: DI.faint }}>per kWh</div>
        </div>
      </div>

      {/* progress */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 14 }}>
        <FlowBars color={c} n={5} />
        <div style={{ flex: 1, height: 6, borderRadius: 999, background: 'rgba(255,255,255,0.12)', overflow: 'hidden' }}>
          <div style={{ width: pct + '%', height: '100%', borderRadius: 999, background: c }} />
        </div>
        <span style={{ fontSize: 12.5, fontWeight: 700, color: '#fff', fontFamily: DI.mono }}>{kwh} kWh</span>
      </div>

      {/* footer stats */}
      <div style={{ display: 'flex', gap: 18, marginTop: 14 }}>
        {[[selling ? 'Earned' : 'Spent', (selling ? '+' : '−') + '฿' + (kwh * 4.3).toFixed(2)], ['Live for', '6 min'], ['Counterparty', '4 buyers']].map(([l, v]) => (
          <div key={l}>
            <div style={{ fontSize: 11, color: DI.faint, textTransform: 'uppercase', letterSpacing: 0.4 }}>{l}</div>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: '#fff', fontFamily: DI.mono, marginTop: 2 }}>{v}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── TX SUCCESS — compact pill (sending / receiving done) ──
function TxIslandCompact({ mode = 'send' }) {
  const sending = mode === 'send';
  const amt = sending ? '−25 GTX' : '+18 GTX';
  return (
    <div style={{ width: 126, height: 37, borderRadius: 24, background: '#000', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 11px 0 8px', fontFamily: DI.font }}>
      <style>{DI_KEYFRAMES}</style>
      <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'rgba(47,208,138,0.22)', border: `1px solid ${DI.up}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d={DP.check} stroke={DI.up} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" /></svg>
      </div>
      <span style={{ fontSize: 13, fontWeight: 700, color: '#fff', fontFamily: DI.mono }}>{amt}</span>
    </div>
  );
}

// ── TX SUCCESS — expanded (sending / receiving) ──
function TxIslandSuccess({ mode = 'send' }) {
  const sending = mode === 'send';
  const c = sending ? DI.violetSoft : DI.up;
  const title = sending ? 'Sent successfully' : 'Received';
  const who = sending ? 'To Somchai · @somchai_p' : 'From Noi · @noi.energy';
  const amount = sending ? '25.00 GTX' : '18.00 GTX';
  const fiat = sending ? '≈ ฿108.00' : '≈ ฿77.76';

  return (
    <div style={{ width: 360, borderRadius: 34, background: '#000', padding: '15px 18px 16px', fontFamily: DI.font, boxShadow: '0 18px 50px rgba(0,0,0,0.6)', animation: 'diexpand 0.34s cubic-bezier(.2,.8,.3,1) both' }}>
      <style>{DI_KEYFRAMES}</style>
      <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
        {/* success disc with directional glyph badge */}
        <div style={{ position: 'relative' }}>
          <CheckDisc size={44} color={DI.up} />
          <div style={{ position: 'absolute', bottom: -3, right: -3, width: 20, height: 20, borderRadius: '50%', background: sending ? DI.violet : DI.up, border: '2.5px solid #000', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <DIcon d={sending ? DP.send : DP.receive} c="#fff" s={10} sw={2.4} />
          </div>
        </div>
        <div style={{ flex: 1, animation: 'difade 0.4s 0.15s both' }}>
          <div style={{ fontSize: 15, fontWeight: 700, color: '#fff' }}>{title}</div>
          <div style={{ fontSize: 12.5, color: DI.muted, marginTop: 2 }}>{who}</div>
        </div>
        <div style={{ textAlign: 'right', animation: 'difade 0.4s 0.22s both' }}>
          <div style={{ fontSize: 17, fontWeight: 800, fontFamily: DI.mono, color: c }}>{sending ? '−' : '+'}{amount.split(' ')[0]}</div>
          <div style={{ fontSize: 11, color: DI.faint, fontFamily: DI.mono }}>{fiat}</div>
        </div>
      </div>
      {/* settle line */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 13, paddingTop: 12, borderTop: '1px solid rgba(255,255,255,0.1)', animation: 'difade 0.4s 0.3s both' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: DI.up }} />
        <span style={{ fontSize: 12, color: DI.muted }}>Settled on-chain</span>
        <span style={{ flex: 1 }} />
        <span style={{ fontSize: 11.5, color: DI.faint, fontFamily: DI.mono }}>0x7a3f…c2e1</span>
      </div>
    </div>
  );
}

Object.assign(window, { EnergyIslandCompact, EnergyIslandSplit, EnergyIslandExpanded, TxIslandCompact, TxIslandSuccess });
