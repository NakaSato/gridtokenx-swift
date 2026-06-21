// GridTokenX — mobile Profile / Wallet page
// Same dark + purple system; green/red reserved for gains/losses.
// Exports WalletPage to window.

const W = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.045)',
  surface2: 'rgba(255,255,255,0.07)',
  border: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.54)',
  faint: 'rgba(244,241,250,0.32)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  up: '#2FD08A',
  down: '#FF5C6C',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, "Roboto Mono", monospace',
};

function WIcon({ d, c = W.violetSoft, s = 18, sw = 2 }) {
  return (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}
const PATH = {
  deposit: 'M12 5v14M5 12l7 7 7-7',     // down arrow (receive)
  send: 'M12 19V5M5 12l7-7 7 7',         // up arrow (send)
  withdraw: 'M4 7h16M4 12h16M4 17h10',   // bars (bank)
  swap: 'M7 10l-3 3 3 3M4 13h12M17 14l3-3-3-3M20 11H8',
  gear: 'M12 9a3 3 0 100 6 3 3 0 000-6zM19 12a7 7 0 00-.1-1.2l2-1.5-2-3.4-2.3 1a7 7 0 00-2-1.2l-.3-2.5H9.7l-.3 2.5a7 7 0 00-2 1.2l-2.3-1-2 3.4 2 1.5A7 7 0 005 12a7 7 0 00.1 1.2l-2 1.5 2 3.4 2.3-1a7 7 0 002 1.2l.3 2.5h4.6l.3-2.5a7 7 0 002-1.2l2.3 1 2-3.4-2-1.5A7 7 0 0019 12z',
  copy: 'M9 9h10v10H9zM5 15V5h10',
  chev: 'M9 6l6 6-6 6',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  meter: 'M12 3a9 9 0 00-9 9 9 9 0 003 6.7M12 3a9 9 0 019 9 9 9 0 01-3 6.7M12 12l4-3',
  bank: 'M4 9h16M5 9l7-5 7 5M6 9v8M10 9v8M14 9v8M18 9v8M4 20h16',
  shield: 'M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3zM9 11.5l2 2 4-4',
};

function ActionBtn({ icon, label, primary }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
      <button style={{
        width: '100%', height: 56, borderRadius: 16, cursor: 'pointer',
        background: primary ? W.grad : W.surface, border: primary ? 'none' : `1px solid ${W.border}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: primary ? '0 8px 20px rgba(124,58,237,0.4)' : 'none',
      }}>
        <WIcon d={icon} c={primary ? '#fff' : W.violetSoft} s={21} />
      </button>
      <span style={{ fontSize: 12, color: primary ? W.text : W.muted, fontWeight: 600 }}>{label}</span>
    </div>
  );
}

function GtxGlyph() {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 3 }}>
      {[0,1,2,3].map(i => <div key={i} style={{ width: 6, height: 6, borderRadius: 2, background: i===0 ? '#fff' : 'rgba(255,255,255,0.62)' }} />)}
    </div>
  );
}

function Holding({ markBg, markBorder, glyph, name, sub, amount, value, change }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px' }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0, background: markBg, border: markBorder, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{glyph}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15.5, fontWeight: 650 }}>{name}</div>
        <div style={{ fontSize: 12.5, color: W.faint, marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{ textAlign: 'right' }}>
        <div style={{ fontSize: 15, fontWeight: 700, fontFamily: W.mono }}>{value}</div>
        <div style={{ fontSize: 12, color: change > 0 ? W.up : change < 0 ? W.down : W.faint, fontWeight: 600, marginTop: 2 }}>
          {amount}
        </div>
      </div>
    </div>
  );
}

function Txn({ kind, title, sub, amt, pos }) {
  const arrow = { in: PATH.deposit, out: PATH.send }[kind];
  const c = pos ? W.up : W.down;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 16px' }}>
      <div style={{
        width: 36, height: 36, borderRadius: 11, flexShrink: 0,
        background: pos ? 'rgba(47,208,138,0.14)' : 'rgba(255,92,108,0.14)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <WIcon d={arrow} c={c} s={16} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 600 }}>{title}</div>
        <div style={{ fontSize: 12, color: W.faint, marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{ fontSize: 14.5, fontWeight: 700, fontFamily: W.mono, color: c }}>{amt}</div>
    </div>
  );
}

function WalletPage() {
  const [tab, setTab] = React.useState('tokens');

  const holdings = [
    { markBg: W.grad, glyph: <GtxGlyph />, name: 'GridTokenX', sub: '968.40 GTX', value: '฿4,182', amount: '+2.45%', change: 1 },
    { markBg: 'rgba(224,162,60,0.18)', markBorder: '1px solid rgba(224,162,60,0.4)', glyph: <WIcon d={PATH.bolt} c="#E0A23C" s={20} sw={2} />, name: 'kWh credits', sub: 'Tradeable energy', value: '12.4 kWh', amount: '≈ ฿53.50', change: 0 },
    { markBg: W.surface2, markBorder: `1px solid ${W.border}`, glyph: <span style={{ fontSize: 18, fontWeight: 800, color: W.violetSoft, fontFamily: W.mono }}>฿</span>, name: 'THB cash', sub: 'Settlement balance', value: '฿320.00', amount: 'Available', change: 0 },
  ];
  const alloc = [['GTX', 4182, W.violet], ['kWh', 53.5, '#E0A23C'], ['THB', 320, '#8aa0c0']];
  const allocTotal = alloc.reduce((a, x) => a + x[1], 0);

  const txns = [
    { kind: 'in', title: 'Sold 5.4 kWh', sub: 'Zone 2 → Zone 4 · 2h ago', amt: '+฿23.20', pos: 1 },
    { kind: 'in', title: 'Solar payout', sub: 'Daily generation · 6h ago', amt: '+฿88.40', pos: 1 },
    { kind: 'out', title: 'Bought 3.2 kWh', sub: 'Zone 1 → Zone 2 · yesterday', amt: '−฿13.70', pos: 0 },
    { kind: 'out', title: 'Withdraw to bank', sub: 'SCB ••4192 · yesterday', amt: '−฿200.00', pos: 0 },
    { kind: 'in', title: 'Deposit', sub: 'PromptPay · 3d ago', amt: '+฿500.00', pos: 1 },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, background: W.bg, fontFamily: W.font, color: W.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Wallet</span>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: W.surface, border: `1px solid ${W.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <WIcon d={PATH.gear} c={W.muted} s={18} sw={1.6} />
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 16px 40px', display: 'flex', flexDirection: 'column', gap: 18 }}>
        {/* profile */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
          <div style={{
            width: 54, height: 54, borderRadius: '50%', background: W.grad, flexShrink: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 700,
            boxShadow: '0 6px 18px rgba(124,58,237,0.45)',
          }}>MC</div>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <span style={{ fontSize: 18, fontWeight: 700 }}>Maya Chen</span>
              <svg width="15" height="15" viewBox="0 0 24 24" fill={W.violet}><path d="M12 2l2.4 1.8 3-.3 1 2.8 2.6 1.5-.9 2.9.9 2.9-2.6 1.5-1 2.8-3-.3L12 22l-2.4-1.8-3 .3-1-2.8L3 16.2l.9-2.9L3 10.4l2.6-1.5 1-2.8 3 .3L12 2z"/><path d="M8.5 12l2.3 2.3 4.7-4.8" stroke="#0B0712" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </div>
            <div style={{ fontSize: 13, color: W.muted, marginTop: 2 }}>Prosumer · Zone 2 · Bangkok</div>
          </div>
        </div>

        {/* wallet address chip */}

        {/* balance hero */}
        <div style={{ borderRadius: 22, padding: '20px 20px 18px', background: W.grad, boxShadow: '0 14px 40px rgba(124,58,237,0.4)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -40, right: -30, width: 150, height: 150, borderRadius: '50%', background: 'rgba(255,255,255,0.12)' }} />
          <div style={{ position: 'relative' }}>
            <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.78)', fontWeight: 600 }}>Portfolio value</div>
            <div style={{ fontSize: 36, fontWeight: 800, fontFamily: W.mono, marginTop: 4, letterSpacing: -0.5 }}>฿4,502.40</div>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, marginTop: 6, padding: '3px 9px', borderRadius: 999, background: 'rgba(255,255,255,0.2)', fontSize: 12.5, fontWeight: 700 }}>
              ↑ ฿108.20 · 2.45% today
            </div>
            {/* allocation bar */}
            <div style={{ display: 'flex', height: 7, borderRadius: 999, overflow: 'hidden', marginTop: 16, background: 'rgba(0,0,0,0.18)' }}>
              {alloc.map(([l, v, c]) => <div key={l} style={{ width: (v / allocTotal * 100) + '%', background: l === 'GTX' ? 'rgba(255,255,255,0.92)' : l === 'kWh' ? 'rgba(255,255,255,0.55)' : 'rgba(255,255,255,0.28)' }} />)}
            </div>
            <div style={{ display: 'flex', gap: 14, marginTop: 9 }}>
              {alloc.map(([l, v]) => (
                <div key={l} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.82)', fontWeight: 600 }}>
                  <span style={{ width: 7, height: 7, borderRadius: 2, background: l === 'GTX' ? 'rgba(255,255,255,0.92)' : l === 'kWh' ? 'rgba(255,255,255,0.55)' : 'rgba(255,255,255,0.28)' }} />
                  {l} {Math.round(v / allocTotal * 100)}%
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* actions */}
        <div style={{ display: 'flex', gap: 8 }}>
          <ActionBtn icon={PATH.deposit} label="Deposit" primary />
          <ActionBtn icon={PATH.send} label="Send" />
          <ActionBtn icon={PATH.withdraw} label="Withdraw" />
          <ActionBtn icon={PATH.swap} label="Swap" />
        </div>

        {/* this-month stats */}
        <div style={{ display: 'flex', gap: 10 }}>
          {[['Sold', '84 kWh'], ['Earned', '฿362'], ['CO₂ saved', '18.4 kg']].map(([k, v], i) => (
            <div key={k} style={{ flex: 1, padding: '12px 13px', borderRadius: 14, background: W.surface, border: `1px solid ${W.border}` }}>
              <div style={{ fontSize: 10.5, color: W.muted, textTransform: 'uppercase', letterSpacing: 0.3 }}>{k}</div>
              <div style={{ fontSize: 17, fontWeight: 700, fontFamily: W.mono, marginTop: 4, color: i === 2 ? W.up : W.text }}>{v}</div>
            </div>
          ))}
        </div>

        {/* segmented */}
        <div style={{ display: 'flex', gap: 6, padding: 5, background: W.surface, borderRadius: 14, border: `1px solid ${W.border}` }}>
          {[['tokens', 'Tokens'], ['activity', 'Activity']].map(([k, l]) => {
            const on = tab === k;
            return (
              <button key={k} onClick={() => setTab(k)} style={{
                flex: 1, height: 38, border: 'none', borderRadius: 10, cursor: 'pointer',
                fontFamily: W.font, fontSize: 14.5, fontWeight: 650, transition: 'all .15s',
                background: on ? W.grad : 'transparent', color: on ? '#fff' : W.muted,
                boxShadow: on ? '0 4px 14px rgba(124,58,237,0.4)' : 'none',
              }}>{l}</button>
            );
          })}
        </div>

        {/* list */}
        <div style={{ borderRadius: 18, background: W.surface, border: `1px solid ${W.border}`, overflow: 'hidden' }}>
          {tab === 'tokens'
            ? holdings.map((h, i) => (
                <React.Fragment key={i}>
                  {i > 0 && <div style={{ height: 1, background: W.border, marginLeft: 69 }} />}
                  <Holding {...h} />
                </React.Fragment>
              ))
            : txns.map((t, i) => (
                <React.Fragment key={i}>
                  {i > 0 && <div style={{ height: 1, background: W.border, marginLeft: 65 }} />}
                  <Txn {...t} />
                </React.Fragment>
              ))}
        </div>

        {/* settings rows */}
        <div style={{ borderRadius: 18, background: W.surface, border: `1px solid ${W.border}`, overflow: 'hidden' }}>
          {[[PATH.meter, 'Linked meter', 'Solar 5.2 kW'], [PATH.bank, 'Payout method', 'SCB ••4192'], [PATH.shield, 'Security & recovery', '']].map(([icon, l, val], i) => (
            <React.Fragment key={l}>
              {i > 0 && <div style={{ height: 1, background: W.border, marginLeft: 60 }} />}
              <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px' }}>
                <div style={{ width: 32, height: 32, borderRadius: 9, flexShrink: 0, background: 'rgba(155,107,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <WIcon d={icon} c={W.violetSoft} s={17} sw={1.8} />
                </div>
                <span style={{ flex: 1, fontSize: 14.5, fontWeight: 550 }}>{l}</span>
                {val && <span style={{ fontSize: 13, color: W.muted, marginRight: 4 }}>{val}</span>}
                <WIcon d={PATH.chev} c={W.faint} s={16} sw={2} />
              </div>
            </React.Fragment>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { WalletPage });
