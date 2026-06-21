// GridTokenX — Historical Billing (list + deep detail per statement)
// Internal router: list view → tap any statement → full statement detail.
// Distinct global names (HB*) to avoid collision with billing.jsx.

const HB = {
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

function HBIcon({ d, c = HB.violetSoft, s = 18, sw = 2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const HBP = {
  back: 'M15 6l-6 6 6 6',
  chev: 'M9 6l6 6-6 6',
  doc: 'M6 3h9l3 3v15H6zM15 3v4h3',
  download: 'M12 4v11M7 11l5 5 5-5M5 20h14',
  share: 'M12 3v12M8 7l4-4 4 4M5 12v8h14v-8',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  grid: 'M3 9h18M3 15h18M9 3v18M15 3v18',
  swap: 'M7 10l-3 3 3 3M4 13h12M17 14l3-3-3-3M20 11H8',
  meter: 'M12 3a9 9 0 00-9 9 9 9 0 003 6.7M12 3a9 9 0 019 9 9 9 0 01-3 6.7M12 12l4-3',
  check: 'M4 12.5l5 5 11-12',
  card: 'M3 7h18v10H3zM3 10h18',
  info: 'M12 16v-4M12 8h.01M12 3a9 9 0 100 18 9 9 0 000-18z',
  calendar: 'M4 6h16v15H4zM4 10h16M8 3v4M16 3v4',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zM20 20l-4-4',
  receipt: 'M6 3h12v18l-2-1.5L14 21l-2-1.5L10 21l-2-1.5L6 21zM9 8h6M9 12h6',
};

function hbMoney(n) { return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

// ── statement dataset (12 months) ──
const HB_DATA = [
  { id: '2026-05', m: 'May', y: 2026, label: 'May 2026', amt: 612.40, import: 198.0, sold: 104.2, fee: 38, gridCost: 966.20, credit: 391.80, paid: true, paidOn: '26 May 2026', method: 'PromptPay', read0: 41820, read1: 42018 },
  { id: '2026-04', m: 'Apr', y: 2026, label: 'Apr 2026', amt: 738.10, import: 232.0, sold: 88.6, fee: 38, gridCost: 1132.20, credit: 432.10, paid: true, paidOn: '27 Apr 2026', method: 'Debit ••1234', read0: 41588, read1: 41820 },
  { id: '2026-03', m: 'Mar', y: 2026, label: 'Mar 2026', amt: 689.55, import: 221.0, sold: 92.0, fee: 38, gridCost: 1078.80, credit: 427.25, paid: true, paidOn: '25 Mar 2026', method: 'PromptPay', read0: 41367, read1: 41588 },
  { id: '2026-02', m: 'Feb', y: 2026, label: 'Feb 2026', amt: 534.20, import: 176.0, sold: 118.4, fee: 38, gridCost: 858.90, credit: 362.70, paid: true, paidOn: '24 Feb 2026', method: 'Bank transfer', read0: 41191, read1: 41367 },
  { id: '2026-01', m: 'Jan', y: 2026, label: 'Jan 2026', amt: 801.30, import: 248.0, sold: 71.2, fee: 38, gridCost: 1210.50, credit: 447.20, paid: true, paidOn: '26 Jan 2026', method: 'Debit ••1234', read0: 40943, read1: 41191 },
  { id: '2025-12', m: 'Dec', y: 2025, label: 'Dec 2025', amt: 845.90, import: 261.0, sold: 64.0, fee: 38, gridCost: 1273.60, credit: 465.70, paid: true, paidOn: '27 Dec 2025', method: 'PromptPay', read0: 40682, read1: 40943 },
  { id: '2025-11', m: 'Nov', y: 2025, label: 'Nov 2025', amt: 712.00, import: 224.0, sold: 86.0, fee: 38, gridCost: 1094.40, credit: 420.40, paid: true, paidOn: '25 Nov 2025', method: 'PromptPay', read0: 40458, read1: 40682 },
  { id: '2025-10', m: 'Oct', y: 2025, label: 'Oct 2025', amt: 598.70, import: 190.0, sold: 109.6, fee: 38, gridCost: 928.40, credit: 367.70, paid: true, paidOn: '26 Oct 2025', method: 'Bank transfer', read0: 40268, read1: 40458 },
];

// ── LIST VIEW ──
function HistoricalBilling() {
  const [openId, setOpenId] = React.useState(null);
  const [year, setYear] = React.useState(2026);

  if (openId) return <StatementDetail data={HB_DATA.find(d => d.id === openId)} onBack={() => setOpenId(null)} />;

  const years = [2026, 2025];
  const rows = HB_DATA.filter(d => d.y === year);
  const yearTotal = rows.reduce((a, d) => a + d.amt, 0);
  const yearKwh = rows.reduce((a, d) => a + d.import, 0);
  const avg = yearTotal / rows.length;
  const maxAmt = Math.max(...HB_DATA.map(d => d.amt));

  return (
    <div style={{ position: 'absolute', inset: 0, background: HB.bg, fontFamily: HB.font, color: HB.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <HBIcon d={HBP.back} c={HB.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 20, fontWeight: 700, letterSpacing: -0.3 }}>Billing history</span>
        <HBIcon d={HBP.search} c={HB.muted} s={20} sw={1.8} />
      </div>

      {/* year segmented */}
      <div style={{ flexShrink: 0, padding: '8px 16px 4px' }}>
        <div style={{ display: 'flex', gap: 6, padding: 4, background: HB.surface, borderRadius: 13, border: `1px solid ${HB.border}` }}>
          {years.map(y => {
            const on = year === y;
            return (
              <button key={y} onClick={() => setYear(y)} style={{
                flex: 1, height: 34, border: 'none', borderRadius: 10, cursor: 'pointer',
                fontFamily: HB.font, fontSize: 14, fontWeight: 650, transition: 'all .15s',
                background: on ? HB.grad : 'transparent', color: on ? '#fff' : HB.muted,
                boxShadow: on ? '0 4px 12px rgba(124,58,237,0.35)' : 'none',
              }}>{y}</button>
            );
          })}
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* year summary */}
        <div style={{ borderRadius: 18, background: HB.surface, border: `1px solid ${HB.border}`, padding: '15px 16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <span style={{ fontSize: 12.5, color: HB.muted }}>Total billed in {year}</span>
            <span style={{ fontSize: 11.5, color: HB.faint }}>{rows.length} statements</span>
          </div>
          <div style={{ fontSize: 30, fontWeight: 800, fontFamily: HB.mono, letterSpacing: -1, marginTop: 3 }}>฿{hbMoney(yearTotal)}</div>
          <div style={{ display: 'flex', gap: 22, marginTop: 10 }}>
            <div><div style={{ fontSize: 11, color: HB.faint, textTransform: 'uppercase', letterSpacing: 0.4 }}>Avg / mo</div><div style={{ fontSize: 14.5, fontWeight: 700, fontFamily: HB.mono, marginTop: 2 }}>฿{hbMoney(avg)}</div></div>
            <div><div style={{ fontSize: 11, color: HB.faint, textTransform: 'uppercase', letterSpacing: 0.4 }}>Imported</div><div style={{ fontSize: 14.5, fontWeight: 700, fontFamily: HB.mono, marginTop: 2 }}>{yearKwh.toFixed(0)} kWh</div></div>
          </div>
          {/* mini bar chart */}
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 6, height: 54, marginTop: 16 }}>
            {rows.slice().reverse().map(d => (
              <div key={d.id} onClick={() => setOpenId(d.id)} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, cursor: 'pointer' }}>
                <div style={{ width: '100%', maxWidth: 18, height: (d.amt / maxAmt * 42) + 6, borderRadius: 5, background: HB.grad, opacity: 0.85 }} />
                <span style={{ fontSize: 9.5, color: HB.faint }}>{d.m[0]}</span>
              </div>
            ))}
          </div>
        </div>

        {/* statement list */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: HB.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 2px 8px' }}>Statements</div>
          <div style={{ borderRadius: 18, background: HB.surface, border: `1px solid ${HB.border}`, overflow: 'hidden' }}>
            {rows.map((d, i) => (
              <div key={d.id} onClick={() => setOpenId(d.id)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px', cursor: 'pointer', borderTop: i ? `1px solid ${HB.hair}` : 'none' }}>
                <div style={{ width: 38, height: 38, borderRadius: 11, flexShrink: 0, background: HB.surface2, border: `1px solid ${HB.border}`, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                  <span style={{ fontSize: 11, fontWeight: 800, color: HB.violetSoft, lineHeight: 1 }}>{d.m}</span>
                  <span style={{ fontSize: 8, color: HB.faint, marginTop: 1 }}>{String(d.y).slice(2)}</span>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 14.5, fontWeight: 650 }}>{d.label}</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 12, color: HB.up, marginTop: 2 }}>
                    <HBIcon d={HBP.check} c={HB.up} s={12} sw={2.6} /> Paid · {d.import.toFixed(0)} kWh
                  </div>
                </div>
                <span style={{ fontSize: 15, fontWeight: 700, fontFamily: HB.mono }}>฿{hbMoney(d.amt)}</span>
                <HBIcon d={HBP.chev} c={HB.faint} s={16} sw={2} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ── DEEP DETAIL VIEW (one per statement) ──
function StatementDetail({ data, onBack }) {
  const d = data;
  const net = d.gridCost - d.credit + d.fee;
  const totalKwh = d.import + d.sold;
  const rate = (d.gridCost / d.import);

  const Line = ({ icon, color, label, sub, amount, credit }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 0' }}>
      <div style={{ width: 36, height: 36, borderRadius: 11, flexShrink: 0, background: `${color}18`, border: `1px solid ${color}40`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <HBIcon d={icon} c={color} s={18} sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 600 }}>{label}</div>
        {sub && <div style={{ fontSize: 12.5, color: HB.faint, marginTop: 2 }}>{sub}</div>}
      </div>
      <div style={{ fontSize: 15, fontWeight: 700, fontFamily: HB.mono, color: credit ? HB.up : HB.text }}>
        {credit ? '−' : ''}฿{hbMoney(amount)}
      </div>
    </div>
  );

  const Meta = ({ label, value }) => (
    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '11px 0' }}>
      <span style={{ fontSize: 13.5, color: HB.muted }}>{label}</span>
      <span style={{ fontSize: 13.5, fontWeight: 600, fontFamily: HB.mono }}>{value}</span>
    </div>
  );

  return (
    <div style={{ position: 'absolute', inset: 0, background: HB.bg, fontFamily: HB.font, color: HB.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 11, background: HB.surface, border: `1px solid ${HB.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <HBIcon d={HBP.back} c={HB.violetSoft} s={18} sw={2} />
        </button>
        <span style={{ flex: 1, fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>{d.label}</span>
        <button style={{ width: 38, height: 38, borderRadius: 11, background: HB.surface, border: `1px solid ${HB.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <HBIcon d={HBP.share} c={HB.violetSoft} s={17} sw={1.8} />
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* hero */}
        <div style={{ borderRadius: 22, padding: '20px 20px 18px', background: HB.grad, boxShadow: '0 14px 36px rgba(124,58,237,0.42)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -50, right: -30, width: 170, height: 170, borderRadius: '50%', background: 'rgba(255,255,255,0.1)' }} />
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ fontSize: 13, fontWeight: 600, color: 'rgba(255,255,255,0.85)' }}>Net total paid</span>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 11.5, fontWeight: 700, padding: '3px 10px', borderRadius: 999, background: 'rgba(47,208,138,0.3)', color: '#fff' }}>
                <HBIcon d={HBP.check} c="#fff" s={12} sw={2.8} /> PAID
              </span>
            </div>
            <div style={{ fontSize: 44, fontWeight: 800, fontFamily: HB.mono, letterSpacing: -1.5, marginTop: 6 }}>฿{hbMoney(net)}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 4, fontSize: 13, color: 'rgba(255,255,255,0.85)' }}>
              <HBIcon d={HBP.calendar} c="rgba(255,255,255,0.85)" s={14} sw={2} /> Paid {d.paidOn} · {d.method}
            </div>
            {/* usage split */}
            <div style={{ display: 'flex', height: 8, borderRadius: 999, overflow: 'hidden', marginTop: 16, background: 'rgba(0,0,0,0.2)' }}>
              <div style={{ width: (d.import / totalKwh * 100) + '%', background: 'rgba(255,255,255,0.92)' }} />
              <div style={{ width: (d.sold / totalKwh * 100) + '%', background: 'rgba(47,208,138,0.95)' }} />
            </div>
            <div style={{ display: 'flex', gap: 16, marginTop: 9 }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>
                <span style={{ width: 7, height: 7, borderRadius: 2, background: 'rgba(255,255,255,0.92)' }} />Imported {d.import} kWh
              </span>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>
                <span style={{ width: 7, height: 7, borderRadius: 2, background: 'rgba(47,208,138,0.95)' }} />Sold {d.sold} kWh
              </span>
            </div>
          </div>
        </div>

        {/* breakdown */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: HB.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 2px 2px' }}>Breakdown</div>
          <div style={{ borderRadius: 18, background: HB.surface, border: `1px solid ${HB.border}`, padding: '2px 16px' }}>
            <Line icon={HBP.grid} color={HB.blue} label="Grid electricity" sub={`${d.import} kWh · ฿${rate.toFixed(2)}/kWh`} amount={d.gridCost} />
            <div style={{ height: 1, background: HB.hair }} />
            <Line icon={HBP.swap} color={HB.up} label="P2P energy sold" sub={`${d.sold} kWh to neighbours`} amount={d.credit} credit />
            <div style={{ height: 1, background: HB.hair }} />
            <Line icon={HBP.meter} color={HB.violet} label="Service & grid fee" sub="Fixed monthly" amount={d.fee} />
            <div style={{ height: 1, background: HB.hair }} />
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '14px 0' }}>
              <span style={{ fontSize: 15, fontWeight: 700 }}>Net total</span>
              <span style={{ fontSize: 20, fontWeight: 800, fontFamily: HB.mono, color: HB.violetSoft }}>฿{hbMoney(net)}</span>
            </div>
          </div>
        </div>

        {/* meter & payment */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: HB.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '0 2px 2px' }}>Meter & payment</div>
          <div style={{ borderRadius: 18, background: HB.surface, border: `1px solid ${HB.border}`, padding: '2px 16px' }}>
            <Meta label="Meter" value="GTX-5821" />
            <div style={{ height: 1, background: HB.hair }} />
            <Meta label="Previous read" value={`${d.read0} kWh`} />
            <div style={{ height: 1, background: HB.hair }} />
            <Meta label="Current read" value={`${d.read1} kWh`} />
            <div style={{ height: 1, background: HB.hair }} />
            <Meta label="Payment method" value={d.method} />
            <div style={{ height: 1, background: HB.hair }} />
            <Meta label="Reference" value={`GTX-${d.id.replace('-', '')}`} />
          </div>
        </div>
      </div>

      {/* download CTA */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${HB.border}`, background: HB.bg, display: 'flex', gap: 10 }}>
        <button style={{ flex: 1, height: 54, border: `1px solid ${HB.border}`, borderRadius: 15, cursor: 'pointer', fontFamily: HB.font, fontSize: 15.5, fontWeight: 650, color: HB.text, background: HB.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
          <HBIcon d={HBP.receipt} c={HB.violetSoft} s={18} sw={1.8} /> View receipt
        </button>
        <button style={{ flex: 1, height: 54, border: 'none', borderRadius: 15, cursor: 'pointer', fontFamily: HB.font, fontSize: 15.5, fontWeight: 700, color: '#fff', background: HB.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
          <HBIcon d={HBP.download} c="#fff" s={18} sw={2} /> PDF
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { HistoricalBilling, StatementDetail });
