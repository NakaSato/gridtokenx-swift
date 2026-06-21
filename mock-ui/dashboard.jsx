// GridTokenX — mobile trading dashboard (interactive)
// Purple primary; green/red reserved for buy/sell + gains/losses.
// Exports Dashboard to window.

const D = {
  bg: '#0B0712',
  panel: '#0E0A18',
  surface: 'rgba(255,255,255,0.045)',
  surface2: 'rgba(255,255,255,0.07)',
  border: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.54)',
  faint: 'rgba(244,241,250,0.32)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  buy: '#2FD08A',
  sell: '#FF5C6C',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, "Roboto Mono", monospace',
};

const MAX_KWH = 12.4;
const PRICE = 4.32;

// ── price chart (area sparkline with gradient fill) ──────────
const SERIES = {
  '1H': [4.28,4.30,4.27,4.31,4.29,4.33,4.30,4.34,4.32,4.35,4.33,4.36,4.34,4.38,4.36,4.39,4.37,4.40,4.38,4.32],
  '1D': [4.10,4.14,4.09,4.18,4.22,4.16,4.24,4.20,4.28,4.25,4.30,4.27,4.33,4.29,4.36,4.31,4.34,4.38,4.35,4.32],
  '1W': [3.92,4.02,3.96,4.10,4.06,4.18,4.12,4.22,4.16,4.28,4.24,4.20,4.30,4.26,4.34,4.29,4.36,4.31,4.38,4.32],
  '1M': [3.70,3.85,3.78,3.95,4.05,3.98,4.12,4.08,4.20,4.14,4.26,4.18,4.30,4.22,4.34,4.28,4.36,4.30,4.40,4.32],
};

function PriceChart({ data, color = D.buy, h = 68 }) {
  const min = Math.min(...data), max = Math.max(...data);
  const span = max - min || 1;
  const n = data.length;
  const X = (i) => (i / (n - 1)) * 100;
  const Y = (v) => 100 - ((v - min) / span) * 88 - 6;
  const line = data.map((v, i) => `${X(i)},${Y(v)}`).join(' ');
  const area = `0,100 ${line} 100,100`;
  const gid = 'pcg-' + color.replace('#', '');
  return (
    <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ width: '100%', height: h, display: 'block' }}>
      <defs>
        <linearGradient id={gid} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.3" />
          <stop offset="100%" stopColor={color} stopOpacity="0" />
        </linearGradient>
      </defs>
      <polygon points={area} fill={`url(#${gid})`} />
      <polyline points={line} fill="none" stroke={color} strokeWidth="1.5" vectorEffect="non-scaling-stroke" strokeLinejoin="round" strokeLinecap="round" />
      <circle cx={X(n - 1)} cy={Y(data[n - 1])} r="1.7" fill={color} vectorEffect="non-scaling-stroke" />
    </svg>
  );
}

// ── grid-network map ─────────────────────────────────────────
function GridMap() {
  // node: {x%, y%, type} type: prosumer | storage | consumer
  const nodes = [
    { x: 22, y: 30, t: 'prosumer' },
    { x: 50, y: 20, t: 'consumer' },
    { x: 76, y: 33, t: 'storage' },
    { x: 34, y: 58, t: 'consumer' },
    { x: 62, y: 55, t: 'prosumer', active: true },
    { x: 84, y: 66, t: 'consumer' },
    { x: 16, y: 74, t: 'storage' },
    { x: 47, y: 80, t: 'consumer' },
  ];
  const links = [[0, 1], [1, 2], [0, 3], [3, 4], [4, 2], [4, 5], [3, 6], [4, 7], [6, 7]];
  const color = { prosumer: '#E0A23C', storage: '#7CA8FF', consumer: D.violetSoft };
  const P = (i) => ({ cx: nodes[i].x, cy: nodes[i].y });

  return (
    <div style={{
      position: 'relative', height: 196, borderRadius: 20,
      overflow: 'hidden', border: `1px solid ${D.border}`, background: D.panel,
    }}>
      {/* faint street grid */}
      <div style={{
        position: 'absolute', inset: -20,
        backgroundImage: 'repeating-linear-gradient(58deg, rgba(255,255,255,0.05) 0 1px, transparent 1px 46px), repeating-linear-gradient(-32deg, rgba(255,255,255,0.04) 0 1px, transparent 1px 60px)',
      }} />
      {/* zone tint blobs */}
      <div style={{ position: 'absolute', top: '6%', left: '8%', width: 150, height: 150, borderRadius: '50%', background: 'radial-gradient(circle, rgba(155,107,255,0.16), transparent 70%)' }} />
      <div style={{ position: 'absolute', bottom: '-10%', right: '4%', width: 170, height: 170, borderRadius: '50%', background: 'radial-gradient(circle, rgba(124,58,237,0.18), transparent 70%)' }} />

      {/* links */}
      <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
        {links.map(([a, b], i) => {
          const hot = (a === 3 && b === 4) || (a === 4 && b === 2);
          return (
            <line key={i} x1={P(a).cx} y1={P(a).cy} x2={P(b).cx} y2={P(b).cy}
              stroke={hot ? D.violet : 'rgba(255,255,255,0.16)'}
              strokeWidth={hot ? 0.8 : 0.5}
              strokeDasharray={hot ? '2 2' : 'none'}
              className={hot ? 'gtx-flow' : ''}
              vectorEffect="non-scaling-stroke" />
          );
        })}
      </svg>

      {/* nodes */}
      {nodes.map((n, i) => (
        <div key={i} style={{ position: 'absolute', left: n.x + '%', top: n.y + '%', transform: 'translate(-50%,-50%)' }}>
          {n.active && <span className="gtx-pulse" style={{
            position: 'absolute', left: '50%', top: '50%', width: 10, height: 10,
            marginLeft: -5, marginTop: -5, borderRadius: '50%', border: `1.5px solid ${D.violet}`,
          }} />}
          <span style={{
            display: 'block', width: 9, height: 9, borderRadius: '50%',
            background: color[n.t], boxShadow: `0 0 8px ${color[n.t]}`,
          }} />
        </div>
      ))}

      {/* legend */}
      <div style={{
        position: 'absolute', left: 12, top: 12, display: 'flex', flexDirection: 'column', gap: 5,
        padding: '8px 10px', borderRadius: 12, background: 'rgba(11,7,18,0.7)',
        backdropFilter: 'blur(8px)', border: `1px solid ${D.border}`,
      }}>
        {[['prosumer', 'Prosumer'], ['storage', 'Storage'], ['consumer', 'Consumer']].map(([k, l]) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 10.5, color: D.muted }}>
            <span style={{ width: 7, height: 7, borderRadius: '50%', background: color[k] }} />{l}
          </div>
        ))}
      </div>

      {/* active-trading chip */}
      <div style={{
        position: 'absolute', right: 12, top: 12, display: 'flex', alignItems: 'center', gap: 6,
        padding: '6px 10px', borderRadius: 999, background: 'rgba(155,107,255,0.16)',
        border: `1px solid rgba(155,107,255,0.4)`, fontSize: 11, fontWeight: 600, color: D.violetSoft,
      }}>
        <span className="gtx-blink" style={{ width: 6, height: 6, borderRadius: '50%', background: D.violet }} />
        4 zones live
      </div>
    </div>
  );
}

// ── small ui atoms ───────────────────────────────────────────
function Stat({ k, v, sub, accent }) {
  return (
    <div style={{ flex: 1, padding: '12px 13px', borderRadius: 14, background: D.surface, border: `1px solid ${D.border}` }}>
      <div style={{ fontSize: 10.5, color: D.muted, letterSpacing: 0.3, textTransform: 'uppercase' }}>{k}</div>
      <div style={{ fontSize: 19, fontWeight: 700, marginTop: 4, color: accent || D.text, fontFamily: D.mono }}>{v}</div>
      {sub && <div style={{ fontSize: 11, color: D.faint, marginTop: 2 }}>{sub}</div>}
    </div>
  );
}

// ── TRADE tab (minimal) ──────────────────────────────────────
function TradeTab({ side, setSide, preset, setPreset, orderType, setOrderType }) {
  const amount = preset ? (MAX_KWH * preset / 100) : 0;
  const total = amount * PRICE;
  const sides = [['buy', 'Buy', D.buy], ['sell', 'Sell', D.sell], ['dca', 'DCA', D.violet]];
  const Row = ({ label, children }) => (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '15px 0', borderTop: `1px solid ${D.border}` }}>
      <span style={{ fontSize: 14, color: D.muted }}>{label}</span>
      {children}
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      {/* side segment — bare */}
      <div style={{ display: 'flex', gap: 8 }}>
        {sides.map(([k, l, c]) => {
          const on = side === k;
          return (
            <button key={k} onClick={() => setSide(k)} style={{
              flex: 1, height: 42, border: 'none', borderRadius: 12, cursor: 'pointer',
              fontFamily: D.font, fontSize: 15, fontWeight: on ? 700 : 600,
              background: on ? `${c}22` : 'transparent', color: on ? c : D.faint,
              boxShadow: on ? `inset 0 0 0 1.5px ${c}` : `inset 0 0 0 1px ${D.border}`,
              transition: 'all .15s',
            }}>{l}</button>
          );
        })}
      </div>

      {/* amount — bare big number */}
      <div style={{ textAlign: 'center', padding: '30px 0 16px' }}>
        <div style={{ fontSize: 12.5, color: D.muted, marginBottom: 8 }}>Amount</div>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 8 }}>
          <span style={{ fontSize: 46, fontWeight: 800, fontFamily: D.mono, letterSpacing: -1, color: amount ? D.text : D.faint }}>{amount.toFixed(2)}</span>
          <span style={{ fontSize: 16, color: D.muted, fontWeight: 600 }}>kWh</span>
        </div>
        <div style={{ fontSize: 12, color: D.faint, marginTop: 6 }}>≈ ฿{total.toFixed(2)} · avail {MAX_KWH} kWh</div>
      </div>

      {/* presets — bare */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 4 }}>
        {[['25%',25],['50%',50],['75%',75],['Max',100]].map(([l, p]) => {
          const on = preset === p;
          return (
            <button key={p} onClick={() => setPreset(on ? null : p)} style={{
              flex: 1, height: 38, borderRadius: 10, cursor: 'pointer', fontFamily: D.font,
              fontSize: 13.5, fontWeight: 650, transition: 'all .15s', border: 'none',
              background: on ? 'rgba(155,107,255,0.16)' : D.surface,
              color: on ? D.violetSoft : D.muted,
            }}>{l}</button>
          );
        })}
      </div>

      {/* detail rows — hairline list */}
      <div style={{ marginTop: 14 }}>
        <Row label="Order type">
          <div style={{ display: 'flex', gap: 16 }}>
            {['market', 'limit'].map(t => {
              const on = orderType === t;
              return (
                <button key={t} onClick={() => setOrderType(t)} style={{
                  background: 'none', border: 'none', padding: 0, cursor: 'pointer', textTransform: 'capitalize',
                  fontFamily: D.font, fontSize: 14.5, fontWeight: on ? 700 : 500, color: on ? D.text : D.faint,
                }}>{t}</button>
              );
            })}
          </div>
        </Row>
        <Row label="Price">
          <span style={{ fontSize: 14.5, fontWeight: 700, fontFamily: D.mono }}>฿{PRICE.toFixed(2)}<span style={{ color: D.faint, fontWeight: 500, fontSize: 12 }}> /kWh</span></span>
        </Row>
        <Row label="Route">
          <span style={{ fontSize: 14.5, fontWeight: 600 }}>Zone 2 <span style={{ color: D.faint }}>→</span> <span style={{ color: D.violetSoft }}>Auto</span></span>
        </Row>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 0 0', borderTop: `1px solid ${D.border}` }}>
          <span style={{ fontSize: 15, fontWeight: 600 }}>Total</span>
          <span style={{ fontSize: 22, fontWeight: 800, fontFamily: D.mono, color: D.violetSoft }}>฿{total.toFixed(2)}</span>
        </div>
      </div>
    </div>
  );
}

// ── MARKET tab ───────────────────────────────────────────────
function MarketTab() {
  const trades = [
    { route: 'Zone 2 → Zone 4', kwh: 3.20, price: 4.28, t: '12s', side: 'buy' },
    { route: 'Zone 1 → Zone 0', kwh: 1.05, price: 4.55, t: '48s', side: 'sell' },
    { route: 'Zone 3 → Zone 2', kwh: 5.40, price: 4.31, t: '2m', side: 'buy' },
    { route: 'Zone 4 → Zone 1', kwh: 0.80, price: 4.62, t: '4m', side: 'sell' },
    { route: 'Zone 0 → Zone 3', kwh: 2.15, price: 4.40, t: '6m', side: 'buy' },
    { route: 'Zone 2 → Zone 4', kwh: 4.00, price: 4.25, t: '9m', side: 'buy' },
  ];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <div style={{ display: 'flex', gap: 10 }}>
        <Stat k="VWAP (24h)" v="฿4.36" sub="+2.45%" accent={D.buy} />
        <Stat k="Volume" v="218 kWh" sub="142 trades" />
      </div>
      <div>
        <div style={{ fontSize: 13, fontWeight: 600, color: D.muted, margin: '2px 2px 4px' }}>P2P trade feed</div>
        <div style={{ borderRadius: 16, background: D.surface, border: `1px solid ${D.border}`, overflow: 'hidden' }}>
          {trades.map((tr, i) => {
            const c = tr.side === 'buy' ? D.buy : D.sell;
            return (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px',
                borderTop: i ? `1px solid ${D.border}` : 'none',
              }}>
                <span style={{ width: 7, height: 7, borderRadius: '50%', background: c, flexShrink: 0 }} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 14, fontWeight: 600 }}>{tr.route}</div>
                  <div style={{ fontSize: 12, color: D.faint, marginTop: 2 }}>{tr.kwh.toFixed(2)} kWh · {tr.t} ago</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontSize: 14, fontWeight: 700, fontFamily: D.mono, color: c }}>฿{tr.price.toFixed(2)}</div>
                  <div style={{ fontSize: 11, color: D.faint, textTransform: 'capitalize' }}>{tr.side}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ── GRID tab ─────────────────────────────────────────────────
function GridTab() {
  const Bar = ({ pct, c }) => (
    <div style={{ height: 6, borderRadius: 999, background: 'rgba(255,255,255,0.08)', overflow: 'hidden', marginTop: 10 }}>
      <div style={{ width: pct + '%', height: '100%', borderRadius: 999, background: c }} />
    </div>
  );
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <GridMap />
      <div style={{ display: 'flex', gap: 10 }}>
        <Stat k="Generation" v="142 kW" sub="from 6 prosumers" />
        <Stat k="Consumption" v="128 kW" sub="11 consumers" />
      </div>
      <div style={{ padding: '14px 16px', borderRadius: 16, background: D.surface, border: `1px solid ${D.border}` }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <span style={{ fontSize: 13, color: D.muted, textTransform: 'uppercase', letterSpacing: 0.3 }}>Load balance</span>
          <span style={{ fontSize: 18, fontWeight: 700, fontFamily: D.mono, color: D.buy }}>+14 kW</span>
        </div>
        <Bar pct={62} c={D.buy} />
        <div style={{ fontSize: 11.5, color: D.faint, marginTop: 8 }}>Grid is exporting surplus to neighbouring zones.</div>
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{ flex: 1, padding: '14px 16px', borderRadius: 16, background: D.surface, border: `1px solid ${D.border}` }}>
          <div style={{ fontSize: 11, color: D.muted, textTransform: 'uppercase', letterSpacing: 0.3 }}>Storage</div>
          <div style={{ fontSize: 22, fontWeight: 700, fontFamily: D.mono, marginTop: 4, color: D.violetSoft }}>64%</div>
          <Bar pct={64} c={D.violet} />
        </div>
        <div style={{ flex: 1, padding: '14px 16px', borderRadius: 16, background: D.surface, border: `1px solid ${D.border}` }}>
          <div style={{ fontSize: 11, color: D.muted, textTransform: 'uppercase', letterSpacing: 0.3 }}>CO₂ saved</div>
          <div style={{ fontSize: 22, fontWeight: 700, fontFamily: D.mono, marginTop: 4, color: D.buy }}>18.4 kg</div>
          <div style={{ fontSize: 11.5, color: D.faint, marginTop: 12 }}>today, this zone</div>
        </div>
      </div>
    </div>
  );
}

// ── Dashboard shell ──────────────────────────────────────────
function Dashboard() {
  const [tab, setTab] = React.useState('trade');
  const [side, setSide] = React.useState('buy');
  const [preset, setPreset] = React.useState(50);
  const [orderType, setOrderType] = React.useState('market');
  const [range, setRange] = React.useState('1D');

  const amount = preset ? (MAX_KWH * preset / 100) : 0;
  const total = amount * PRICE;
  const ctaColor = side === 'buy' ? D.buy : side === 'sell' ? D.sell : D.violet;
  const ctaLabel = side === 'dca'
    ? 'Set up DCA'
    : `${side === 'buy' ? 'Buy' : 'Sell'} ${amount.toFixed(2)} kWh · ฿${total.toFixed(2)}`;

  const data = SERIES[range];
  const up = data[data.length - 1] >= data[0];
  const chgPct = (((data[data.length - 1] - data[0]) / data[0]) * 100);
  const trendC = up ? D.buy : D.sell;

  const tabs = [['trade', 'Trade'], ['market', 'Market']];

  return (
    <div style={{ position: 'absolute', inset: 0, background: D.bg, fontFamily: D.font, color: D.text, display: 'flex', flexDirection: 'column' }}>
      {/* header ticker */}
      <div style={{ paddingTop: 56, flexShrink: 0 }}>
        <div style={{ padding: '0 16px 10px', display: 'flex', alignItems: 'center', gap: 11 }}>
          <div style={{ width: 38, height: 38, borderRadius: 11, background: D.grad, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 14px rgba(124,58,237,0.5)' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 4 }}>
              {[0,1,2,3].map(i => <div key={i} style={{ width: 5, height: 5, borderRadius: 1.5, background: i===0 ? '#fff' : 'rgba(255,255,255,0.6)' }} />)}
            </div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
              <span style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.3 }}>GRX/THB</span>
              <span style={{ fontSize: 10, fontWeight: 700, color: D.violetSoft, padding: '2px 6px', borderRadius: 6, background: 'rgba(155,107,255,0.16)', border: '1px solid rgba(155,107,255,0.3)' }}>PERP</span>
            </div>
            <div style={{ fontSize: 11.5, color: D.faint, marginTop: 1 }}>P2P energy · oracle price</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: 20, fontWeight: 800, fontFamily: D.mono }}>฿{PRICE.toFixed(2)}</div>
            <div style={{ fontSize: 12.5, fontWeight: 700, color: trendC }}>{up ? '↑' : '↓'} {Math.abs(chgPct).toFixed(2)}%</div>
          </div>
        </div>

        {/* price chart */}
        <div style={{ padding: '4px 8px 0' }}>
          <PriceChart data={data} color={trendC} h={132} />
        </div>

        {/* range chips + 24h stats */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '6px 16px 0', gap: 10 }}>
          <div style={{ display: 'flex', gap: 16 }}>
            {['1H','1D','1W','1M'].map(r => {
              const on = range === r;
              return (
                <button key={r} onClick={() => setRange(r)} style={{
                  background: 'none', border: 'none', padding: '2px 0', cursor: 'pointer',
                  fontFamily: D.font, fontSize: 12.5, fontWeight: on ? 700 : 500,
                  color: on ? D.text : D.faint, transition: 'color .15s',
                }}>{r}</button>
              );
            })}
          </div>
          <div style={{ display: 'flex', gap: 12, fontSize: 11, color: D.faint }}>
            <span>H <b style={{ color: D.muted, fontFamily: D.mono, fontWeight: 600 }}>{Math.max(...data).toFixed(2)}</b></span>
            <span>L <b style={{ color: D.muted, fontFamily: D.mono, fontWeight: 600 }}>{Math.min(...data).toFixed(2)}</b></span>
            <span>Vol <b style={{ color: D.muted, fontFamily: D.mono, fontWeight: 600 }}>218</b></span>
          </div>
        </div>
      </div>

      {/* underline tabs (pinned) */}
      <div style={{ flexShrink: 0, padding: '14px 16px 0', display: 'flex', gap: 24, borderBottom: `1px solid ${D.border}` }}>
        {tabs.map(([k, l]) => {
          const on = tab === k;
          return (
            <button key={k} onClick={() => setTab(k)} style={{
              background: 'none', border: 'none', padding: '0 0 11px', cursor: 'pointer', marginBottom: -1,
              fontFamily: D.font, fontSize: 15, fontWeight: on ? 700 : 500,
              color: on ? D.text : D.muted, borderBottom: `2px solid ${on ? D.violet : 'transparent'}`,
              transition: 'color .15s',
            }}>{l}</button>
          );
        })}
      </div>

      {/* scrollable content */}
      <div style={{ flex: 1, overflowY: 'auto', padding: tab === 'trade' ? '16px 16px 108px' : '16px 16px 48px' }}>
        {tab === 'trade' && <TradeTab side={side} setSide={setSide} preset={preset} setPreset={setPreset} orderType={orderType} setOrderType={setOrderType} />}
        {tab === 'market' && <MarketTab />}
      </div>

      {/* sticky CTA for trade */}
      {tab === 'trade' && (
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '12px 16px 30px', background: 'linear-gradient(transparent, rgba(11,7,18,0.92) 28%)' }}>
          <button style={{
            width: '100%', height: 56, border: 'none', borderRadius: 16, cursor: 'pointer',
            fontFamily: D.font, fontSize: 17, fontWeight: 700, color: side === 'dca' ? '#fff' : '#08110C',
            background: side === 'dca' ? D.grad : ctaColor, boxShadow: `0 10px 28px ${ctaColor}55`,
          }}>{ctaLabel}</button>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { Dashboard });
