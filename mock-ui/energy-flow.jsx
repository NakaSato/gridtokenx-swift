// GridTokenX — Energy Flow (Sankey). Ribbon width ∝ power (kW).
// Sources → your grid hub → uses. Exports EnergyFlowPage to window.

const EF = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  border: 'rgba(255,255,255,0.09)',
  hair: 'rgba(255,255,255,0.08)',
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

function EFIcon({ d, c = EF.violetSoft, s = 18, sw = 2 }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const EFP = { back: 'M15 6l-6 6 6 6', info: 'M12 16v-4M12 8h.01M12 3a9 9 0 100 18 9 9 0 000-18z' };

const DATASETS = {
  now: {
    sources: [
      { name: 'Solar', v: 6.2, c: '#FFD166' },
      { name: 'Wind', v: 2.8, c: '#2FD08A' },
      { name: 'Grid buy', v: 1.5, c: '#7CA8FF' },
    ],
    sinks: [
      { name: 'Home', v: 4.5, c: '#C9B4FF' },
      { name: 'EV', v: 2.0, c: '#E0A23C' },
      { name: 'Battery', v: 2.4, c: '#7CA8FF' },
      { name: 'Sold', v: 1.6, c: '#9B6BFF' },
    ],
  },
  today: {
    sources: [
      { name: 'Solar', v: 48, c: '#FFD166' },
      { name: 'Wind', v: 19, c: '#2FD08A' },
      { name: 'Grid buy', v: 9, c: '#7CA8FF' },
    ],
    sinks: [
      { name: 'Home', v: 34, c: '#C9B4FF' },
      { name: 'EV', v: 14, c: '#E0A23C' },
      { name: 'Battery', v: 12, c: '#7CA8FF' },
      { name: 'Sold', v: 16, c: '#9B6BFF' },
    ],
  },
};

function ribbon(x0, y0, x1, y1, h) {
  const mx = (x0 + x1) / 2;
  return `M${x0},${y0} C${mx},${y0} ${mx},${y1} ${x1},${y1} L${x1},${y1 + h} C${mx},${y1 + h} ${mx},${y0 + h} ${x0},${y0 + h} Z`;
}

function Sankey({ sources, sinks, unit, hubLabel = 'YOU' }) {
  const total = sources.reduce((a, s) => a + s.v, 0);
  const W = 372, TOP = 16, H = 326, GAP = 6;
  const leftBarX = 92, barW = 11, hubX = 180, hubW = 13, rightBarX = 268;
  const leftRibX0 = leftBarX + barW, hubLeft = hubX, hubRight = hubX + hubW, rightRibX1 = rightBarX;

  const sScale = (H - (sources.length - 1) * GAP) / total;
  const kScale = (H - (sinks.length - 1) * GAP) / total;

  let yy = TOP;
  const sNodes = sources.map(s => { const h = s.v * sScale; const o = { ...s, y: yy, h }; yy += h + GAP; return o; });
  yy = TOP;
  const kNodes = sinks.map(s => { const h = s.v * kScale; const o = { ...s, y: yy, h }; yy += h + GAP; return o; });

  // hub stacks (no gaps)
  let hl = TOP; const sHub = sNodes.map(n => { const o = hl; hl += n.h; return o; });
  let hr = TOP; const kHub = kNodes.map(n => { const o = hr; hr += n.h; return o; });
  const hubTop = TOP, hubBot = Math.max(hl, hr);

  const label = (n, x, anchor) => (
    <g key={'l' + x + n.name}>
      <text x={x} y={n.y + n.h / 2 - 2} textAnchor={anchor} fill={EF.text} fontFamily={EF.font} fontSize="12.5" fontWeight="650">{n.name}</text>
      <text x={x} y={n.y + n.h / 2 + 12} textAnchor={anchor} fill={EF.muted} fontFamily={EF.mono} fontSize="11">{n.v}{unit === 'kWh' ? '' : ''}</text>
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${hubBot + 16}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
      {/* left ribbons */}
      {sNodes.map((n, i) => (
        <path key={'lr' + i} d={ribbon(leftRibX0, n.y, hubLeft, sHub[i], n.h)} fill={n.c} opacity="0.4" />
      ))}
      {/* right ribbons */}
      {kNodes.map((n, i) => (
        <path key={'rr' + i} d={ribbon(hubRight, kHub[i], rightRibX1, n.y, n.h)} fill={n.c} opacity="0.4" />
      ))}

      {/* hub bar */}
      <rect x={hubX} y={hubTop} width={hubW} height={hubBot - hubTop} rx="3" fill="url(#efhub)" />
      <defs>
        <linearGradient id="efhub" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#A974FF" /><stop offset="100%" stopColor="#7C3AED" />
        </linearGradient>
      </defs>

      {/* left nodes + labels */}
      {sNodes.map((n, i) => (
        <g key={'sn' + i}>
          <rect x={leftBarX} y={n.y} width={barW} height={n.h} rx="3" fill={n.c} />
          {label(n, leftBarX - 8, 'end')}
        </g>
      ))}
      {/* right nodes + labels */}
      {kNodes.map((n, i) => (
        <g key={'kn' + i}>
          <rect x={rightBarX} y={n.y} width={barW} height={n.h} rx="3" fill={n.c} />
          {label(n, rightBarX + barW + 8, 'start')}
        </g>
      ))}

      {/* hub caption */}
      <text x={hubX + hubW / 2} y={hubTop - 5} textAnchor="middle" fill={EF.violetSoft} fontFamily={EF.font} fontSize="10.5" fontWeight="700" letterSpacing="0.5">{hubLabel}</text>
    </svg>
  );
}

function EnergyFlowPage() {
  const [period, setPeriod] = React.useState('now');
  const d = DATASETS[period];
  const unit = period === 'now' ? 'kW' : 'kWh';
  const produced = d.sources.reduce((a, s) => a + s.v, 0);
  const sold = d.sinks.find(s => s.name === 'Sold').v;
  const used = d.sinks.filter(s => s.name !== 'Sold').reduce((a, s) => a + s.v, 0);
  const gridBuy = d.sources.find(s => s.name === 'Grid buy').v;
  const selfSufficient = Math.round(((produced - gridBuy) / produced) * 100);

  return (
    <div style={{ position: 'absolute', inset: 0, background: EF.bg, fontFamily: EF.font, color: EF.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <EFIcon d={EFP.back} c={EF.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Energy flow</span>
        <EFIcon d={EFP.info} c={EF.faint} s={19} sw={1.8} />
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '6px 16px 32px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* period toggle */}
        <div style={{ display: 'flex', gap: 6, padding: 5, background: EF.surface, borderRadius: 13, border: `1px solid ${EF.border}`, alignSelf: 'flex-start' }}>
          {[['now', 'Now'], ['today', 'Today']].map(([k, l]) => {
            const on = period === k;
            return (
              <button key={k} onClick={() => setPeriod(k)} style={{
                height: 32, padding: '0 18px', border: 'none', borderRadius: 9, cursor: 'pointer',
                fontFamily: EF.font, fontSize: 13.5, fontWeight: 650, transition: 'all .15s',
                background: on ? EF.grad : 'transparent', color: on ? '#fff' : EF.muted,
              }}>{l}</button>
            );
          })}
        </div>

        {/* headline figure */}
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
          <span style={{ fontSize: 38, fontWeight: 800, fontFamily: EF.mono, letterSpacing: -1 }}>{produced}<span style={{ fontSize: 18, color: EF.muted, fontWeight: 600 }}> {unit}</span></span>
          <span style={{ fontSize: 13.5, color: EF.muted }}>{period === 'now' ? 'flowing now' : 'today'}</span>
        </div>

        {/* sankey */}
        <div style={{ borderRadius: 20, background: EF.surface, border: `1px solid ${EF.border}`, padding: '16px 10px 12px' }}>
          <Sankey sources={d.sources} sinks={d.sinks} unit={unit} />
        </div>

        {/* summary stats */}
        <div style={{ display: 'flex', gap: 10 }}>
          {[['Self-powered', selfSufficient + '%', EF.up], ['Using', used + ' ' + unit, EF.violetSoft], ['Exporting', sold + ' ' + unit, EF.violet]].map(([l, v, c]) => (
            <div key={l} style={{ flex: 1, padding: '12px 12px', borderRadius: 14, background: EF.surface, border: `1px solid ${EF.border}` }}>
              <div style={{ fontSize: 10.5, color: EF.muted, textTransform: 'uppercase', letterSpacing: 0.3 }}>{l}</div>
              <div style={{ fontSize: 17, fontWeight: 750, fontFamily: EF.mono, marginTop: 4, color: c }}>{v}</div>
            </div>
          ))}
        </div>

        {/* note */}
        <div style={{ display: 'flex', gap: 9, padding: '13px 15px', borderRadius: 14, background: 'rgba(155,107,255,0.08)', border: '1px solid rgba(155,107,255,0.2)' }}>
          <EFIcon d={EFP.info} c={EF.violetSoft} s={16} sw={1.8} />
          <span style={{ fontSize: 12.5, color: EF.muted, lineHeight: 1.45 }}>
            Ribbon thickness shows how much power flows along each path. You sold <b style={{ color: EF.text }}>{sold} {unit}</b> of surplus {period === 'now' ? 'right now' : 'today'}.
          </span>
        </div>
      </div>
    </div>
  );
}

// ── My home energy flow ──────────────────────────────────────
const HOME = {
  sources: [
    { name: 'Solar', v: 6.2, c: '#FFD166' },
    { name: 'Battery', v: 1.8, c: '#7CA8FF' },
    { name: 'Grid buy', v: 0.9, c: '#FF9A5C' },
  ],
  sinks: [
    { name: 'Air-con', v: 2.6, c: '#7CA8FF' },
    { name: 'EV charger', v: 2.0, c: '#E0A23C' },
    { name: 'Kitchen', v: 1.0, c: '#C9B4FF' },
    { name: 'Water heat', v: 0.8, c: '#FF6B9D' },
    { name: 'Lights+plug', v: 0.9, c: '#9B6BFF' },
    { name: 'Sold', v: 1.6, c: '#2FD08A' },
  ],
};

function MyHomeFlow() {
  const d = HOME;
  const unit = 'kW';
  const supply = d.sources.reduce((a, s) => a + s.v, 0);
  const sold = d.sinks.find(s => s.name === 'Sold').v;
  const homeUse = d.sinks.filter(s => s.name !== 'Sold').reduce((a, s) => a + s.v, 0);
  const gridBuy = d.sources.find(s => s.name === 'Grid buy').v;
  const selfSufficient = Math.round(((supply - gridBuy) / supply) * 100);

  return (
    <div style={{ position: 'absolute', inset: 0, background: EF.bg, fontFamily: EF.font, color: EF.text, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <EFIcon d={EFP.back} c={EF.muted} s={22} sw={2} />
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 21, fontWeight: 700, letterSpacing: -0.4 }}>My home</div>
          <div style={{ fontSize: 12, color: EF.faint, marginTop: 1 }}>Zone 2 · Bangkok · live</div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '5px 10px', borderRadius: 999, background: 'rgba(47,208,138,0.12)', border: '1px solid rgba(47,208,138,0.3)', fontSize: 11.5, fontWeight: 700, color: EF.up }}>
          <span className="gtx-blink" style={{ width: 6, height: 6, borderRadius: '50%', background: EF.up }} />LIVE
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '6px 16px 32px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ borderRadius: 20, padding: '18px 18px', background: EF.grad, boxShadow: '0 14px 40px rgba(124,58,237,0.4)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -30, right: -20, width: 130, height: 130, borderRadius: '50%', background: 'rgba(255,255,255,0.1)' }} />
          <div style={{ position: 'relative' }}>
            <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>Powered by your own clean energy</div>
            <div style={{ fontSize: 40, fontWeight: 850, fontFamily: EF.mono, letterSpacing: -1, marginTop: 2 }}>{selfSufficient}%</div>
            <div style={{ display: 'flex', gap: 18, marginTop: 8 }}>
              <div><div style={{ fontSize: 15, fontWeight: 750, fontFamily: EF.mono }}>{supply.toFixed(1)} kW</div><div style={{ fontSize: 11, color: 'rgba(255,255,255,0.75)' }}>supply</div></div>
              <div><div style={{ fontSize: 15, fontWeight: 750, fontFamily: EF.mono }}>{homeUse.toFixed(1)} kW</div><div style={{ fontSize: 11, color: 'rgba(255,255,255,0.75)' }}>home use</div></div>
              <div><div style={{ fontSize: 15, fontWeight: 750, fontFamily: EF.mono }}>{sold.toFixed(1)} kW</div><div style={{ fontSize: 11, color: 'rgba(255,255,255,0.75)' }}>exported</div></div>
            </div>
          </div>
        </div>

        <div style={{ borderRadius: 20, background: EF.surface, border: `1px solid ${EF.border}`, padding: '16px 10px 12px' }}>
          <div style={{ fontSize: 12.5, color: EF.muted, fontWeight: 600, textAlign: 'center', marginBottom: 4 }}>Where your power comes from & goes</div>
          <Sankey sources={d.sources} sinks={d.sinks} unit={unit} hubLabel="HOME" />
        </div>

        <div style={{ display: 'flex', gap: 9, padding: '13px 15px', borderRadius: 14, background: 'rgba(155,107,255,0.08)', border: '1px solid rgba(155,107,255,0.2)' }}>
          <EFIcon d={EFP.info} c={EF.violetSoft} s={16} sw={1.8} />
          <span style={{ fontSize: 12.5, color: EF.muted, lineHeight: 1.45 }}>
            Ribbon thickness = power along each path. Your <b style={{ color: EF.text }}>Air-con</b> is the biggest load right now; surplus <b style={{ color: EF.text }}>{sold} kW</b> is being sold to neighbours.
          </span>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { EnergyFlowPage, MyHomeFlow });
