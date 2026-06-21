//
//  RegisterDeviceView.swift
//  gridtokexios
//
//  10 · Register meter — link a smart meter by scanning the serial barcode on
//  its back. Native port of mock-ui/register.jsx (RegisterDevice). A mock
//  viewfinder simulates a barcode scan: after ~2s (or a tap) the canned serial
//  is "detected", swapping the scan-status / manual-entry block for a found
//  card + 6-digit activation-code step. No camera/AVFoundation — the detection
//  is a timer, matching the prototype. "Rescan" resets the flow.
//

import SwiftUI

struct RegisterDeviceView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    enum Phase { case scanning, detected }

    @State private var phase: Phase = .scanning
    @State private var code = ""
    @State private var scanTask: Task<Void, Never>?
    @FocusState private var codeFocused: Bool

    private let serial = "GTX-5821-4490-1123"
    private let codeLen = 6
    private var codeComplete: Bool { code.count == codeLen }

    // Palette (mock-ui `R`).
    private enum R {
        static let bg         = Color(hex: "#0B0712")
        static let surface    = Color.white.opacity(0.05)
        static let border     = Color.white.opacity(0.09)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.54)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.32)
        static let violet     = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let up         = Color(hex: "#2FD08A")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            R.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scan the barcode on the back of your smart meter to link it to your account.")
                            .font(.system(size: 15)).foregroundStyle(R.muted).lineSpacing(3)
                            .padding(.horizontal, 2)

                        scanner

                        if phase == .scanning {
                            scanningStatus.transition(.opacity)
                            manualEntry.transition(.opacity)
                        } else {
                            foundCard.transition(.opacity)
                            activationStep.transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
                    .gtxUniversalWidth()
                }
                ctaBar
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18).onEnded { v in
                if v.startLocation.x < 24, v.translation.width > 70, abs(v.translation.height) < 60 {
                    onBack()
                }
            })
        .onAppear { startScan() }
        .onDisappear { scanTask?.cancel() }
        .enableInjection()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold)).foregroundStyle(R.violetSoft)
                    .frame(width: 38, height: 38)
                    .background(R.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(R.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")
            Text("Register meter").font(.system(size: 22, weight: .bold)).tracking(-0.4).foregroundStyle(R.text)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
    }

    // MARK: - Scanner viewport

    private var scanner: some View {
        let found = phase == .detected
        return ZStack {
            // device-surface grid
            GridPattern().opacity(0.5)

            // meter label being scanned
            VStack(spacing: 0) {
                HStack {
                    Text("GRIDTOKENX").font(.system(size: 10, weight: .heavy)).tracking(0.5)
                        .foregroundStyle(Color(hex: "#15101F"))
                    Spacer()
                    Text("METER · v2").font(.system(size: 8.5)).foregroundStyle(Color(hex: "#6B6478"))
                }
                .padding(.bottom, 8)
                Barcode()
                Text(serial)
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced)).tracking(1)
                    .foregroundStyle(Color(hex: "#15101F"))
                    .padding(.top, 7)
            }
            .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 12)
            .frame(width: 200)
            .background(Color(hex: "#EDE9F2"), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.5), radius: 15, y: 14)

            // corner brackets
            CornerBrackets(color: R.violet)

            // scan line
            if !found {
                ScanLine(color: R.violet)
            }

            // found check
            if found {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: "#053123"))
                            .frame(width: 30, height: 30)
                            .background(R.up, in: Circle())
                            .shadow(color: R.up.opacity(0.5), radius: 6, y: 4)
                    }
                    Spacer()
                }
                .padding(14)
            }

            // flash toggle
            VStack {
                Spacer()
                Image(systemName: "bolt.fill")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(R.violetSoft)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(R.border, lineWidth: 1))
            }
            .padding(.bottom, 14)
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .background(
            RadialGradient(colors: [Color(hex: "#1A1330"), Color(hex: "#0A0712")],
                           center: UnitPoint(x: 0.5, y: 0.3), startRadius: 0, endRadius: 260),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(found ? R.up.opacity(0.5) : R.border, lineWidth: 1))
        .shadow(color: found ? R.up.opacity(0.18) : .clear, radius: 0)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { if !found { detectNow() } }
        .animation(.smooth(duration: 0.3), value: found)
    }

    // MARK: - Scanning state

    private var scanningStatus: some View {
        HStack(spacing: 9) {
            BlinkDot(color: R.violet)
            Text("Scanning for barcode…").font(.system(size: 14.5)).foregroundStyle(R.muted)
        }
        .frame(maxWidth: .infinity)
    }

    private var manualEntry: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Rectangle().fill(R.border).frame(height: 1)
                Text("or enter manually").font(.system(size: 12.5)).foregroundStyle(R.faint).fixedSize()
                Rectangle().fill(R.border).frame(height: 1)
            }
            HStack(spacing: 10) {
                Image(systemName: "keyboard")
                    .font(.system(size: 17)).foregroundStyle(R.faint)
                Text("GTX-____-____-____")
                    .font(.system(size: 16, design: .monospaced)).tracking(1).foregroundStyle(R.faint)
                Spacer()
            }
            .padding(.horizontal, 16).frame(height: 56)
            .background(R.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(R.border, lineWidth: 1))
        }
    }

    // MARK: - Detected state

    private var foundCard: some View {
        HStack(spacing: 13) {
            Image(systemName: "speedometer")
                .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(R.grad, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("GridTokenX Meter found").font(.system(size: 15, weight: .semibold)).foregroundStyle(R.text)
                Text(serial).font(.system(size: 13, design: .monospaced)).tracking(0.5).foregroundStyle(R.muted)
            }
            Spacer(minLength: 0)
            Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundStyle(R.up)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(R.up.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(R.up.opacity(0.35), lineWidth: 1))
    }

    private var activationStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Enter activation code").font(.system(size: 15, weight: .bold)).foregroundStyle(R.text)
                Text("Type the 6-digit code shown on your meter's display or setup card.")
                    .font(.system(size: 13.5)).foregroundStyle(R.muted).lineSpacing(2)
            }

            ZStack {
                // hidden capture input
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($codeFocused)
                    .foregroundStyle(.clear).tint(.clear)
                    .onChange(of: code) { _, v in
                        let digits = String(v.filter(\.isNumber).prefix(codeLen))
                        if digits != code { code = digits }
                    }

                HStack(spacing: 8) {
                    ForEach(0..<codeLen, id: \.self) { i in
                        codeCell(i)
                    }
                }
                .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .onTapGesture { codeFocused = true }

            (Text("Can't find it? ").foregroundStyle(R.muted)
                + Text("Resend to meter").foregroundStyle(R.violetSoft).bold())
                .font(.system(size: 13))
        }
    }

    private func codeCell(_ i: Int) -> some View {
        let chars = Array(code)
        let ch = i < chars.count ? String(chars[i]) : ""
        let active = i == code.count
        return ZStack {
            if !ch.isEmpty {
                Text(ch).font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundStyle(R.text)
            } else if active {
                Text("|").font(.system(size: 22, weight: .light, design: .monospaced)).foregroundStyle(R.violet)
            }
        }
        .frame(maxWidth: .infinity).frame(height: 56)
        .background(ch.isEmpty ? R.surface : R.violet.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(active ? R.violet : (ch.isEmpty ? R.border : R.violet.opacity(0.45)), lineWidth: 1.5))
        .shadow(color: active ? R.violet.opacity(0.16) : .clear, radius: 0)
    }

    // MARK: - CTA

    private var ctaBar: some View {
        HStack(spacing: 10) {
            if phase == .detected {
                Button { startScan() } label: {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 22, weight: .semibold)).foregroundStyle(R.violetSoft)
                        .frame(width: 56, height: 56)
                        .background(R.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(R.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rescan")
            }

            Button {} label: {
                Text(phase == .scanning ? "Searching…" : (codeComplete ? "Activate meter" : "Enter activation code"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(codeComplete ? AnyShapeStyle(R.grad) : AnyShapeStyle(Color.white.opacity(0.08)),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .opacity(codeComplete ? 1 : 0.6)
                    .shadow(color: codeComplete ? Color(hex: "#7C3AED", alpha: 0.42) : .clear, radius: 13, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(!codeComplete)
        }
        .gtxUniversalWidth()
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 30)
        .background(R.bg)
        .overlay(Rectangle().fill(R.border).frame(height: 1), alignment: .top)
    }

    // MARK: - Scan flow

    private func startScan() {
        scanTask?.cancel()
        withAnimation(.smooth(duration: 0.3)) {
            phase = .scanning
            code = ""
        }
        codeFocused = false
        scanTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await MainActor.run { detectNow() }
        }
    }

    private func detectNow() {
        scanTask?.cancel()
        guard phase != .detected else { return }
        withAnimation(.smooth(duration: 0.3)) { phase = .detected }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { codeFocused = true }
    }
}

// MARK: - Decorative pieces

/// Vertical barcode bars (mock-ui `Barcode`).
private struct Barcode: View {
    private let widths: [CGFloat] = [3, 1, 2, 1, 1, 3, 1, 2, 2, 1, 1, 3, 2, 1, 1, 2,
                                     3, 1, 1, 2, 1, 3, 1, 2, 1, 1, 2, 3, 1, 1, 2, 1]
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(Array(widths.enumerated()), id: \.offset) { i, w in
                Rectangle()
                    .fill(i.isMultiple(of: 2) ? Color(hex: "#15101F") : .clear)
                    .frame(width: w * 2)
            }
        }
        .frame(height: 56)
    }
}

/// Faint device-surface grid (repeating-linear-gradient in the mock).
private struct GridPattern: View {
    var body: some View {
        GeometryReader { geo in
            let step: CGFloat = 34
            Path { p in
                var x: CGFloat = 0
                while x <= geo.size.width { p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: geo.size.height)); x += step }
                var y: CGFloat = 0
                while y <= geo.size.height { p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: geo.size.width, y: y)); y += step }
            }
            .stroke(Color.white.opacity(0.04), lineWidth: 1)
        }
    }
}

/// Four violet L-shaped corner brackets framing the viewfinder.
private struct CornerBrackets: View {
    let color: Color
    var body: some View {
        VStack {
            HStack { corner(.tl); Spacer(); corner(.tr) }
            Spacer()
            HStack { corner(.bl); Spacer(); corner(.br) }
        }
        .padding(14)
    }

    enum Pos { case tl, tr, bl, br }

    private func corner(_ pos: Pos) -> some View {
        let r: CGFloat = 10, lw: CGFloat = 3
        return CornerShape(pos: pos, radius: r)
            .stroke(color, style: .init(lineWidth: lw, lineCap: .round, lineJoin: .round))
            .frame(width: 30, height: 30)
    }
}

private struct CornerShape: Shape {
    let pos: CornerBrackets.Pos
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = radius
        switch pos {
        case .tl:
            p.move(to: .init(x: rect.minX, y: rect.maxY))
            p.addLine(to: .init(x: rect.minX, y: rect.minY + r))
            p.addQuadCurve(to: .init(x: rect.minX + r, y: rect.minY), control: .init(x: rect.minX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.minY))
        case .tr:
            p.move(to: .init(x: rect.minX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX - r, y: rect.minY))
            p.addQuadCurve(to: .init(x: rect.maxX, y: rect.minY + r), control: .init(x: rect.maxX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        case .bl:
            p.move(to: .init(x: rect.minX, y: rect.minY))
            p.addLine(to: .init(x: rect.minX, y: rect.maxY - r))
            p.addQuadCurve(to: .init(x: rect.minX + r, y: rect.maxY), control: .init(x: rect.minX, y: rect.maxY))
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        case .br:
            p.move(to: .init(x: rect.maxX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY - r))
            p.addQuadCurve(to: .init(x: rect.maxX - r, y: rect.maxY), control: .init(x: rect.maxX, y: rect.maxY))
            p.addLine(to: .init(x: rect.minX, y: rect.maxY))
        }
        return p
    }
}

/// Animated sweeping scan line.
private struct ScanLine: View {
    let color: Color
    @State private var down = false
    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 2)
                .shadow(color: color, radius: 7)
                .padding(.horizontal, 22)
                .offset(y: down ? geo.size.height - 30 : 30)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { down = true }
                }
        }
    }
}

/// Blinking status dot.
private struct BlinkDot: View {
    let color: Color
    @State private var on = true
    var body: some View {
        Circle().fill(color).frame(width: 7, height: 7)
            .opacity(on ? 1 : 0.25)
            .onAppear { withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { on = false } }
    }
}

#Preview {
    RegisterDeviceView()
}
