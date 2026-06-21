// GridTokenX — DCA (recurring order) strategy setup.
// Dark + purple; green/red reserved for Buy/Sell. Exports DCAStrategy to window.

const DC = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  field: 'rgba(255,255,255,0.04)',
  border: 'rgba(255,255,255,0.09)',
  text: '#F4F1FA',
  muted: 'rgba(244,241,250,0.54)',
  faint: 'rgba(244,241,250,0.34)',
  violet: '#9B6BFF',
  violetSoft: '#C9B4FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  buy: '#2FD08A',
  sell: '#FF5C6C',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function DCIcon({ d, c = DC.violetSoft, s = 18, sw = 2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const DCP = {
  back: 'M15 6l-6 6 6 6',
  dca: 'M7 10l-3 3 3 3M4 13h12M17 14l3-3-3-3M20 11H8',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zM12 7v5l3 2',
  sun: 'M12 5V3M12 21v-2M5 12H3M21 12h-2M6 6L4.6 4.6M19.4 4.6L18 6M6 18l-1.4 1.4M19.4 19.4L18 18M12 8a4 4 0 100 8 4 4 0 000-8z',
  cal: 'M4 6h16v15H4zM4 10h16M8 3v4M16 3v4',
  hash: 'M9 4L7 20M17 4l-2 16M4 9h16M3 15h16',
  inf: 'M7 9a3 3 0 110 6c-2 0-3-3-5-3M17 9a3 3 0 100 6c2 0 3-3 5-3',
  spark: 'M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3z',
  arrowUp: 'M12 19V5M5 12l7-7 7 7',
};

function Seg({ side, setSide }) {
  const opts = [['buy', 'Buy', DC.buy], ['sell', 'Sell', DC.sell]];
  return (
    <div style={{ display: 'flex', gap: 6, padding: 5, background: DC.surface, borderRadius: 14, border: `1px solid ${DC.border}` }}>
      {opts.map(([k, l, c]) => {
        const on = side === k;
        return (
          <button key={k} onClick={() => setSide(k)} style={{
            flex: 1, height: 44, border: 'none', borderRadius: 10, cursor: 'pointer',
            fontFamily: DC.font, fontSize: 16, fontWeight: 700,
            background: on ? c : 'transparent', color: on ? '#08110C' : DC.muted,
            boxShadow: on ? `0 4px 14px ${c}55` : 'none', transition: 'all .15s',
          }}>{l}</button>
        );
      })}
    </div>
  );
}

function Label({ children, hint }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
      <span style={{ fontSize: 14, fontWeight: 650 }}>{children}</span>
      {hint && <span style={{ fontSize: 12.5, color: DC.faint }}>{hint}</span>}
    </div>
  );
}

function FieldBox({ value, placeholder, unit, mono = true, focus }) {
  const empty = !value;
  return (
    <div style={{ height: 54, borderRadius: 13, background: DC.field, border: `1px solid ${focus ? DC.violet : DC.border}`, boxShadow: focus ? '0 0 0 4px rgba(155,107,255,0.14)' : 'none', display: 'flex', alignItems: 'center', padding: '0 15px', gap: 10 }}>
      <span style={{ flex: 1, fontSize: mono ? 18 : 16, fontWeight: mono ? 700 : 500, fontFamily: mono ? DC.mono : DC.font, color: empty ? DC.faint : DC.text }}>{value || placeholder}</span>
      {unit && <span style={{ fontSize: 13.5, color: DC.muted, fontWeight: 600 }}>{unit}</span>}
    </div>
  );
}

function DCAStrategy() {
  const [started, setStarted] = React.useState(false);
  const [side, setSide] = React.useState('buy');
  const [freq, setFreq] = React.useState('daily');
  const [amount, setAmount] = React.useState('3.0');
  const [maxPrice, setMaxPrice] = React.useState('');
  const [everyN, setEveryN] = React.useState('1');

  // AI assist state
  const [aiPrompt, setAiPrompt] = React.useState('');
  const [aiLoading, setAiLoading] = React.useState(false);
  const [aiNote, setAiNote] = React.useState('');
  const [aiErr, setAiErr] = React.useState('');

  async function runAI(text) {
    const goal = (text != null ? text : aiPrompt).trim();
    if (!goal || aiLoading) return;
    setAiLoading(true); setAiErr(''); setAiNote('');
    try {
      const prompt = `You are configuring a recurring (DCA) energy-trade order on a peer-to-peer solar marketplace in Thailand. Prices are in Thai Baht (THB) per kWh, typically 4.0–5.0. A household has ~12 kWh/day of tradeable solar.\n\nUser goal: "${goal}"\n\nReply with ONLY a JSON object, no prose, of this exact shape:\n{"side":"buy"|"sell","amount":number (kWh, 0.1-12),"frequency":"hourly"|"daily"|"weekly"|"monthly","everyN":integer>=1,"maxPrice":number|null (THB/kWh cap, null if none),"note":"one short sentence explaining the plan"}`;
      const raw = await window.claude.complete(prompt);
      const m = raw.match(/\{[\s\S]*\}/);
      const cfg = JSON.parse(m ? m[0] : raw);
      if (cfg.side === 'buy' || cfg.side === 'sell') setSide(cfg.side);
      if (['hourly','daily','weekly','monthly'].includes(cfg.frequency)) setFreq(cfg.frequency);
      if (cfg.amount != null) setAmount(Number(cfg.amount).toFixed(1));
      if (cfg.everyN != null) setEveryN(String(Math.max(1, parseInt(cfg.everyN, 10) || 1)));
      setMaxPrice(cfg.maxPrice != null ? Number(cfg.maxPrice).toFixed(2) : '');
      setAiNote(cfg.note || 'Strategy configured.');
    } catch (e) {
      setAiErr('Couldn\u2019t generate a plan. Try rephrasing your goal.');
    } finally {
      setAiLoading(false);
    }
  }

  const freqs = [['hourly', 'Hourly', DCP.clock], ['daily', 'Daily', DCP.sun], ['weekly', 'Weekly', DCP.cal], ['monthly', 'Monthly', DCP.cal]];
  const unit = { hourly: 'hours', daily: 'days', weekly: 'weeks', monthly: 'months' }[freq];
  const sideC = side === 'buy' ? DC.buy : DC.sell;

  if (started) {
    return <DCAActive side={side} amount={amount} freq={freq} unit={unit} everyN={everyN} maxPrice={maxPrice} onBack={() => setStarted(false)} />;
  }

  return (
    <div style={{ position: 'absolute', inset: 0, background: DC.bg, fontFamily: DC.font, color: DC.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: DC.surface, border: `1px solid ${DC.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <DCIcon d={DCP.back} s={18} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4, display: 'flex', alignItems: 'center', gap: 8 }}>
            <DCIcon d={DCP.dca} s={20} /> DCA strategy
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          <p style={{ margin: '2px 0 0', flex: 1, fontSize: 14, color: DC.muted, lineHeight: 1.45 }}>Automatically {side} energy on a schedule to average out price swings.</p>
          <button onClick={() => runAI('Suggest a smart DCA strategy for my solar household')} disabled={aiLoading} style={{
            flexShrink: 0, display: 'flex', alignItems: 'center', gap: 6, height: 34, padding: '0 13px', borderRadius: 999,
            border: '1px solid rgba(155,107,255,0.4)', background: 'rgba(155,107,255,0.14)', cursor: aiLoading ? 'default' : 'pointer',
            color: DC.violetSoft, fontFamily: DC.font, fontSize: 13, fontWeight: 700,
          }}>
            {aiLoading
              ? <span className="gtx-spin" style={{ width: 14, height: 14, borderRadius: '50%', border: '2px solid rgba(201,180,255,0.4)', borderTopColor: DC.violetSoft, display: 'block' }} />
              : <DCIcon d={DCP.spark} c={DC.violetSoft} s={14} sw={1.8} />}
            {aiLoading ? 'Thinking…' : 'Suggest with AI'}
          </button>
        </div>

        <div>
          <Label hint="Min: 0.1 kWh">Amount per execution</Label>
          <FieldBox value={amount} unit="kWh" focus />
        </div>

        <div>
          <Label hint="Skip if price exceeds">Max price <span style={{ color: DC.faint, fontWeight: 400 }}>(optional)</span></Label>
          <FieldBox value={maxPrice} placeholder="No limit" unit="฿/kWh" />
        </div>

        <div>
          <Label>Frequency</Label>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: 8 }}>
            {freqs.map(([k, l, icon]) => {
              const on = freq === k;
              return (
                <button key={k} onClick={() => setFreq(k)} style={{
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7, padding: '12px 4px',
                  borderRadius: 14, cursor: 'pointer', fontFamily: DC.font, transition: 'all .15s',
                  background: on ? 'rgba(155,107,255,0.14)' : DC.surface,
                  border: `1.5px solid ${on ? DC.violet : DC.border}`,
                }}>
                  <div style={{ width: 34, height: 34, borderRadius: 10, background: on ? DC.grad : 'rgba(255,255,255,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <DCIcon d={icon} c="#fff" s={18} />
                  </div>
                  <span style={{ fontSize: 12, fontWeight: 650, color: on ? DC.text : DC.muted }}>{l}</span>
                </button>
              );
            })}
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12 }}>
          <div style={{ flex: 1 }}>
            <Label>Every N {unit}</Label>
            <FieldBox value={everyN} />
          </div>
          <div style={{ flex: 1 }}>
            <Label hint="∞ if empty">Max runs</Label>
            <FieldBox placeholder="∞" />
          </div>
        </div>

        {/* preview */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '14px 16px', borderRadius: 16, background: DC.surface, border: `1px solid ${DC.border}` }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', background: sideC, flexShrink: 0 }} />
          <span style={{ fontSize: 13.5, color: DC.muted, lineHeight: 1.4 }}>
            {side === 'buy' ? 'Buys' : 'Sells'} <b style={{ color: DC.text }}>{amount} kWh</b> every <b style={{ color: DC.text }}>{unit.replace(/s$/, '')}</b> · runs until cancelled
          </span>
        </div>
      </div>

      {/* CTA */}
      <div style={{ flexShrink: 0, padding: '12px 16px 30px', borderTop: `1px solid ${DC.border}`, background: DC.bg, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Seg side={side} setSide={setSide} />
        <button onClick={() => setStarted(true)} style={{
          width: '100%', height: 56, border: 'none', borderRadius: 16, cursor: 'pointer',
          fontFamily: DC.font, fontSize: 17, fontWeight: 700, color: side === 'buy' ? '#08110C' : '#fff',
          background: sideC, boxShadow: `0 10px 26px ${sideC}55`,
        }}>Start DCA · {amount} kWh / {unit.replace(/s$/, '')}</button>
      </div>
    </div>
  );
}

// ── DCA active / confirmation page (shown after Start DCA) ──
function DCAActive({ side = 'buy', amount = '3.0', freq = 'daily', unit = 'days', everyN = '1', maxPrice = '', onBack }) {
  const sideC = side === 'buy' ? DC.buy : DC.sell;
  const sideLabel = side === 'buy' ? 'Buy' : 'Sell';
  const cadence = { hourly: 'Hourly', daily: 'Daily', weekly: 'Weekly', monthly: 'Monthly' }[freq] || 'Daily';
  const nextRun = { hourly: 'In 1 hour', daily: 'Tomorrow, 06:00', weekly: 'Mon, 06:00', monthly: '1st of month' }[freq] || 'Tomorrow';
  const rows = [
    ['Action', `${sideLabel} energy`, sideC],
    ['Amount', `${amount} kWh`, DC.text],
    ['Frequency', `${cadence}${Number(everyN) > 1 ? ` · every ${everyN} ${unit}` : ''}`, DC.text],
    ['Price cap', maxPrice ? `฿${maxPrice}/kWh` : 'No limit', DC.text],
    ['Next run', nextRun, DC.violetSoft],
  ];
  return (
    <div style={{ position: 'absolute', inset: 0, background: DC.bg, fontFamily: DC.font, color: DC.text, display: 'flex', flexDirection: 'column' }}>
      {/* glow */}
      <div style={{ position: 'absolute', top: -120, left: '50%', transform: 'translateX(-50%)', width: 420, height: 360, borderRadius: '50%', background: 'radial-gradient(circle, rgba(124,58,237,0.34) 0%, transparent 66%)', pointerEvents: 'none' }} />

      <div style={{ position: 'relative', flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 24px', textAlign: 'center' }}>
        <div style={{ width: 92, height: 92, borderRadius: 28, background: DC.grad, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 16px 48px rgba(124,58,237,0.5)' }}>
          <DCIcon d="M5 13l4 4L19 7" c="#fff" s={44} sw={3} />
        </div>
        <h1 style={{ margin: '28px 0 0', fontSize: 27, fontWeight: 750, letterSpacing: -0.6 }}>DCA strategy active</h1>
        <p style={{ margin: '12px 0 0', fontSize: 15, color: DC.muted, lineHeight: 1.5, maxWidth: 290 }}>
          Your recurring order is live. We’ll {side} <b style={{ color: DC.text }}>{amount} kWh</b> automatically and notify you on every fill.
        </p>

        {/* summary card */}
        <div style={{ width: '100%', marginTop: 26, borderRadius: 18, background: DC.surface, border: `1px solid ${DC.border}`, overflow: 'hidden' }}>
          {rows.map(([l, v, c], i) => (
            <div key={l} style={{ display: 'flex', alignItems: 'center', padding: '14px 16px', borderTop: i ? `1px solid ${DC.border}` : 'none' }}>
              <span style={{ flex: 1, textAlign: 'left', fontSize: 14, color: DC.muted }}>{l}</span>
              <span style={{ fontSize: 14.5, fontWeight: 700, color: c, fontFamily: /[0-9฿]/.test(v) ? DC.mono : DC.font }}>{v}</span>
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 16, fontSize: 12.5, color: DC.faint }}>
          <span className="gtx-blink" style={{ width: 7, height: 7, borderRadius: '50%', background: sideC }} />
          Running until cancelled
        </div>
      </div>

      {/* CTAs */}
      <div style={{ flexShrink: 0, padding: '12px 16px 30px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button style={{ width: '100%', height: 54, border: 'none', borderRadius: 16, cursor: 'pointer', fontFamily: DC.font, fontSize: 16.5, fontWeight: 700, color: '#fff', background: DC.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)' }}>View in orders</button>
        <button onClick={onBack} style={{ width: '100%', height: 50, borderRadius: 14, cursor: 'pointer', fontFamily: DC.font, fontSize: 15.5, fontWeight: 600, color: DC.muted, background: 'transparent', border: `1px solid ${DC.border}` }}>Edit strategy</button>
      </div>
    </div>
  );
}

Object.assign(window, { DCAStrategy, DCAActive });
