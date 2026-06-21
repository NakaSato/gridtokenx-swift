// GridTokenX — Deposit & Withdraw pages (shared numeric keypad).
// Dark + purple system; green/red reserved for positive/destructive.
// Exports DepositPage, WithdrawPage to window.

const T = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.05)',
  surface2: 'rgba(255,255,255,0.08)',
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
  mono: '"SF Mono", ui-monospace, monospace',
};

function TIcon({ d, c = T.violetSoft, s = 18, sw = 2 }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const TP = {
  back: 'M15 6l-6 6 6 6',
  qr: 'M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h2v2h-2zM18 14h2v2h-2zM14 18h2v2h-2zM18 18h2v2h-2z',
  bank: 'M4 9h16M5 9l7-5 7 5M6 9v8M10 9v8M14 9v8M18 9v8M4 20h16',
  card: 'M3 7h18v10H3zM3 10h18',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  check: 'M5 12l5 5 9-10',
  plus: 'M12 5v14M5 12h14',
  copy: 'M9 9h10v10H9zM5 15V5h10',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zM12 7v5l3 2',
  lock: 'M6 11V8a6 6 0 0112 0v3M5 11h14v9H5z',
  shield: 'M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z',
};

// faux QR (deterministic) on white tile
function FakeQR({ size = 176 }) {
  const N = 23, cells = [];
  const finder = (r, c) => (r < 7 && c < 7) || (r < 7 && c >= N - 7) || (r >= N - 7 && c < 7);
  for (let r = 0; r < N; r++) for (let c = 0; c < N; c++) {
    let on;
    if (finder(r, c)) {
      const lr = r < 7 ? r : r - (N - 7), lc = c < 7 ? c : c - (N - 7);
      on = lr === 0 || lr === 6 || lc === 0 || lc === 6 || (lr >= 2 && lr <= 4 && lc >= 2 && lc <= 4);
    } else {
      on = ((r * 7 + c * 13 + (r ^ c) * 5) % 3 === 0);
    }
    if (on) cells.push([r, c]);
  }
  const cell = size / N;
  return (
    <div style={{ width: size + 24, height: size + 24, borderRadius: 16, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto' }}>
      <svg width={size} height={size} viewBox={`0 0 ${N} ${N}`}>
        {cells.map(([r, c], i) => <rect key={i} x={c} y={r} width={1.02} height={1.02} fill="#0B0712" />)}
      </svg>
    </div>
  );
}

function CopyRow({ label, value, mono = true }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', padding: '13px 16px' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 11.5, color: T.faint, textTransform: 'uppercase', letterSpacing: 0.4, marginBottom: 3 }}>{label}</div>
        <div style={{ fontSize: 15.5, fontWeight: 650, fontFamily: mono ? T.mono : T.font, letterSpacing: mono ? 0.5 : 0 }}>{value}</div>
      </div>
      <button style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '6px 10px', borderRadius: 9, border: `1px solid ${T.border}`, background: T.surface, cursor: 'pointer', color: T.violetSoft, fontFamily: T.font, fontSize: 12.5, fontWeight: 600 }}>
        <TIcon d={TP.copy} c={T.violetSoft} s={14} sw={1.8} /> Copy
      </button>
    </div>
  );
}

function ConfirmBtn({ children, onClick }) {
  return (
    <button onClick={onClick} style={{ width: '100%', height: 56, border: 'none', borderRadius: 16, cursor: 'pointer', fontFamily: T.font, fontSize: 17, fontWeight: 700, color: '#fff', background: T.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)' }}>{children}</button>
  );
}

function MethodTopBar({ title, onBack }) {
  return (
    <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 8px', display: 'flex', alignItems: 'center', gap: 12 }}>
      <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 11, background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
        <TIcon d={TP.back} s={18} />
      </button>
      <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>{title}</span>
    </div>
  );
}

// ── Deposit · PromptPay (QR) ──
function DepositPromptPay({ amount = '500', onBack }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      <MethodTopBar title="PromptPay" onBack={onBack} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 13.5, color: T.muted }}>Scan to add</div>
          <div style={{ fontSize: 34, fontWeight: 800, fontFamily: T.mono, letterSpacing: -1, marginTop: 2 }}>฿{group(amount)}</div>
        </div>
        <FakeQR />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, fontSize: 13, color: T.muted }}>
          <TIcon d={TP.clock} c={T.faint} s={15} sw={1.8} /> Expires in <b style={{ color: T.text, fontFamily: T.mono }}>04:58</b>
        </div>
        <div style={{ borderRadius: 16, background: T.surface, border: `1px solid ${T.border}`, overflow: 'hidden' }}>
          <CopyRow label="PromptPay ID" value="0812345678" />
          <div style={{ height: 1, background: T.border, marginLeft: 16 }} />
          <CopyRow label="Reference" value="GTX-DEP-8842" />
        </div>
        <p style={{ margin: 0, fontSize: 12.5, color: T.faint, textAlign: 'center', lineHeight: 1.5 }}>Open any Thai banking app, scan the QR or enter the PromptPay ID. Funds arrive instantly.</p>
      </div>
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <ConfirmBtn>I’ve paid</ConfirmBtn>
      </div>
    </div>
  );
}

// ── Deposit · Bank transfer (account details) ──
function DepositBank({ amount = '500', onBack }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      <MethodTopBar title="Bank transfer" onBack={onBack} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 13.5, color: T.muted }}>Transfer exactly</div>
          <div style={{ fontSize: 34, fontWeight: 800, fontFamily: T.mono, letterSpacing: -1, marginTop: 2 }}>฿{group(amount)}</div>
        </div>
        <div style={{ borderRadius: 18, background: T.surface, border: `1px solid ${T.border}`, overflow: 'hidden' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderBottom: `1px solid ${T.border}` }}>
            <div style={{ width: 38, height: 38, borderRadius: 11, background: T.grad, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TIcon d={TP.bank} c="#fff" s={19} /></div>
            <div><div style={{ fontSize: 15.5, fontWeight: 650 }}>Siam Commercial Bank</div><div style={{ fontSize: 12.5, color: T.muted, marginTop: 1 }}>GridTokenX (Thailand) Co.</div></div>
          </div>
          <CopyRow label="Account number" value="123-4-56789-0" />
          <div style={{ height: 1, background: T.border, marginLeft: 16 }} />
          <CopyRow label="Reference (required)" value="GTX-DEP-8842" />
        </div>
        <div style={{ display: 'flex', gap: 9, padding: '12px 14px', borderRadius: 13, background: 'rgba(255,209,102,0.1)', border: '1px solid rgba(255,209,102,0.28)' }}>
          <TIcon d={TP.shield} c="#FFD166" s={16} sw={1.8} />
          <span style={{ fontSize: 12.5, color: T.muted, lineHeight: 1.45 }}>Always include the <b style={{ color: T.text }}>reference</b> so we can match your transfer. Arrives in seconds for most Thai banks.</span>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <ConfirmBtn>I’ve transferred</ConfirmBtn>
      </div>
    </div>
  );
}

// ── Deposit · Debit card (form) ──
function DepositCard({ amount = '500', onBack }) {
  const fee = (toNum(amount) * 0.015);
  const total = toNum(amount) + fee;
  const CardField = ({ label, value, ph, flex }) => (
    <div style={{ flex: flex || 'auto' }}>
      <div style={{ fontSize: 12, fontWeight: 600, color: T.muted, marginBottom: 7 }}>{label}</div>
      <div style={{ height: 52, borderRadius: 13, background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', padding: '0 14px' }}>
        <span style={{ fontSize: 16, fontFamily: T.mono, letterSpacing: 1, color: value ? T.text : T.faint }}>{value || ph}</span>
      </div>
    </div>
  );
  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      <MethodTopBar title="Debit card" onBack={onBack} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* card preview */}
        {/* card preview — realistic */}
        <div style={{ borderRadius: 18, padding: '20px 20px 18px', background: 'linear-gradient(125deg, #7C3AED 0%, #A974FF 45%, #6D28D9 100%)', boxShadow: '0 16px 40px rgba(124,58,237,0.5)', position: 'relative', overflow: 'hidden', aspectRatio: '1.586', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          {/* glossy streaks */}
          <div style={{ position: 'absolute', top: -60, right: -40, width: 220, height: 220, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,255,255,0.22), transparent 65%)' }} />
          <div style={{ position: 'absolute', bottom: -80, left: -30, width: 200, height: 200, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,255,255,0.1), transparent 60%)' }} />
          <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(105deg, transparent 40%, rgba(255,255,255,0.12) 50%, transparent 60%)' }} />

          {/* top row: brand + contactless */}
          <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 14, fontWeight: 800, letterSpacing: 0.5, color: '#fff' }}>GridToken<span style={{ color: 'rgba(255,255,255,0.7)' }}>X</span></span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" style={{ opacity: 0.85 }}>
              <path d="M8 8a6 6 0 010 8M11.5 5a10 10 0 010 14M5 11a3 3 0 010 2" stroke="#fff" strokeWidth="1.6" strokeLinecap="round" />
            </svg>
          </div>

          {/* chip */}
          <div style={{ position: 'relative', width: 44, height: 33, borderRadius: 7, background: 'linear-gradient(135deg, #F5D98B, #C9A24B)', overflow: 'hidden', marginTop: 2 }}>
            <div style={{ position: 'absolute', inset: 0, background: 'repeating-linear-gradient(0deg, rgba(0,0,0,0.18) 0 1px, transparent 1px 7px), repeating-linear-gradient(90deg, rgba(0,0,0,0.18) 0 1px, transparent 1px 11px)' }} />
            <div style={{ position: 'absolute', top: 6, left: '50%', width: 1, height: 21, marginLeft: -0.5, background: 'rgba(0,0,0,0.22)' }} />
            <div style={{ position: 'absolute', left: 5, top: '50%', width: 34, height: 1, marginTop: -0.5, background: 'rgba(0,0,0,0.22)' }} />
          </div>

          {/* number */}
          <div style={{ position: 'relative', fontSize: 21, fontFamily: T.mono, letterSpacing: 2.5, fontWeight: 600, color: '#fff', textShadow: '0 1px 2px rgba(0,0,0,0.25)' }}>4242 •••• •••• 1234</div>

          {/* bottom row */}
          <div style={{ position: 'relative', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontSize: 8.5, letterSpacing: 1, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>CARD HOLDER</div>
              <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff', letterSpacing: 0.5, marginTop: 2 }}>MAYA CHEN</div>
            </div>
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: 8.5, letterSpacing: 1, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>EXPIRES</div>
              <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff', fontFamily: T.mono, marginTop: 2 }}>09/27</div>
            </div>
            {/* network mark — overlapping circles */}
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <div style={{ width: 26, height: 26, borderRadius: '50%', background: 'rgba(255,80,90,0.9)' }} />
              <div style={{ width: 26, height: 26, borderRadius: '50%', background: 'rgba(255,179,71,0.85)', marginLeft: -11 }} />
            </div>
          </div>
        </div>
        <CardField label="Card number" value="4242 4242 4242 1234" />
        <div style={{ display: 'flex', gap: 12 }}>
          <CardField label="Expiry" value="09 / 27" flex={1} />
          <CardField label="CVC" ph="123" flex={1} />
        </div>
        <div style={{ borderRadius: 14, background: T.surface, border: `1px solid ${T.border}`, padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[['Amount', '฿' + group(amount)], ['Card fee (1.5%)', '฿' + fee.toFixed(2)]].map(([l, v]) => (
            <div key={l} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13.5 }}><span style={{ color: T.muted }}>{l}</span><span style={{ fontFamily: T.mono, fontWeight: 600 }}>{v}</span></div>
          ))}
          <div style={{ height: 1, background: T.border }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}><span style={{ fontSize: 14.5, fontWeight: 600 }}>Total</span><span style={{ fontSize: 19, fontWeight: 800, fontFamily: T.mono, color: T.violetSoft }}>฿{total.toFixed(2)}</span></div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, fontSize: 12, color: T.faint }}><TIcon d={TP.lock} c={T.faint} s={13} sw={1.8} /> Encrypted · 3-D Secure</div>
      </div>
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <ConfirmBtn>Pay ฿{total.toFixed(2)}</ConfirmBtn>
      </div>
    </div>
  );
}

function group(str) {
  if (str === '' || str === '.') return '0';
  const [i, d] = str.split('.');
  const gi = parseInt(i || '0', 10).toLocaleString('en-US');
  return d !== undefined ? `${gi}.${d}` : gi;
}
const toNum = (s) => (s === '' ? 0 : parseFloat(s) || 0);

function useAmount(initial) {
  const [amt, setAmt] = React.useState(initial);
  const press = (k) => setAmt(cur => {
    if (k === 'del') return cur.slice(0, -1);
    if (k === '.') return cur.includes('.') ? cur : (cur === '' ? '0.' : cur + '.');
    const [, dec] = cur.split('.');
    if (dec && dec.length >= 2) return cur;
    if (cur === '0') return k;
    return cur + k;
  });
  return [amt, setAmt, press];
}

function NumPad({ onPress }) {
  const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'];
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
      {keys.map(k => (
        <button key={k} onClick={() => onPress(k)} style={{
          height: 54, border: 'none', borderRadius: 14, cursor: 'pointer',
          background: T.surface, color: T.text, fontFamily: T.mono, fontSize: 23, fontWeight: 600,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          {k === 'del' ? <TIcon d="M9 5h12v14H9l-6-7 6-7zM13 9l5 5M18 9l-5 5" c={T.muted} s={22} sw={1.8} /> : k}
        </button>
      ))}
    </div>
  );
}

function TopBar({ title }) {
  return (
    <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 8px', display: 'flex', alignItems: 'center', gap: 12 }}>
      <div style={{ width: 38, height: 38, borderRadius: 11, background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TIcon d={TP.back} s={18} />
      </div>
      <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>{title}</span>
    </div>
  );
}

function Chip({ label, on, onClick }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, height: 38, borderRadius: 11, cursor: 'pointer', fontFamily: T.font,
      fontSize: 13.5, fontWeight: 650, transition: 'all .15s',
      border: `1px solid ${on ? T.violet : T.border}`,
      background: on ? 'rgba(155,107,255,0.16)' : T.surface,
      color: on ? T.violetSoft : T.muted,
    }}>{label}</button>
  );
}

function MethodRow({ icon, title, sub, on, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: '100%', textAlign: 'left', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 13,
      padding: '14px 16px', borderRadius: 16, fontFamily: T.font,
      background: on ? 'rgba(155,107,255,0.12)' : T.surface,
      border: `1.5px solid ${on ? T.violet : T.border}`,
    }}>
      <div style={{ width: 38, height: 38, borderRadius: 11, flexShrink: 0, background: on ? T.grad : 'rgba(255,255,255,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TIcon d={icon} c="#fff" s={19} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 15.5, fontWeight: 650, color: T.text }}>{title}</div>
        <div style={{ fontSize: 12.5, color: T.muted, marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{ width: 22, height: 22, borderRadius: 11, flexShrink: 0, border: `1.5px solid ${on ? T.violet : T.faint}`, background: on ? T.violet : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {on && <TIcon d={TP.check} c="#fff" s={13} sw={2.4} />}
      </div>
    </button>
  );
}

function AmountHero({ amt, sub, error }) {
  return (
    <div style={{ textAlign: 'center', padding: '6px 0 2px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
        <span style={{ fontSize: 30, fontWeight: 700, color: amt === '' ? T.faint : (error ? T.down : T.text), fontFamily: T.mono, alignSelf: 'flex-start', marginTop: 8 }}>฿</span>
        <span style={{ fontSize: 52, fontWeight: 800, letterSpacing: -1, color: amt === '' ? T.faint : (error ? T.down : T.text), fontFamily: T.mono }}>{group(amt)}</span>
      </div>
      <div style={{ fontSize: 13.5, color: error ? T.down : T.muted, marginTop: 4 }}>{error || sub}</div>
    </div>
  );
}

// ── Deposit ──────────────────────────────────────────────────
function DepositPage() {
  const [amt, setAmt, press] = useAmount('500');
  const [method, setMethod] = React.useState('promptpay');
  const [screen, setScreen] = React.useState('form');
  const n = toNum(amt);
  const presets = [100, 500, 1000, 2000];

  if (screen === 'promptpay') return <DepositPromptPay amount={amt} onBack={() => setScreen('form')} />;
  if (screen === 'bank') return <DepositBank amount={amt} onBack={() => setScreen('form')} />;
  if (screen === 'card') return <DepositCard amount={amt} onBack={() => setScreen('form')} />;

  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      <TopBar title="Deposit" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <AmountHero amt={amt} sub="Add funds to your THB balance" />
        <div style={{ display: 'flex', gap: 8 }}>
          {presets.map(p => <Chip key={p} label={'฿' + p.toLocaleString()} on={n === p} onClick={() => setAmt(String(p))} />)}
        </div>
        <div style={{ fontSize: 13, fontWeight: 600, color: T.muted, margin: '2px 2px -4px' }}>Pay with</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <MethodRow icon={TP.qr} title="PromptPay" sub="Instant · no fee" on={method === 'promptpay'} onClick={() => setMethod('promptpay')} />
          <MethodRow icon={TP.bank} title="Bank transfer" sub="SCB ••4192 · instant" on={method === 'bank'} onClick={() => setMethod('bank')} />
          <MethodRow icon={TP.card} title="Debit card" sub="1.5% fee" on={method === 'card'} onClick={() => setMethod('card')} />
        </div>
      </div>
      {/* keypad + cta */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <NumPad onPress={press} />
        <button disabled={n <= 0} onClick={() => { if (n > 0) setScreen(method); }} style={{
          width: '100%', height: 56, marginTop: 12, border: 'none', borderRadius: 16,
          cursor: n > 0 ? 'pointer' : 'default', fontFamily: T.font, fontSize: 17, fontWeight: 700, color: '#fff',
          background: n > 0 ? T.grad : 'rgba(255,255,255,0.08)', opacity: n > 0 ? 1 : 0.6,
          boxShadow: n > 0 ? '0 10px 26px rgba(124,58,237,0.42)' : 'none',
        }}>{n > 0 ? `Continue · ฿${group(amt)}` : 'Enter amount'}</button>
      </div>
    </div>
  );
}

// ── Withdraw ─────────────────────────────────────────────────
function WithdrawPage() {
  const AVAIL = 320;
  const [amt, setAmt, press] = useAmount('200');
  const [dest, setDest] = React.useState('scb');
  const n = toNum(amt);
  const over = n > AVAIL;
  const valid = n > 0 && !over;

  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      <TopBar title="Withdraw" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <AmountHero amt={amt} sub={`Available ฿${AVAIL.toFixed(2)}`} error={over ? 'Exceeds available balance' : null} />
        <div style={{ display: 'flex', gap: 8 }}>
          {[['฿50', 50], ['฿100', 100], ['฿200', 200], ['Max', AVAIL]].map(([l, v]) => (
            <Chip key={l} label={l} on={n === v} onClick={() => setAmt(String(v))} />
          ))}
        </div>
        <div style={{ fontSize: 13, fontWeight: 600, color: T.muted, margin: '2px 2px -4px' }}>Withdraw to</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <MethodRow icon={TP.bank} title="SCB Savings" sub="••4192 · 1–2 business days" on={dest === 'scb'} onClick={() => setDest('scb')} />
          <MethodRow icon={TP.bolt} title="Instant to PromptPay" sub="฿10 fee · arrives now" on={dest === 'promptpay'} onClick={() => setDest('promptpay')} />
        </div>
        <button style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, height: 46,
          border: `1px dashed ${T.border}`, borderRadius: 14, background: 'transparent', cursor: 'pointer',
          color: T.violetSoft, fontFamily: T.font, fontSize: 14.5, fontWeight: 600,
        }}>
          <TIcon d={TP.plus} s={16} /> Add bank account
        </button>
      </div>
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <NumPad onPress={press} />
        <button disabled={!valid} style={{
          width: '100%', height: 56, marginTop: 12, border: 'none', borderRadius: 16,
          cursor: valid ? 'pointer' : 'default', fontFamily: T.font, fontSize: 17, fontWeight: 700, color: '#fff',
          background: valid ? T.grad : 'rgba(255,255,255,0.08)', opacity: valid ? 1 : 0.6,
          boxShadow: valid ? '0 10px 26px rgba(124,58,237,0.42)' : 'none',
        }}>{over ? 'Amount too high' : n > 0 ? `Withdraw ฿${group(amt)}` : 'Enter amount'}</button>
      </div>
    </div>
  );
}

// ── Transaction status overlay (loading / success / error) ───
const TX_KEYFRAMES = `
@keyframes txspin { to { transform: rotate(360deg); } }
@keyframes txpop { 0% { transform: scale(0.4); opacity: 0; } 60% { transform: scale(1.08); } 100% { transform: scale(1); opacity: 1; } }
@keyframes txdraw { to { stroke-dashoffset: 0; } }
@keyframes txshake { 0%,100% { transform: translateX(0); } 20% { transform: translateX(-9px); } 40% { transform: translateX(8px); } 60% { transform: translateX(-5px); } 80% { transform: translateX(3px); } }
@keyframes txfade { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
@keyframes txpulse { 0%,100% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.05); opacity: 0.85; } }
@keyframes txbolt { 0%,100% { opacity: 0.4; transform: scale(0.9); } 50% { opacity: 1; transform: scale(1.1); } }
@keyframes txring { 0% { transform: scale(0.6); opacity: 0.6; } 100% { transform: scale(1.5); opacity: 0; } }
`;

function TxStatus({ state, title, sub, primary, onPrimary, onSecondary }) {
  const color = state === 'success' ? T.up : state === 'error' ? T.down : T.violet;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 60, background: 'rgba(8,5,14,0.82)', backdropFilter: 'blur(14px)', WebkitBackdropFilter: 'blur(14px)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', fontFamily: T.font }}>
      <style>{TX_KEYFRAMES}</style>

      {/* icon */}
      <div style={{ position: 'relative', width: 104, height: 104, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {state === 'loading' && (
          <React.Fragment>
            {/* expanding rings */}
            <div style={{ position: 'absolute', inset: 0, borderRadius: '50%', border: `2px solid ${T.violet}`, animation: 'txring 1.6s ease-out infinite' }} />
            {/* spinner */}
            <div style={{ width: 104, height: 104, borderRadius: '50%', background: `conic-gradient(from 0deg, ${T.violet} 0%, rgba(155,107,255,0) 75%)`, WebkitMask: 'radial-gradient(farthest-side, transparent calc(100% - 6px), #000 calc(100% - 6px))', mask: 'radial-gradient(farthest-side, transparent calc(100% - 6px), #000 calc(100% - 6px))', animation: 'txspin 0.9s linear infinite' }} />
            {/* bolt core */}
            <div style={{ position: 'absolute', animation: 'txbolt 1.1s ease-in-out infinite' }}>
              <TIcon d={TP.bolt} c={T.violetSoft} s={34} sw={2} />
            </div>
          </React.Fragment>
        )}

        {state === 'success' && (
          <div style={{ width: 104, height: 104, borderRadius: '50%', background: 'rgba(47,208,138,0.16)', border: `2px solid ${T.up}`, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: 'txpop 0.5s cubic-bezier(.2,.8,.3,1.2) both' }}>
            <svg width="52" height="52" viewBox="0 0 52 52" fill="none">
              <path d="M14 27l9 9 16-19" stroke={T.up} strokeWidth="5" strokeLinecap="round" strokeLinejoin="round" style={{ strokeDasharray: 60, strokeDashoffset: 60, animation: 'txdraw 0.45s 0.25s ease-out forwards' }} />
            </svg>
          </div>
        )}

        {state === 'error' && (
          <div style={{ width: 104, height: 104, borderRadius: '50%', background: 'rgba(255,92,108,0.16)', border: `2px solid ${T.down}`, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: 'txpop 0.4s ease-out both, txshake 0.5s 0.3s ease-in-out' }}>
            <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
              <path d="M15 15l18 18" stroke={T.down} strokeWidth="5" strokeLinecap="round" style={{ strokeDasharray: 26, strokeDashoffset: 26, animation: 'txdraw 0.28s 0.2s ease-out forwards' }} />
              <path d="M33 15L15 33" stroke={T.down} strokeWidth="5" strokeLinecap="round" style={{ strokeDasharray: 26, strokeDashoffset: 26, animation: 'txdraw 0.28s 0.42s ease-out forwards' }} />
            </svg>
          </div>
        )}
      </div>

      {/* text */}
      <div style={{ textAlign: 'center', marginTop: 26, animation: 'txfade 0.4s 0.15s both' }}>
        <div style={{ fontSize: 21, fontWeight: 750, letterSpacing: -0.3, color: T.text }}>{title}</div>
        {sub && <div style={{ fontSize: 14.5, color: T.muted, marginTop: 7, lineHeight: 1.5, maxWidth: 280 }}>{sub}</div>}
      </div>

      {/* actions */}
      {state !== 'loading' && (
        <div style={{ position: 'absolute', left: 16, right: 16, bottom: 30, display: 'flex', flexDirection: 'column', gap: 10, animation: 'txfade 0.4s 0.3s both' }}>
          <button onClick={onPrimary} style={{ width: '100%', height: 54, border: 'none', borderRadius: 16, cursor: 'pointer', fontFamily: T.font, fontSize: 16.5, fontWeight: 700, color: '#fff', background: state === 'error' ? T.grad : T.grad, boxShadow: '0 10px 26px rgba(124,58,237,0.42)' }}>{primary}</button>
          {state === 'error' && <button onClick={onSecondary} style={{ width: '100%', height: 50, borderRadius: 16, cursor: 'pointer', fontFamily: T.font, fontSize: 15.5, fontWeight: 600, color: T.muted, background: 'transparent', border: 'none' }}>Cancel</button>}
        </div>
      )}
    </div>
  );
}

// drives loading → outcome. outcome 'success'|'error'
function useTx() {
  const [tx, setTx] = React.useState(null); // null | loading | success | error
  const run = (outcome = 'success', ms = 1700) => {
    setTx('loading');
    setTimeout(() => setTx(outcome), ms);
  };
  const reset = () => setTx(null);
  return [tx, run, reset, setTx];
}

// ── asset model (for Send / Swap) ────────────────────────────
const ASSETS = {
  thb: { sym: '฿',   name: 'THB cash',    sub: 'Thai Baht',        bal: 320.00,  rate: 1,    color: '#C9B4FF', glyph: '฿' },
  gtx: { sym: '',    name: 'GridTokenX',  sub: 'GTX token',        bal: 968.40,  rate: 4.32, color: '#A974FF', glyph: 'g' },
  kwh: { sym: '',    name: 'kWh credits', sub: 'Tradeable energy', bal: 12.40,   rate: 4.30, color: '#FFD166', glyph: 'k' },
};
const TP2 = {
  swapV: 'M7 4v13M7 17l-3-3M7 17l3-3M17 20V7M17 7l-3 3M17 7l3 3',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zM4 21a8 8 0 0116 0',
  scan: 'M4 8V4h4M20 8V4h-4M4 16v4h4M20 16v4h-4M4 12h16',
  send: 'M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z',
  chev: 'M9 6l6 6-6 6',
};

function AssetMark({ id, size = 38 }) {
  const a = ASSETS[id];
  if (id === 'thb') return <div style={{ width: size, height: size, borderRadius: 11, flexShrink: 0, background: T.surface2, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: size * 0.5, fontWeight: 800, color: a.color, fontFamily: T.mono }}>฿</div>;
  if (id === 'gtx') return (
    <div style={{ width: size, height: size, borderRadius: 11, flexShrink: 0, background: T.grad, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: size * 0.09 }}>
        {[0,1,2,3].map(i => <div key={i} style={{ width: size*0.13, height: size*0.13, borderRadius: 2, background: i===0 ? '#fff' : 'rgba(255,255,255,0.6)' }} />)}
      </div>
    </div>
  );
  return <div style={{ width: size, height: size, borderRadius: 11, flexShrink: 0, background: 'rgba(255,209,102,0.16)', border: '1px solid rgba(255,209,102,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><TIcon d={TP.bolt} c="#FFD166" s={size*0.5} /></div>;
}

// ── Send ─────────────────────────────────────────────────────
const RECENTS = [
  { id: 'somchai', name: 'Somchai', tag: '@somchai_p', c: '#A974FF', init: 'S' },
  { id: 'noi',     name: 'Noi',     tag: '@noi.energy', c: '#2FD08A', init: 'N' },
  { id: 'zone2',   name: 'Zone 2 Co-op', tag: '@zone2coop', c: '#7CA8FF', init: 'Z' },
  { id: 'arthit',  name: 'Arthit',  tag: '@arthit', c: '#FFD166', init: 'A' },
];

function SendPage() {
  const [asset, setAsset] = React.useState('gtx');
  const [amt, setAmt, press] = useAmount('25');
  const [to, setTo] = React.useState('somchai');
  const [tx, run, reset] = useTx();
  const a = ASSETS[asset];
  const n = toNum(amt);
  const over = n > a.bal;
  const valid = n > 0 && !over && to;
  const fiat = n * a.rate;
  const toName = to ? RECENTS.find(r => r.id === to).name : '…';
  const unit = asset === 'gtx' ? 'GTX' : asset === 'kwh' ? 'kWh' : '฿';

  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      {tx && (
        <TxStatus
          state={tx}
          title={tx === 'loading' ? 'Sending…' : tx === 'success' ? 'Sent!' : 'Transfer failed'}
          sub={tx === 'loading' ? `${a.sym}${group(amt)} ${a.sym ? '' : unit + ' '}to ${toName}` : tx === 'success' ? `${a.sym}${group(amt)} ${a.sym ? '' : unit + ' '}sent to ${toName} · settled on-chain` : 'The network rejected this transfer. Your balance was not touched.'}
          primary={tx === 'success' ? 'Done' : 'Try again'}
          onPrimary={tx === 'success' ? reset : () => run('success')}
          onSecondary={reset}
        />
      )}
      <TopBar title="Send" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 12px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* amount hero */}
        <div style={{ textAlign: 'center', padding: '4px 0 0' }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 8 }}>
            {a.sym && <span style={{ fontSize: 30, fontWeight: 700, color: over ? T.down : T.text, fontFamily: T.mono }}>{a.sym}</span>}
            <span style={{ fontSize: 52, fontWeight: 800, letterSpacing: -1, color: amt === '' ? T.faint : (over ? T.down : T.text), fontFamily: T.mono }}>{group(amt)}</span>
            {!a.sym && <span style={{ fontSize: 22, fontWeight: 700, color: T.muted, fontFamily: T.font }}>{asset === 'gtx' ? 'GTX' : 'kWh'}</span>}
          </div>
          <div style={{ fontSize: 13.5, color: over ? T.down : T.muted, marginTop: 4 }}>
            {over ? 'More than your balance' : `≈ ฿${group(String(fiat.toFixed(2)))} · Balance ${a.sym}${a.bal.toLocaleString()}`}
          </div>
        </div>
        {/* asset switch */}
        <div style={{ display: 'flex', gap: 8 }}>
          {Object.keys(ASSETS).map(k => <Chip key={k} label={ASSETS[k].name.includes('Grid') ? 'GTX' : ASSETS[k].sym ? 'THB' : 'kWh'} on={asset === k} onClick={() => { setAsset(k); setAmt('0'); }} />)}
        </div>
        {/* recipient */}
        <div style={{ fontSize: 13, fontWeight: 600, color: T.muted, margin: '2px 2px -4px' }}>Send to</div>
        <div style={{ display: 'flex', gap: 12, overflowX: 'auto', paddingBottom: 2 }}>
          {RECENTS.map(r => {
            const on = to === r.id;
            return (
              <button key={r.id} onClick={() => setTo(r.id)} style={{ flexShrink: 0, width: 62, background: 'none', border: 'none', cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <div style={{ width: 50, height: 50, borderRadius: '50%', background: r.c, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, fontWeight: 700, color: '#1A1320', border: on ? `2.5px solid ${T.violetSoft}` : '2.5px solid transparent', boxShadow: on ? '0 0 0 2px rgba(155,107,255,0.3)' : 'none' }}>{r.init}</div>
                <span style={{ fontSize: 11.5, color: on ? T.text : T.muted, fontWeight: on ? 600 : 500, whiteSpace: 'nowrap' }}>{r.name.split(' ')[0]}</span>
              </button>
            );
          })}
        </div>
        {/* paste address */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '13px 14px', borderRadius: 14, background: T.surface, border: `1px solid ${T.border}` }}>
          <TIcon d={TP2.user} c={T.muted} s={18} sw={1.8} />
          <span style={{ flex: 1, fontSize: 14.5, color: to ? T.text : T.faint }}>{to ? `${RECENTS.find(r=>r.id===to).tag}` : 'Username or wallet address'}</span>
          <TIcon d={TP2.scan} c={T.violetSoft} s={19} sw={1.8} />
        </div>
      </div>
      {/* keypad + cta */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <NumPad onPress={press} />
        <button disabled={!valid} onClick={() => valid && run('success')} style={{
          width: '100%', height: 56, marginTop: 12, border: 'none', borderRadius: 16,
          cursor: valid ? 'pointer' : 'default', fontFamily: T.font, fontSize: 17, fontWeight: 700, color: '#fff',
          background: valid ? T.grad : 'rgba(255,255,255,0.08)', opacity: valid ? 1 : 0.6,
          boxShadow: valid ? '0 10px 26px rgba(124,58,237,0.42)' : 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9,
        }}>
          <TIcon d={TP2.send} c="#fff" s={19} sw={2} />
          {over ? 'Amount too high' : n > 0 ? `Send to ${toName}` : 'Enter amount'}
        </button>
      </div>
    </div>
  );
}

// ── Swap ─────────────────────────────────────────────────────
function SwapPage() {
  const [from, setFrom] = React.useState('kwh');
  const [toA, setToA] = React.useState('thb');
  const [amt, setAmt, press] = useAmount('5');
  const [tx, run, reset] = useTx();
  const fa = ASSETS[from], ta = ASSETS[toA];
  const n = toNum(amt);
  const over = n > fa.bal;
  const fee = 0.003; // 0.3%
  const out = n * (fa.rate / ta.rate) * (1 - fee);
  const valid = n > 0 && !over && from !== toA;

  const flip = () => { setFrom(toA); setToA(from); setAmt('0'); };

  const AssetSide = ({ id, label, value, editable, onPick }) => {
    const a = ASSETS[id];
    return (
      <div style={{ borderRadius: 18, background: T.surface, border: `1px solid ${editable && over ? T.down : T.border}`, padding: '15px 16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span style={{ fontSize: 12.5, color: T.muted, fontWeight: 600 }}>{label}</span>
          <span style={{ fontSize: 11.5, color: T.faint }}>Balance {a.sym}{a.bal.toLocaleString()}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 10 }}>
          <button onClick={onPick} style={{ display: 'flex', alignItems: 'center', gap: 9, background: 'rgba(255,255,255,0.04)', border: `1px solid ${T.border}`, borderRadius: 999, padding: '5px 11px 5px 6px', cursor: 'pointer' }}>
            <AssetMark id={id} size={28} />
            <span style={{ fontSize: 14.5, fontWeight: 700, color: T.text }}>{id === 'gtx' ? 'GTX' : id === 'kwh' ? 'kWh' : 'THB'}</span>
            <TIcon d={TP2.chev} c={T.faint} s={14} sw={2} />
          </button>
          <div style={{ flex: 1, textAlign: 'right', minWidth: 0 }}>
            <div style={{ fontSize: 30, fontWeight: 800, fontFamily: T.mono, letterSpacing: -0.5, color: editable ? (over ? T.down : T.text) : T.violetSoft, overflow: 'hidden', textOverflow: 'ellipsis' }}>{value}</div>
          </div>
        </div>
      </div>
    );
  };

  const fromU = from==='gtx'?'GTX':from==='kwh'?'kWh':'THB';
  const toU = toA==='gtx'?'GTX':toA==='kwh'?'kWh':'THB';

  return (
    <div style={{ position: 'absolute', inset: 0, background: T.bg, fontFamily: T.font, color: T.text, display: 'flex', flexDirection: 'column' }}>
      {tx && (
        <TxStatus
          state={tx}
          title={tx === 'loading' ? 'Swapping…' : tx === 'success' ? 'Swap complete' : 'Swap failed'}
          sub={tx === 'loading' ? `${group(amt)} ${fromU} → ${toU}` : tx === 'success' ? `${group(amt)} ${fromU} → ${out.toFixed(toA==='thb'?2:4)} ${toU} · settled` : 'Price moved beyond your limit. No assets were swapped.'}
          primary={tx === 'success' ? 'Done' : 'Try again'}
          onPrimary={tx === 'success' ? reset : () => run('success')}
          onSecondary={reset}
        />
      )}
      <TopBar title="Swap" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 12px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* from / to with overlapping flip btn */}
        <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', gap: 8 }}>
          <AssetSide id={from} label="You pay" value={group(amt)} editable />
          <AssetSide id={toA} label="You receive" value={out > 0 ? out.toFixed(toA === 'thb' ? 2 : 4) : '0'} />
          <button onClick={flip} style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%,-50%)', width: 42, height: 42, borderRadius: 13, background: T.bg, border: `1px solid ${T.border}`, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 14px rgba(0,0,0,0.4)' }}>
            <TIcon d={TP2.swapV} c={T.violetSoft} s={20} sw={2} />
          </button>
        </div>
        {/* rate + fee */}
        <div style={{ borderRadius: 14, background: T.surface, border: `1px solid ${T.border}`, padding: '4px 16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '11px 0', borderBottom: `1px solid ${T.border}` }}>
            <span style={{ fontSize: 13, color: T.muted }}>Rate</span>
            <span style={{ fontSize: 13, fontWeight: 600, fontFamily: T.mono }}>1 {from==='gtx'?'GTX':from==='kwh'?'kWh':'THB'} ≈ {(fa.rate/ta.rate).toFixed(4)} {toA==='gtx'?'GTX':toA==='kwh'?'kWh':'THB'}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '11px 0', borderBottom: `1px solid ${T.border}` }}>
            <span style={{ fontSize: 13, color: T.muted }}>Network fee</span>
            <span style={{ fontSize: 13, fontWeight: 600, fontFamily: T.mono, color: T.up }}>0.30%</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '11px 0' }}>
            <span style={{ fontSize: 13, color: T.muted }}>Est. value</span>
            <span style={{ fontSize: 13, fontWeight: 600, fontFamily: T.mono }}>฿{group(String((n*fa.rate).toFixed(2)))}</span>
          </div>
        </div>
      </div>
      {/* keypad + cta */}
      <div style={{ flexShrink: 0, padding: '10px 16px 30px', borderTop: `1px solid ${T.border}`, background: T.bg }}>
        <NumPad onPress={press} />
        <button disabled={!valid} onClick={() => valid && run('success')} style={{
          width: '100%', height: 56, marginTop: 12, border: 'none', borderRadius: 16,
          cursor: valid ? 'pointer' : 'default', fontFamily: T.font, fontSize: 17, fontWeight: 700, color: '#fff',
          background: valid ? T.grad : 'rgba(255,255,255,0.08)', opacity: valid ? 1 : 0.6,
          boxShadow: valid ? '0 10px 26px rgba(124,58,237,0.42)' : 'none',
        }}>{over ? 'Not enough balance' : n > 0 ? `Review swap` : 'Enter amount'}</button>
      </div>
    </div>
  );
}

Object.assign(window, { DepositPage, WithdrawPage, DepositPromptPay, DepositBank, DepositCard, SendPage, SwapPage, TxStatus });
