// GridTokenX — Dashboard "Easy view" (age-friendly / accessible UX).
// Larger type, bigger tap targets, plain language, high contrast,
// fewer choices on screen. Exports DashboardEasy to window.

const E = {
  bg: '#0B0712',
  surface: 'rgba(255,255,255,0.06)',
  border: 'rgba(255,255,255,0.11)',
  text: '#FBFAFF',
  sub: 'rgba(251,250,255,0.74)',   // brighter than usual for contrast
  faint: 'rgba(251,250,255,0.5)',
  violet: '#B594FF',
  grad: 'linear-gradient(135deg, #A974FF 0%, #7C3AED 100%)',
  up: '#43E6A0',
  upBg: 'rgba(67,230,160,0.16)',
  down: '#FF6B79',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function EIcon({ d, c = '#fff', s = 26, sw = 2.2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const EP = {
  sun: 'M12 4V2M12 22v-2M4 12H2M22 12h-2M6 6L4.5 4.5M18 6l1.5-1.5M6 18l-1.5 1.5M18 18l1.5 1.5M12 8a4 4 0 100 8 4 4 0 000-8z',
  sell: 'M12 19V5M5 12l7-7 7 7',
  buy: 'M12 5v14M5 12l7 7 7-7',
  help: 'M12 3a9 9 0 100 18 9 9 0 000-18zM9.5 9.5a2.5 2.5 0 114 2.3c-.9.5-1.5 1-1.5 2.2M12 17h.01',
  up: 'M5 12l5 5 9-12',
  access: 'M12 3.5a1.6 1.6 0 100 3.2 1.6 1.6 0 000-3.2zM4 8.5h16M9.5 21l2.5-8 2.5 8M9.5 13.5h5',
  chev: 'M9 6l6 6-6 6',
};

function BigButton({ icon, label, hint, bg, color = '#fff', glow }) {
  return (
    <button style={{
      width: '100%', minHeight: 76, border: 'none', borderRadius: 22, cursor: 'pointer',
      background: bg, color, fontFamily: E.font, display: 'flex', alignItems: 'center', gap: 16,
      padding: '0 20px', boxShadow: glow, textAlign: 'left',
    }}>
      <div style={{ width: 48, height: 48, borderRadius: 15, flexShrink: 0, background: 'rgba(255,255,255,0.22)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <EIcon d={icon} c={color} s={26} sw={2.6} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 21, fontWeight: 750, letterSpacing: -0.2 }}>{label}</div>
        <div style={{ fontSize: 14.5, fontWeight: 500, opacity: 0.85, marginTop: 2 }}>{hint}</div>
      </div>
      <EIcon d={EP.chev} c={color} s={22} sw={2.6} />
    </button>
  );
}

function DashboardEasy() {
  return (
    <div style={{ position: 'absolute', inset: 0, background: E.bg, fontFamily: E.font, color: E.text, display: 'flex', flexDirection: 'column' }}>
      {/* header */}
      <div style={{ paddingTop: 60, flexShrink: 0, padding: '60px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 15, color: E.sub, fontWeight: 500 }}>Good morning</div>
          <div style={{ fontSize: 27, fontWeight: 800, letterSpacing: -0.5, marginTop: 1 }}>Maya</div>
        </div>
        <button aria-label="Accessibility view" style={{
          width: 48, height: 48, flexShrink: 0, borderRadius: 16, cursor: 'pointer',
          background: E.surface, border: `1px solid ${E.border}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <EIcon d={EP.access} c={E.violet} s={24} sw={2} />
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 20px 26px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* today earnings — the one big number */}
        <div style={{ borderRadius: 22, padding: '20px 22px', background: E.grad, boxShadow: '0 16px 40px rgba(124,58,237,0.4)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -40, right: -30, width: 150, height: 150, borderRadius: '50%', background: 'rgba(255,255,255,0.12)' }} />
          <div style={{ position: 'relative' }}>
            <div style={{ fontSize: 16, color: 'rgba(255,255,255,0.85)', fontWeight: 600 }}>You earned today</div>
            <div style={{ fontSize: 44, fontWeight: 850, letterSpacing: -1.5, fontFamily: E.mono, marginTop: 2 }}>฿362</div>
            <div style={{ fontSize: 16, color: 'rgba(255,255,255,0.9)', fontWeight: 500, marginTop: 4 }}>from selling 84 kWh of your solar</div>
          </div>
        </div>

        {/* live status — plain language */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 16, padding: '16px 20px', borderRadius: 20, background: E.surface, border: `1px solid ${E.border}` }}>
          <div style={{ width: 50, height: 50, borderRadius: 15, flexShrink: 0, background: E.upBg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <EIcon d={EP.sun} c={E.up} s={28} sw={2.2} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 19, fontWeight: 700 }}>Your solar is on</div>
            <div style={{ fontSize: 15.5, color: E.sub, marginTop: 2 }}>Producing <b style={{ color: E.text }}>5.2 kW</b> right now</div>
          </div>
        </div>

        {/* current price — large, clear */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 20px', borderRadius: 20, background: E.surface, border: `1px solid ${E.border}` }}>
          <div>
            <div style={{ fontSize: 15.5, color: E.sub, fontWeight: 500 }}>Best sell price now</div>
            <div style={{ fontSize: 30, fontWeight: 800, fontFamily: E.mono, marginTop: 2 }}>฿4.50<span style={{ fontSize: 17, color: E.sub, fontWeight: 600 }}> /kWh</span></div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 12px', borderRadius: 999, background: E.upBg, color: E.up, fontSize: 15, fontWeight: 700 }}>
            <EIcon d={EP.up} c={E.up} s={16} sw={2.6} /> Good
          </div>
        </div>

        {/* the two primary actions — huge, labelled */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 4 }}>
          <BigButton icon={EP.sell} label="Sell my energy" hint="Send your extra power to neighbours" bg={E.up} color="#053123" glow="0 12px 30px rgba(67,230,160,0.32)" />
          <BigButton icon={EP.buy} label="Buy energy" hint="Get clean power from your area" bg={E.grad} glow="0 12px 30px rgba(124,58,237,0.4)" />
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { DashboardEasy });
