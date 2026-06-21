// GridTokenX — Electrical Billing (monthly statement)
// Net bill = grid import − P2P energy sold. Same dark + purple system.
// green/red reserved for credit/charge. Exports BillingPage to window.

const BL = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  surface2: 'rgba(255,255,255,0.03)',
  border: 'rgba(255,255,255,0.09)',
  hair: 'rgba(255,255,255,0.07)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.54)',
  faint: 'rgba(244,241,250,0.34)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  up: '#2FD08A',
  down: '#FF5C6C',
  gold: '#FFD166',
  blue: '#7CA8FF',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function BIcon({ d, c = BL.violetSoft, s = 18, sw = 2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const BP = {
  back: 'M15 6l-6 6 6 6',
  chev: 'M9 6l6 6-6 6',
  down: 'M12 5v14M5 12l7 7 7-7',
  doc: 'M6 3h9l3 3v15H6zM15 3v4h3',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  sun: 'M12 5V3M12 21v-2M5 12H3M21 12h-2M6.4 6.4L5 5M18.6 6.4L20 5M6.4 17.6L5 19M18.6 17.6L20 19M12 8a4 4 0 100 8 4 4 0 000-8z',
  grid: 'M3 9h18M3 15h18M9 3v18M15 3v18',
  swap: 'M7 10l-3 3 3 3M4 13h12M17 14l3-3-3-3M20 11H8',
  meter: 'M12 3a9 9 0 00-9 9 9 9 0 003 6.7M12 3a9 9 0 019 9 9 9 0 01-3 6.7M12 12l4-3',
  check: 'M4 12.5l5 5 11-12',
  card: 'M3 7h18v10H3zM3 10h18',
  info: 'M12 16v-4M12 8h.01M12 3a9 9 0 100 18 9 9 0 000-18z',
  leaf: 'M5 21c0-7 4-12 14-13 0 9-5 14-12 14a6 6 0 01-2-1zM9 17c2-3 5-5 8-6',
};

function group(n) { return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

// past statements
const HISTORY = [
  { m: 'May 2026', amt: 612.40, paid: true },
  { m: 'Apr 2026', amt: 738.10, paid: true },
  { m: 'Mar 2026', amt: 689.55, paid: true },
];

function BillingPage() {
  // figures (THB)
  const gridImport = { kwh: 214.0, cost: 1043.30 };   // bought from grid
  const p2pSold    = { kwh: 96.4,  credit: 412.90 };   // sold to neighbours
  const serviceFee = 38.00;
  const net = gridImport.cost - p2pSold.credit + serviceFee;
  const due = '28 Jun 2026';

  const Line = ({ icon, color, label, sub, amount, credit, strong }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 0' }}>
      <div style={{ width: 36, height: 36, borderRadius: 11, flexShrink: 0, background: `${color}18`, border: `1px solid ${color}40`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <BIcon d={icon} c={color} s={18} sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 600 }}>{label}</div>
        {sub && <div style={{ fontSize: 12.5, color: BL.faint, marginTop: 2 }}>{sub}</div>}
      </div>
      <div style={{ fontSize: 15, fontWeight: 700, fontFamily: BL.mono, color: credit ? BL.up : BL.text }}>
        {credit ? '−' : ''}฿{group(amount)}
      </div>
    </div>
  );

  // breakdown bar: import vs sold
  const totalKwh = gridImport.kwh + p2pSold.kwh;

  return (
    <div style={{ position: 'absolute', inset: 0, background: BL.bg, fontFamily: BL.font, color: BL.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <BIcon d={BP.back} c={BL.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 20, fontWeight: 700, letterSpacing: -0.3 }}>Electrical billing</span>
        <BIcon d={BP.doc} c={BL.muted} s={20} sw={1.8} />
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* hero: amount due */}
        <div style={{ borderRadius: 22, padding: '20px 20px 18px', background: BL.grad, boxShadow: '0 14px 36px rgba(124,58,237,0.42)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -50, right: -30, width: 170, height: 170, borderRadius: '50%', background: 'rgba(255,255,255,0.1)' }} />
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ fontSize: 13, fontWeight: 600, color: 'rgba(255,255,255,0.85)' }}>Amount due · June 2026</span>
              <span style={{ fontSize: 11.5, fontWeight: 700, padding: '3px 9px', borderRadius: 999, background: 'rgba(255,209,102,0.28)', color: '#fff' }}>UNPAID</span>
            </div>
            <div style={{ fontSize: 44, fontWeight: 800, fontFamily: BL.mono, letterSpacing: -1.5, marginTop: 6 }}>฿{group(net)}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 4, fontSize: 13, color: 'rgba(255,255,255,0.85)' }}>
              <BIcon d={BP.info} c="rgba(255,255,255,0.85)" s={14} sw={2} /> Due {due} · Meter GTX-5821
            </div>
            {/* usage split bar */}
            <div style={{ display: 'flex', height: 8, borderRadius: 999, overflow: 'hidden', marginTop: 16, background: 'rgba(0,0,0,0.2)' }}>
              <div style={{ width: (gridImport.kwh / totalKwh * 100) + '%', background: 'rgba(255,255,255,0.92)' }} />
              <div style={{ width: (p2pSold.kwh / totalKwh * 100) + '%', background: 'rgba(47,208,138,0.95)' }} />
            </div>
            <div style={{ display: 'flex', gap: 16, marginTop: 9 }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>
                <span style={{ width: 7, height: 7, borderRadius: 2, background: 'rgba(255,255,255,0.92)' }} />Imported {gridImport.kwh} kWh
              </span>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>
                <span style={{ width: 7, height: 7, borderRadius: 2, background: 'rgba(47,208,138,0.95)' }} />Sold {p2pSold.kwh} kWh
              </span>
            </div>
          </div>
        </div>

        {/* breakdown */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: BL.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 2px 2px' }}>This period</div>
          <div style={{ borderRadius: 18, background: BL.surface, border: `1px solid ${BL.border}`, padding: '2px 16px' }}>
            <Line icon={BP.grid} color={BL.blue} label="Grid electricity" sub={`${gridImport.kwh} kWh imported · ฿4.88/kWh`} amount={gridImport.cost} />
            <div style={{ height: 1, background: BL.hair }} />
            <Line icon={BP.swap} color={BL.up} label="P2P energy sold" sub={`${p2pSold.kwh} kWh to neighbours`} amount={p2pSold.credit} credit />
            <div style={{ height: 1, background: BL.hair }} />
            <Line icon={BP.meter} color={BL.violet} label="Service & grid fee" sub="Fixed monthly" amount={serviceFee} />
            <div style={{ height: 1, background: BL.hair }} />
            {/* total */}
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '14px 0' }}>
              <span style={{ fontSize: 15, fontWeight: 700 }}>Net total</span>
              <span style={{ fontSize: 20, fontWeight: 800, fontFamily: BL.mono, color: BL.violetSoft }}>฿{group(net)}</span>
            </div>
          </div>
        </div>

        {/* savings callout */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 15px', borderRadius: 14, background: 'rgba(47,208,138,0.1)', border: '1px solid rgba(47,208,138,0.28)' }}>
          <BIcon d={BP.leaf} c={BL.up} s={20} sw={1.8} />
          <span style={{ flex: 1, fontSize: 13, color: BL.muted, lineHeight: 1.4 }}>Selling your solar cut this bill by <b style={{ color: BL.up }}>฿412.90</b> — about <b style={{ color: BL.text }}>40%</b> off grid-only.</span>
        </div>

        {/* past statements */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: BL.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 2px 8px' }}>Past statements</div>
          <div style={{ borderRadius: 18, background: BL.surface, border: `1px solid ${BL.border}`, overflow: 'hidden' }}>
            {HISTORY.map((h, i) => (
              <div key={h.m} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px', borderTop: i ? `1px solid ${BL.hair}` : 'none' }}>
                <div style={{ width: 34, height: 34, borderRadius: 10, flexShrink: 0, background: BL.surface2, border: `1px solid ${BL.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <BIcon d={BP.doc} c={BL.muted} s={16} sw={1.8} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14.5, fontWeight: 600 }}>{h.m}</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 12, color: BL.up, marginTop: 2 }}>
                    <BIcon d={BP.check} c={BL.up} s={12} sw={2.6} /> Paid
                  </div>
                </div>
                <span style={{ fontSize: 14.5, fontWeight: 700, fontFamily: BL.mono, color: BL.muted }}>฿{group(h.amt)}</span>
                <BIcon d={BP.chev} c={BL.faint} s={16} sw={2} />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* pay CTA */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${BL.border}`, background: BL.bg }}>
        <button style={{ width: '100%', height: 56, border: 'none', borderRadius: 16, cursor: 'pointer', fontFamily: BL.font, fontSize: 17, fontWeight: 700, color: '#fff', background: BL.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9 }}>
          <BIcon d={BP.card} c="#fff" s={20} sw={2} /> Pay ฿{group(net)}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { BillingPage });
