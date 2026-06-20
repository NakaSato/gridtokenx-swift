//
//  WelcomeView.swift
//  gridtokexios
//
//  Welcome index page. Native SwiftUI port of mock-ui welcome-anim.jsx.
//  Launch sequence: grid ignites → logo splash → headline → CTA settle.
//

import SwiftUI

// MARK: - Easing + keyframe helper (ports the jsx `animate(...)` util)

private enum Ease {
    static func outCubic(_ p: Double) -> Double { 1 - pow(1 - p, 3) }
    static func inCubic(_ p: Double) -> Double { p * p * p }
    static func outExpo(_ p: Double) -> Double { p >= 1 ? 1 : 1 - pow(2, -10 * p) }
    static func outBack(_ p: Double) -> Double {
        let c1 = 1.70158, c3 = 1.70158 + 1
        return 1 + c3 * pow(p - 1, 3) + c1 * pow(p - 1, 2)
    }
}

/// Interpolate `from`→`to` between times `start`…`end` at clock `t`, eased.
private func anim(_ from: Double, _ to: Double, _ start: Double, _ end: Double,
                  _ ease: (Double) -> Double = Ease.outCubic, at t: Double) -> Double {
    if t <= start { return from }
    if t >= end { return to }
    let p = (t - start) / (end - start)
    return from + (to - from) * ease(p)
}

struct WelcomeView: View {
    var onCreateAccount: () -> Void = {}
    var onSignIn: () -> Void = {}

    /// Launch reference time — elapsed seconds drive the whole sequence.
    /// Owned by the router so navigating back doesn't replay the intro: by the
    /// time the user returns, elapsed time is past the sequence end (settled).
    var start = Date()

    @ObserveInjection var inject

    /// UI tests freeze the animation (settled frame) so the app reaches idle —
    /// a perpetual TimelineView(.animation) otherwise defeats XCUITest sync.
    private let frozen = ProcessInfo.processInfo.arguments.contains("UITEST")

    var body: some View {
        Group {
            if frozen {
                scene(now: 0, t: 999)   // fully settled, no animation
            } else {
                TimelineView(.animation) { timeline in
                    scene(now: timeline.date.timeIntervalSinceReferenceDate,
                          t: timeline.date.timeIntervalSince(start))
                }
            }
        }
        .preferredColorScheme(.dark)
        .enableInjection()
    }

    private func scene(now: Double, t: Double) -> some View {
        ZStack {
            GTXColor.bg.ignoresSafeArea()

            PowerFlowBackground(now: now, reveal: anim(0, 1, 0.2, 2.4, Ease.outCubic, at: t),
                                glow: anim(0, 1, 0, 2.0, Ease.outCubic, at: t))
                .ignoresSafeArea()

            Ignition(t: t).ignoresSafeArea()

            LogoSplash(t: t)

            content(t: t)
        }
    }

    // MARK: - Welcome content (headline, subtitle, CTA) — reveals after logo exits

    private func content(t: Double) -> some View {
        let l1o = anim(0, 1, 4.6, 5.2, Ease.outCubic, at: t)
        let l1y = anim(30, 0, 4.6, 5.2, Ease.outCubic, at: t)
        let l2o = anim(0, 1, 4.85, 5.5, Ease.outCubic, at: t)
        let l2y = anim(30, 0, 4.85, 5.5, Ease.outCubic, at: t)
        let sweep = anim(1, 0, 4.85, 6.0, Ease.outCubic, at: t)   // gradient slide, 1→0
        let subO = anim(0, 1, 5.8, 6.4, Ease.outCubic, at: t)
        let subY = anim(22, 0, 5.8, 6.4, Ease.outCubic, at: t)
        let btnO = anim(0, 1, 6.6, 7.1, Ease.outCubic, at: t)
        let btnY = anim(40, 0, 6.6, 7.3, Ease.outBack, at: t)
        let signO = anim(0, 1, 7.35, 7.85, Ease.outCubic, at: t)
        let signY = anim(16, 0, 7.35, 7.85, Ease.outCubic, at: t)
        let pulse = 0.42   // static button shadow — no blink

        return VStack(alignment: .leading, spacing: 0) {
            Spacer()
            headline(l1o: l1o, l1y: l1y, l2o: l2o, l2y: l2y, sweep: sweep)
            subtitle.opacity(subO).offset(y: subY)
            createButton(shadow: pulse).opacity(btnO).offset(y: btnY)
            signInRow.opacity(signO).offset(y: signY)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
    }

    private func headline(l1o: Double, l1y: Double, l2o: Double, l2y: Double, sweep: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Trade clean energy,")
                .foregroundStyle(GTXColor.text)
                .opacity(l1o)
                .offset(y: l1y)
            Text("peer to peer.")
                .foregroundStyle(
                    LinearGradient(
                        colors: [GTXColor.violetDeep, GTXColor.violetLight, GTXColor.violetSoft, GTXColor.violetLight, GTXColor.violetDeep],
                        startPoint: UnitPoint(x: -sweep, y: 0.5),
                        endPoint: UnitPoint(x: 2 - sweep, y: 0.5)
                    )
                )
                .opacity(l2o)
                .offset(y: l2y)
        }
        .font(.system(size: 52, weight: .heavy))
        .tracking(-1.5)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 18)
    }

    private var subtitle: some View {
        Text("Buy and sell solar power directly with your community — settled on-chain in real time.")
            .font(.system(size: 19))
            .lineSpacing(6)
            .foregroundStyle(GTXColor.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 30)
    }

    private func createButton(shadow: Double) -> some View {
        Button("Create account", action: onCreateAccount)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(LinearGradient.gtxBrand, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .shadow(color: GTXColor.violetDeep.opacity(shadow), radius: 16, y: 12)
    }

    private var signInRow: some View {
        HStack(spacing: 5) {
            Text("Already trading?")
                .foregroundStyle(GTXColor.muted)
            Button(action: onSignIn) {
                Text("Sign in")
                    .foregroundStyle(GTXColor.violetSoft)
                    .fontWeight(.semibold)
            }
        }
        .font(.system(size: 16))
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}

// MARK: - Ignition flash (t 0.1…1.1)

private struct Ignition: View {
    let t: Double

    var body: some View {
        let grow = anim(0, 1, 0.1, 0.5, Ease.outExpo, at: t)
        let fade = anim(1, 0, 0.45, 1.05, Ease.inCubic, at: t)

        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, GTXColor.violetSoft, .white, GTXColor.violetSoft, .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: geo.size.width, height: 3)
            .scaleEffect(x: grow, y: 1, anchor: .center)
            .shadow(color: GTXColor.violetSoft.opacity(0.8), radius: 12)
            .position(x: geo.size.width / 2, y: geo.size.height * 0.34)
            .opacity(t > 1.1 ? 0 : fade)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Logo splash (t 1.5…4.6): assemble → hold → dissolve up

private struct LogoSplash: View {
    let t: Double
    private let S: CGFloat = 80

    var body: some View {
        let sqScale = anim(0.3, 1, 1.7, 2.5, Ease.outBack, at: t)
        let sqOpacity = anim(0, 1, 1.7, 2.2, Ease.outCubic, at: t)
        let wordO = anim(0, 1, 2.55, 3.1, Ease.outCubic, at: t)
        let wordY = anim(14, 0, 2.55, 3.1, Ease.outCubic, at: t)
        let exitO = anim(1, 0, 3.8, 4.4, Ease.inCubic, at: t)
        let exitY = anim(0, -54, 3.8, 4.5, Ease.inCubic, at: t)
        let visible = t >= 1.5 && t <= 4.6

        return VStack(spacing: 18) {
            // Brand square with assembling 2×2 dot grid.
            ZStack {
                RoundedRectangle(cornerRadius: S * 0.3, style: .continuous)
                    .fill(LinearGradient.gtxBrand)
                    .frame(width: S, height: S)
                    .shadow(color: GTXColor.violetDeep.opacity(0.6), radius: 20, y: 12)

                let cell = S * 0.15
                let gap = S * 0.11
                VStack(spacing: gap) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<2, id: \.self) { col in
                                let i = row * 2 + col
                                let dp = anim(0, 1, 2.25 + Double(i) * 0.09, 2.55 + Double(i) * 0.09, Ease.outBack, at: t)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(i == 0 ? Color.white : Color.white.opacity(0.65))
                                    .frame(width: cell, height: cell)
                                    .scaleEffect(dp)
                                    .opacity(dp)
                            }
                        }
                    }
                }
            }
            .scaleEffect(sqScale)
            .opacity(sqOpacity)

            // Wordmark — "GridToken" + violet "X".
            (Text("GridToken").foregroundColor(GTXColor.text)
                + Text("X").foregroundColor(GTXColor.violetSoft))
                .font(.system(size: 30, weight: .bold))
                .tracking(-0.6)
                .opacity(wordO)
                .offset(y: wordY)
        }
        .offset(y: exitY)
        .opacity(visible ? exitO : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(y: -60)   // sit slightly above center, ~40% line
        .allowsHitTesting(false)
    }
}

// MARK: - Power-flow animated background

/// Atom-style orbital electron cluster over an ambient radial glow, with a
/// bottom fade for text legibility.
private struct PowerFlowBackground: View {
    let now: Double
    let reveal: Double
    let glow: Double

    // Atom-style orbital rings: electrons circling a shared nucleus near the top.
    private struct Orbit {
        let rx: CGFloat        // horizontal radius (fraction of width)
        let ry: CGFloat        // vertical radius (fraction of width)
        let tilt: Double       // ring tilt, radians
        let color: Color
        let speed: Double
        let count: Int
    }
    private let orbits: [Orbit] = [
        .init(rx: 0.20, ry: 0.075, tilt:  0.5,  color: GTXColor.violetLight, speed: 1.4, count: 2),
        .init(rx: 0.30, ry: 0.11,  tilt: -0.4,  color: GTXColor.violetSoft,  speed: 1.0, count: 3),
        .init(rx: 0.40, ry: 0.15,  tilt:  1.05, color: GTXColor.violetDeep,  speed: 0.7, count: 2),
        .init(rx: 0.46, ry: 0.18,  tilt: -1.2,  color: GTXColor.violet,      speed: 0.55, count: 3),
    ]

    var body: some View {
        ZStack {
            GeometryReader { geo in
                RadialGradient(
                    colors: [GTXColor.violetDeep.opacity(0.35), .clear],
                    center: .center, startRadius: 0, endRadius: 280
                )
                .frame(width: 560, height: 560)
                .scaleEffect(0.4 + glow * 0.9)
                .opacity(glow * 0.9)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.34)
            }

            Canvas { ctx, size in draw(in: &ctx, size: size) }
                .opacity(reveal)

            GeometryReader { geo in
                LinearGradient(colors: [.clear, GTXColor.bg], startPoint: .top, endPoint: .bottom)
                    .frame(height: geo.size.height * 0.58)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }

    private func draw(in ctx: inout GraphicsContext, size: CGSize) {
        drawOrbits(in: &ctx, size: size)
    }

    /// Bohr-atom orbital cluster — electrons circling a glowing nucleus near the top.
    private func drawOrbits(in ctx: inout GraphicsContext, size: CGSize) {
        let W = size.width, H = size.height
        let cx = W * 0.5, cy = H * 0.30

        // Nucleus glow.
        let nr: CGFloat = 6
        var nucleus = ctx
        nucleus.addFilter(.shadow(color: GTXColor.violetSoft, radius: 16))
        nucleus.fill(Path(ellipseIn: CGRect(x: cx - nr, y: cy - nr, width: nr * 2, height: nr * 2)),
                     with: .color(.white.opacity(0.9)))

        for orb in orbits {
            let rx = W * orb.rx, ry = W * orb.ry
            let cosT = cos(orb.tilt), sinT = sin(orb.tilt)
            // Map a unit-circle angle to the tilted ellipse in screen space.
            func pos(_ ang: Double) -> CGPoint {
                let ex = cos(ang) * rx, ey = sin(ang) * ry
                return CGPoint(x: cx + ex * cosT - ey * sinT,
                               y: cy + ex * sinT + ey * cosT)
            }

            // Faint orbit ring.
            var ring = Path()
            let steps = 64
            for i in 0...steps {
                let p = pos(Double(i) / Double(steps) * 2 * .pi)
                if i == 0 { ring.move(to: p) } else { ring.addLine(to: p) }
            }
            ctx.stroke(ring, with: .color(orb.color.opacity(0.12)), lineWidth: 1)

            // Electrons riding the ring.
            for k in 0..<orb.count {
                let ang = now * orb.speed + Double(k) / Double(orb.count) * 2 * .pi
                let p = pos(ang)
                // Depth cue: brighter on the near (lower) half of the ellipse.
                let depth = 0.55 + 0.45 * (sin(ang) * 0.5 + 0.5)
                let flicker = 0.8 + 0.2 * sin(now * 5 + Double(k))

                let hr = 5.0 * depth * flicker
                var halo = ctx
                halo.addFilter(.shadow(color: orb.color, radius: 11))
                halo.fill(Path(ellipseIn: CGRect(x: p.x - hr, y: p.y - hr, width: hr * 2, height: hr * 2)),
                          with: .color(orb.color.opacity(0.4 * depth)))

                let cr = 2.2 * depth
                var core = ctx
                core.addFilter(.shadow(color: .white, radius: 5))
                core.fill(Path(ellipseIn: CGRect(x: p.x - cr, y: p.y - cr, width: cr * 2, height: cr * 2)),
                          with: .color(.white.opacity(0.95)))
            }
        }
    }
}

#Preview {
    WelcomeView()
}
