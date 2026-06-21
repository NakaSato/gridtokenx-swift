// GridTokenX — screens 15, 16, 17
// 15 · Live grid map (tappable canvas energy network — mobile)
// 16 · Notifications center
// 17 · Order history (tabs: All / Buy / Sell / DCA)

const EX = {
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
  down: '#FF5C6C',
  gold: '#FFD166',
  teal: '#2FD08A',
  blue: '#7CA8FF',
  orange: '#FF9A5C',
  font: '-apple-system, "SF Pro Text", system-ui, sans-serif',
  mono: '"SF Mono", ui-monospace, monospace',
};

function EIcon({ d, c = EX.violetSoft, s = 18, sw = 2, fill }) {
  return <svg width={s} height={s} viewBox="0 0 24 24" fill={fill || 'none'}><path d={d} stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></svg>;
}
const EP = {
  back: 'M15 6l-6 6 6 6',
  chev: 'M9 6l6 6-6 6',
  filter: 'M4 6h16M7 12h10M10 18h4',
  bell: 'M6 9a6 6 0 1112 0c0 5 2 6 2 6H4s2-1 2-6zM10 20a2 2 0 004 0',
  close: 'M18 6L6 18M6 6l12 12',
  info: 'M12 16v-4M12 8h.01M12 3a9 9 0 100 18 9 9 0 000-18z',
  check: 'M4 12.5l5 5 11-12',
  bolt: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  alert: 'M12 8v5M12 16h.01M12 3l9 16H3l9-16z',
  calendar: 'M4 6h16v15H4zM4 10h16M8 3v4M16 3v4',
  dca: 'M7 10l-3 3 3 3M4 13h12M17 14l3-3-3-3M20 11H8',
  hist: 'M12 8v4l3 2M12 3a9 9 0 100 18 9 9 0 000-18z',
  sun: 'M12 5V3M12 21v-2M5 12H3M21 12h-2M6.4 6.4L5 5M18.6 6.4L20 5M6.4 17.6L5 19M18.6 17.6L20 19M12 8a4 4 0 100 8 4 4 0 000-8z',
  wind: 'M9.59 4.59A2 2 0 1111 8H2m10.59 11.41A2 2 0 1014 16H2m15.73-8.27A2.5 2.5 0 1119.5 12H2',
  battery: 'M5 7h11v10H5zM16 9h3v6h-3',
  home: 'M3 12l9-9 9 9M5 10v9h5v-5h4v5h5v-9',
  industry: 'M2 20V9l6-5 6 5v11M14 20V14h4v6M2 20h20',
  ev: 'M7 11h4m4 0h2M5 17v3M19 17v3M3 11l2-7h14l2 7M3 11v6h18v-6',
};

// ── 15 · LIVE GRID MAP ─────────────────────────────────────────
const MAP_NODES = [
  { id: 'solar', label: 'Solar A', type: 'solar',   x: 22, y: 22, c: '#FFD166', v: '4.2 kW', icon: EP.sun  },
  { id: 'wind',  label: 'Wind',   type: 'wind',    x: 72, y: 16, c: '#2FD08A', v: '6.1 kW', icon: EP.wind },
  { id: 'bat',   label: 'Battery',type: 'storage', x: 28, y: 55, c: '#7CA8FF', v: '78%',    icon: EP.battery },
  { id: 'hub',   label: 'Hub',    type: 'hub',     x: 56, y: 52, c: '#9B6BFF', v: '14.1 kW',icon: EP.bolt  },
  { id: 'res',   label: 'Home',   type: 'consumer',x: 16, y: 80, c: '#C9B4FF', v: '2.1 kW', icon: EP.home  },
  { id: 'com',   label: 'Office', type: 'consumer',x: 54, y: 82, c: '#C9B4FF', v: '3.4 kW', icon: EP.home  },
  { id: 'ind',   label: 'Factory',type: 'consumer',x: 82, y: 74, c: '#FF9A5C', v: '4.7 kW', icon: EP.industry },
  { id: 'ev',    label: 'EV',     type: 'ev',      x: 88, y: 45, c: '#E0A23C', v: '0.9 kW', icon: EP.ev    },
];
const MAP_EDGES = [
  [0,3,'#FFD166'],[1,3,'#2FD08A'],[3,2,'#7CA8FF'],
  [3,4,'#9B6BFF'],[3,5,'#9B6BFF'],[3,6,'#A974FF'],[2,4,'#E0A23C'],[7,6,'#E0A23C'],
];

function GridMapMobile() {
  const [sel, setSel] = React.useState(null);
  const node = sel !== null ? MAP_NODES[sel] : null;

  return (
    <div style={{ position: 'absolute', inset: 0, background: EX.bg, fontFamily: EX.font, color: EX.text, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 4px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <EIcon d={EP.back} c={EX.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Live grid map</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '5px 10px', borderRadius: 999, background: 'rgba(47,208,138,0.12)', border: '1px solid rgba(47,208,138,0.3)', fontSize: 11.5, fontWeight: 700, color: EX.up }}>
          <span className="gtx-blink" style={{ width: 6, height: 6, borderRadius: '50%', background: EX.up }} />LIVE
        </div>
      </div>

      {/* stat chips */}
      <div style={{ display: 'flex', gap: 8, padding: '10px 16px 4px', flexShrink: 0 }}>
        {[['#FFD166','14.1 kW','gen'],['#FF5C6C','11.1 kW','load'],['#9B6BFF','+3.0 kW','surplus']].map(([c,v,l])=>(
          <div key={l} style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 3, padding: '9px 10px', borderRadius: 12, background: EX.surface, border: `1px solid ${EX.border}` }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
              <span style={{ width: 6, height: 6, borderRadius: '50%', background: c }} />
              <span style={{ fontSize: 9.5, fontWeight: 600, color: EX.faint, textTransform: 'uppercase', letterSpacing: 0.4 }}>{l}</span>
            </div>
            <span style={{ fontSize: 14, fontWeight: 750, fontFamily: EX.mono, color: c }}>{v}</span>
          </div>
        ))}
      </div>

      {/* network SVG map */}
      <div style={{ flex: 1, position: 'relative', margin: '6px 16px', borderRadius: 20, overflow: 'hidden', background: 'radial-gradient(120% 90% at 48% 38%, #1a1330 0%, #0a0712 75%)', border: `1px solid ${EX.border}` }}>
        {/* grid texture */}
        <div style={{ position: 'absolute', inset: 0, backgroundImage: 'repeating-linear-gradient(0deg,rgba(255,255,255,0.03) 0 1px,transparent 1px 36px),repeating-linear-gradient(90deg,rgba(255,255,255,0.03) 0 1px,transparent 1px 36px)' }} />

        <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
          {MAP_EDGES.map(([a,b,c],i)=>{
            const na=MAP_NODES[a], nb=MAP_NODES[b];
            const dim = sel!==null && sel!==a && sel!==b;
            return <line key={i} x1={na.x} y1={na.y} x2={nb.x} y2={nb.y}
              stroke={c} strokeWidth="0.7" opacity={dim?0.12:0.65}
              strokeDasharray="2 3" vectorEffect="non-scaling-stroke" />;
          })}
        </svg>

        {/* nodes */}
        {MAP_NODES.map((n,i)=>{
          const on = sel===i;
          const dim = sel!==null && !on;
          return (
            <button key={i} onClick={()=>setSel(on?null:i)} style={{
              position: 'absolute', left:`${n.x}%`, top:`${n.y}%`, transform:'translate(-50%,-50%)',
              width: n.type==='hub'?52:40, height: n.type==='hub'?52:40,
              borderRadius: n.type==='hub'?'18px':'50%',
              background: on?`${n.c}28`:'rgba(14,10,24,0.9)',
              border: `${on?2:1.5}px solid ${on?n.c:n.c+'60'}`,
              boxShadow: on?`0 0 0 6px ${n.c}22,0 8px 24px ${n.c}44`:`0 4px 12px ${n.c}33`,
              display:'flex', alignItems:'center', justifyContent:'center',
              cursor:'pointer', transition:'all .18s', opacity: dim?0.3:1,
            }}>
              <EIcon d={n.icon} c={n.c} s={n.type==='hub'?22:18} sw={1.8} />
            </button>
          );
        })}

        {/* node label tooltip */}
        {node && (
          <div style={{ position: 'absolute', bottom: 14, left: 14, right: 14, padding: '12px 14px', borderRadius: 14, background: 'rgba(11,7,18,0.92)', border: `1px solid ${node.c}44`, backdropFilter: 'blur(12px)', display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 36, height: 36, borderRadius: 11, background: `${node.c}22`, border: `1px solid ${node.c}55`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <EIcon d={node.icon} c={node.c} s={18} sw={1.8} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>{node.label}</div>
              <div style={{ fontSize: 12.5, color: EX.muted, marginTop: 2, textTransform: 'capitalize' }}>{node.type}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: 16, fontWeight: 750, fontFamily: EX.mono, color: node.c }}>{node.v}</div>
              <div style={{ fontSize: 11, color: EX.faint, marginTop: 2 }}>current</div>
            </div>
          </div>
        )}
      </div>

      {/* legend */}
      <div style={{ flexShrink: 0, padding: '10px 16px 28px', display: 'flex', gap: 10, flexWrap: 'wrap' }}>
        {[['#FFD166','Solar'],['#2FD08A','Wind'],['#7CA8FF','Storage'],['#9B6BFF','Hub'],['#C9B4FF','Consumer'],['#E0A23C','EV']].map(([c,l])=>(
          <div key={l} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: EX.muted }}>
            <span style={{ width: 7, height: 7, borderRadius: '50%', background: c }} />{l}
          </div>
        ))}
      </div>
    </div>
  );
}

// ── 16 · NOTIFICATIONS ─────────────────────────────────────────
const NOTIFS = [
  { id: 1, type: 'fill', cat: 'trades', icon: EP.check, color: EX.up,   title: 'Buy filled',          body: '3.2 kWh bought at ฿4.28 · Zone 1→2', time: '2m ago',  read: false },
  { id: 2, type: 'alert',cat: 'alerts', icon: EP.alert, color: '#FFD166',title: 'Price alert triggered',body: 'GRX/THB crossed ฿4.50 upward',        time: '18m ago', read: false, action: 'Sell now' },
  { id: 3, type: 'grid', cat: 'grid',   icon: EP.bolt,  color: EX.violet,title: 'Surplus in Zone 2',   body: '3.4 kW excess — good time to sell',   time: '1h ago',  read: false, action: 'Sell' },
  { id: 4, type: 'fill', cat: 'trades', icon: EP.check, color: EX.down,  title: 'Sell filled',         body: '5.4 kWh sold at ฿4.31 · Zone 2→4',   time: '2h ago',  read: true  },
  { id: 5, type: 'dca',  cat: 'trades', icon: EP.dca,   color: EX.violet,title: 'DCA executed',        body: 'Bought 3.0 kWh as scheduled (daily)', time: '6h ago',  read: true  },
  { id: 6, type: 'grid', cat: 'grid',   icon: EP.info,  color: EX.blue,  title: 'Meter online',        body: 'GTX-5821-4490-1123 reconnected',      time: 'Yesterday',read: true },
  { id: 7, type: 'alert',cat: 'alerts', icon: EP.alert, color: '#FFD166',title: 'Grid event',          body: 'High demand detected in your zone',   time: '2d ago',  read: true  },
];

function NotificationsPage() {
  const [items, setItems] = React.useState(NOTIFS);
  const [filter, setFilter] = React.useState('all');
  const unread = items.filter(n => !n.read).length;
  const markAll = () => setItems(ns => ns.map(n => ({ ...n, read: true })));
  const dismiss = (id) => setItems(ns => ns.filter(n => n.id !== id));
  const read = (id) => setItems(ns => ns.map(n => n.id === id ? { ...n, read: true } : n));

  const filters = [['all', 'All'], ['trades', 'Trades'], ['alerts', 'Alerts'], ['grid', 'Grid']];
  const shown = filter === 'all' ? items : items.filter(n => n.cat === filter);
  const groups = [['New', shown.filter(n => !n.read)], ['Earlier', shown.filter(n => n.read)]];

  const Card = (n) => (
    <div key={n.id} onClick={() => read(n.id)} style={{ display: 'flex', alignItems: 'flex-start', gap: 13, padding: '13px 14px', borderRadius: 16, cursor: 'pointer', background: n.read ? EX.surface : 'rgba(155,107,255,0.09)', border: `1px solid ${n.read ? EX.border : 'rgba(155,107,255,0.26)'}`, position: 'relative' }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0, background: `${n.color}1A`, border: `1px solid ${n.color}44`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <EIcon d={n.icon} c={n.color} s={20} sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
          {!n.read && <span style={{ width: 7, height: 7, borderRadius: '50%', background: EX.violet, flexShrink: 0 }} />}
          <span style={{ fontSize: 14.5, fontWeight: n.read ? 550 : 700 }}>{n.title}</span>
        </div>
        <div style={{ fontSize: 13, color: EX.muted, marginTop: 3, lineHeight: 1.4 }}>{n.body}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 8 }}>
          <span style={{ fontSize: 11.5, color: EX.faint }}>{n.time}</span>
          {n.action && (
            <button onClick={(e) => { e.stopPropagation(); read(n.id); }} style={{
              padding: '5px 12px', borderRadius: 999, border: 'none', cursor: 'pointer', fontFamily: EX.font,
              fontSize: 12, fontWeight: 700, color: '#fff', background: EX.grad,
            }}>{n.action}</button>
          )}
        </div>
      </div>
      <button onClick={(e) => { e.stopPropagation(); dismiss(n.id); }} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, flexShrink: 0, opacity: 0.4 }}>
        <EIcon d={EP.close} c={EX.muted} s={14} sw={2} />
      </button>
    </div>
  );

  return (
    <div style={{ position: 'absolute', inset: 0, background: EX.bg, fontFamily: EX.font, color: EX.text, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <EIcon d={EP.back} c={EX.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 22, fontWeight: 700, letterSpacing: -0.4, display: 'flex', alignItems: 'center', gap: 9 }}>
          Notifications
          {unread > 0 && <span style={{ fontSize: 13, fontWeight: 750, padding: '2px 8px', borderRadius: 999, background: EX.violet, color: '#fff' }}>{unread}</span>}
        </span>
        {unread > 0 && <button onClick={markAll} style={{ background: 'none', border: 'none', cursor: 'pointer', color: EX.violetSoft, fontFamily: EX.font, fontSize: 13.5, fontWeight: 600 }}>Mark all read</button>}
      </div>

      {/* filter chips */}
      <div style={{ flexShrink: 0, display: 'flex', gap: 8, padding: '8px 16px 4px' }}>
        {filters.map(([k, l]) => {
          const on = filter === k;
          const cnt = k === 'all' ? unread : items.filter(n => n.cat === k && !n.read).length;
          return (
            <button key={k} onClick={() => setFilter(k)} style={{
              display: 'flex', alignItems: 'center', gap: 6, height: 32, padding: '0 13px', borderRadius: 999, cursor: 'pointer',
              fontFamily: EX.font, fontSize: 13, fontWeight: 650, transition: 'all .15s',
              border: `1px solid ${on ? 'transparent' : EX.border}`,
              background: on ? EX.grad : EX.surface, color: on ? '#fff' : EX.muted,
            }}>
              {l}
              {cnt > 0 && <span style={{ fontSize: 10.5, fontWeight: 800, minWidth: 16, height: 16, padding: '0 4px', borderRadius: 999, background: on ? 'rgba(255,255,255,0.28)' : 'rgba(155,107,255,0.22)', color: on ? '#fff' : EX.violetSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{cnt}</span>}
            </button>
          );
        })}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 32px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {groups.map(([label, list]) => list.length > 0 && (
          <React.Fragment key={label}>
            <div style={{ fontSize: 12, fontWeight: 700, color: EX.faint, textTransform: 'uppercase', letterSpacing: 0.5, padding: '6px 2px 2px' }}>{label}</div>
            {list.map(Card)}
          </React.Fragment>
        ))}
        {shown.length === 0 && (
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, paddingTop: 80 }}>
            <EIcon d={EP.bell} c={EX.faint} s={40} sw={1.4} />
            <span style={{ fontSize: 15, color: EX.faint }}>All caught up</span>
          </div>
        )}
      </div>
    </div>
  );
}

// ── 17 · ORDER HISTORY ─────────────────────────────────────────
const ORDERS = [
  { side:'buy',  kwh:3.20, price:4.28, total:13.70, status:'filled',   zone:'Zone 1→2', date:'Today, 14:22',    type:'market' },
  { side:'sell', kwh:5.40, price:4.31, total:23.27, status:'filled',   zone:'Zone 2→4', date:'Today, 12:05',    type:'limit'  },
  { side:'buy',  kwh:3.00, price:4.32, total:12.96, status:'filled',   zone:'Zone 2',   date:'Today, 06:00',    type:'dca'    },
  { side:'buy',  kwh:1.50, price:4.50, total:6.75,  status:'cancelled',zone:'Zone 1→2', date:'Yesterday, 18:11',type:'limit'  },
  { side:'sell', kwh:4.00, price:4.25, total:17.00, status:'filled',   zone:'Zone 4→1', date:'Yesterday, 09:30',type:'market' },
  { side:'buy',  kwh:3.00, price:4.40, total:13.20, status:'filled',   zone:'Zone 2',   date:'Jun 17, 06:00',   type:'dca'    },
  { side:'sell', kwh:2.10, price:4.18, total:8.78,  status:'filled',   zone:'Zone 2→3', date:'Jun 16, 11:45',   type:'limit'  },
  { side:'buy',  kwh:5.00, price:4.60, total:23.00, status:'partially',zone:'Zone 1→2', date:'Jun 15, 16:20',   type:'limit'  },
];

function OrderHistory() {
  const [tab, setTab] = React.useState('all');
  const tabs = [['all', 'All'], ['buy', 'Buy'], ['sell', 'Sell'], ['dca', 'DCA']];
  const ARR = { up: 'M12 19V5M5 12l7-7 7 7', down: 'M12 5v14M5 12l7 7 7-7' };
  const statusColor = { filled: EX.up, cancelled: EX.faint, partially: '#FFD166' };
  const statusLabel = { filled: 'Filled', cancelled: 'Cancelled', partially: 'Partial' };

  const shown = tab === 'all' ? ORDERS : tab === 'dca' ? ORDERS.filter(o => o.type === 'dca') : ORDERS.filter(o => o.side === tab);

  // summary (settled orders only)
  const settled = ORDERS.filter(o => o.status !== 'cancelled');
  const soldVal = settled.filter(o => o.side === 'sell').reduce((a, o) => a + o.total, 0);
  const boughtVal = settled.filter(o => o.side === 'buy').reduce((a, o) => a + o.total, 0);
  const net = soldVal - boughtVal;
  const volKwh = settled.reduce((a, o) => a + o.kwh, 0);

  // group shown by day
  const order = [];
  const byDay = {};
  shown.forEach(o => { const k = o.date.split(',')[0]; if (!byDay[k]) { byDay[k] = []; order.push(k); } byDay[k].push(o); });

  return (
    <div style={{ position: 'absolute', inset: 0, background: EX.bg, fontFamily: EX.font, color: EX.text, display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 56, flexShrink: 0, padding: '56px 16px 4px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <EIcon d={EP.back} c={EX.muted} s={22} sw={2} />
        <span style={{ flex: 1, fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>Order history</span>
        <EIcon d={EP.filter} c={EX.muted} s={20} sw={2} />
      </div>

      {/* net summary */}
      <div style={{ flexShrink: 0, padding: '8px 16px 0' }}>
        <div style={{ padding: '14px 16px', borderRadius: 16, background: EX.surface, border: `1px solid ${EX.border}` }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 12.5, color: EX.muted }}>Net this week</span>
            <span style={{ fontSize: 11.5, color: EX.faint }}>{volKwh.toFixed(1)} kWh traded</span>
          </div>
          <div style={{ fontSize: 26, fontWeight: 800, fontFamily: EX.mono, color: net >= 0 ? EX.up : EX.down, marginTop: 3 }}>{net >= 0 ? '+' : '−'}฿{Math.abs(net).toFixed(2)}</div>
          <div style={{ display: 'flex', gap: 18, marginTop: 8 }}>
            <span style={{ fontSize: 12.5, color: EX.muted }}>Sold <b style={{ color: EX.up, fontFamily: EX.mono }}>฿{soldVal.toFixed(0)}</b></span>
            <span style={{ fontSize: 12.5, color: EX.muted }}>Bought <b style={{ color: EX.text, fontFamily: EX.mono }}>฿{boughtVal.toFixed(0)}</b></span>
          </div>
        </div>
      </div>

      {/* underline tabs */}
      <div style={{ flexShrink: 0, padding: '14px 16px 0', display: 'flex', gap: 24, borderBottom: `1px solid ${EX.border}` }}>
        {tabs.map(([k, l]) => {
          const on = tab === k;
          return (
            <button key={k} onClick={() => setTab(k)} style={{
              background: 'none', border: 'none', padding: '0 0 11px', cursor: 'pointer', marginBottom: -1,
              fontFamily: EX.font, fontSize: 14.5, fontWeight: on ? 700 : 500,
              color: on ? EX.text : EX.muted, borderBottom: `2px solid ${on ? EX.violet : 'transparent'}`,
            }}>{l}</button>
          );
        })}
      </div>

      {/* grouped list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 32px' }}>
        {order.map(day => {
          const dayNet = byDay[day].filter(o => o.status !== 'cancelled').reduce((a, o) => a + (o.side === 'sell' ? o.total : -o.total), 0);
          return (
            <div key={day}>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '14px 2px 8px' }}>
                <span style={{ fontSize: 12, fontWeight: 700, color: EX.faint, textTransform: 'uppercase', letterSpacing: 0.5 }}>{day}</span>
                <span style={{ fontSize: 12, fontWeight: 650, fontFamily: EX.mono, color: dayNet >= 0 ? EX.up : EX.down }}>{dayNet >= 0 ? '+' : '−'}฿{Math.abs(dayNet).toFixed(2)}</span>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {byDay[day].map((o, i) => {
                  const sideC = o.side === 'buy' ? EX.up : EX.down;
                  const cancelled = o.status === 'cancelled';
                  const tm = (o.date.split(',')[1] || '').trim();
                  return (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 14px', borderRadius: 16, background: EX.surface, border: `1px solid ${EX.border}`, opacity: cancelled ? 0.6 : 1 }}>
                      <div style={{ width: 38, height: 38, borderRadius: 12, flexShrink: 0, background: `${sideC}18`, border: `1px solid ${sideC}44`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <EIcon d={o.side === 'sell' ? ARR.up : ARR.down} c={sideC} s={18} sw={2.2} />
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                          <span style={{ fontSize: 14.5, fontWeight: 650, textTransform: 'capitalize' }}>{o.side} {o.kwh.toFixed(2)} kWh</span>
                          {o.type === 'dca' && <span style={{ fontSize: 10, fontWeight: 800, padding: '2px 6px', borderRadius: 5, background: 'rgba(155,107,255,0.2)', color: EX.violetSoft }}>DCA</span>}
                        </div>
                        <div style={{ fontSize: 12, color: EX.faint, marginTop: 2 }}>{o.zone} · ฿{o.price.toFixed(2)}/kWh{tm ? ' · ' + tm : ''}</div>
                      </div>
                      <div style={{ textAlign: 'right', flexShrink: 0 }}>
                        <div style={{ fontSize: 14.5, fontWeight: 750, fontFamily: EX.mono, color: cancelled ? EX.faint : (o.side === 'sell' ? EX.up : EX.text) }}>
                          {!cancelled && (o.side === 'sell' ? '+' : '−')}฿{o.total.toFixed(2)}
                        </div>
                        <div style={{ fontSize: 11, fontWeight: 700, color: statusColor[o.status], marginTop: 2 }}>{statusLabel[o.status]}</div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
        {shown.length === 0 && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, paddingTop: 80 }}>
            <EIcon d={EP.hist} c={EX.faint} s={40} sw={1.4} />
            <span style={{ fontSize: 15, color: EX.faint }}>No orders here yet</span>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { GridMapMobile, NotificationsPage, OrderHistory });
