//
//  NDIDProfileView.swift
//  gridtokexios
//
//  14 · NDID verified identity — shown after NDID approval: citizen ID, name,
//  DOB, issuer, KYC level. Native port of mock-ui/ndid-profile.jsx (NDIDProfile).
//  Interactive: per-field privacy mask toggle (tap the eye to reveal/hide), a
//  global Show/Hide in the top bar, and a re-verify CTA. Masked fields render
//  every glyph (except spaces / - / /) as a bullet until revealed.
//

import SwiftUI

struct NDIDProfileView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    /// Mask keys; a key in the set means that field is currently hidden.
    enum Field: Hashable { case id, name, dob, phone }
    @State private var masked: Set<Field> = [.id, .dob, .phone]

    // Palette (mock-ui `NV`).
    private enum N {
        static let bg         = Color(hex: "#0B0712")
        static let hair       = Color.white.opacity(0.08)
        static let surface    = Color.white.opacity(0.045)
        static let border     = Color.white.opacity(0.09)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.5)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.3)
        static let violetSoft = Color(hex: "#C9B4FF")
        static let up         = Color(hex: "#2FD08A")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Thai bank identity provider used for verification.
    private let idpColor = Color(hex: "#2FAE4A")

    private var anyHidden: Bool { !masked.isEmpty }

    private func toggle(_ k: Field) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if masked.contains(k) { masked.remove(k) } else { masked.insert(k) }
        }
    }

    private func toggleAll() {
        withAnimation(.easeInOut(duration: 0.15)) {
            masked = anyHidden ? [] : [.id, .name, .dob, .phone]
        }
    }

    /// Replace every glyph except spaces / - / / with a bullet.
    private func mask(_ value: String, if hidden: Bool) -> String {
        guard hidden else { return value }
        return String(value.map { $0 == " " || $0 == "-" || $0 == "/" ? $0 : "•" })
    }

    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        identityCard
                        identityData
                        verificationDetails
                        unlocked
                        reVerifyButton
                    }
                    .padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 28)
                    .gtxUniversalWidth()
                }
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
        .enableInjection()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 13) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold)).foregroundStyle(N.muted)
            }
            .accessibilityLabel("Back")
            Text("Verified identity")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(N.text)
            Spacer()
            Button(action: toggleAll) {
                HStack(spacing: 6) {
                    Image(systemName: anyHidden ? "eye" : "eye.slash")
                        .font(.system(size: 13, weight: .semibold))
                    Text(anyHidden ? "Show" : "Hide")
                        .font(.system(size: 12.5, weight: .semibold))
                }
                .foregroundStyle(N.violetSoft)
                .padding(.horizontal, 11).frame(height: 30)
                .background(N.surface, in: Capsule())
                .overlay(Capsule().stroke(N.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 6)
    }

    // MARK: - Identity card hero

    private var identityCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(N.grad)
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.4), radius: 20, y: 14)

            // decorative blobs
            Circle().fill(Color.white.opacity(0.1)).frame(width: 160, height: 160)
                .offset(x: 110, y: -90)
            Circle().fill(Color.white.opacity(0.07)).frame(width: 130, height: 130)
                .offset(x: -120, y: 100)

            // guilloché security pattern
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Ellipse()
                        .stroke(Color.white, lineWidth: 0.6)
                        .frame(width: CGFloat(92 - i * 9) * 2, height: CGFloat(64 - i * 6) * 2)
                        .rotationEffect(.degrees(Double(i * 7)))
                        .offset(x: CGFloat(i * 6) - 24)
                }
            }
            .opacity(0.14)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("NATIONAL DIGITAL ID")
                        .font(.system(size: 12, weight: .bold)).tracking(1)
                        .foregroundStyle(Color.white.opacity(0.85))
                    Spacer()
                    Text("🇹🇭 THAILAND")
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.white.opacity(0.22), in: Capsule())
                }
                .padding(.bottom, 18)

                HStack(spacing: 14) {
                    Text("MC")
                        .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(Color.white.opacity(0.22), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Maya Chen")
                            .font(.system(size: 19, weight: .bold)).tracking(-0.3)
                            .foregroundStyle(.white)
                        Text("เมย่า เฉิน")
                            .font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.78))
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(N.up)
                    Text("KYC verified · Full settlement")
                        .font(.system(size: 12.5, weight: .bold)).foregroundStyle(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(N.up.opacity(0.25), in: Capsule())
                .overlay(Capsule().stroke(N.up.opacity(0.45), lineWidth: 1))
                .padding(.top, 16)

                HStack(spacing: 22) {
                    cardMeta("ISSUED", "18 Jun 2026")
                    cardMeta("VALID THRU", "06/29")
                    Spacer(minLength: 0)
                }
                .padding(.top, 16)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)

            // holographic seal
            ZStack {
                Circle().fill(AngularGradient(
                    colors: [Color(hex: "#C9B4FF"), Color(hex: "#A974FF"),
                             Color(hex: "#7CA8FF"), Color(hex: "#2FD08A"), Color(hex: "#C9B4FF")],
                    center: .center))
                    .frame(width: 46, height: 46)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                Circle().fill(Color(hex: "#7C3AED", alpha: 0.55)).frame(width: 38, height: 38)
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func cardMeta(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .bold)).tracking(1)
                .foregroundStyle(Color.white.opacity(0.6))
            Text(value).font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Identity data

    private var identityData: some View {
        section("Identity data") {
            VStack(spacing: 0) {
                dataRow(label: "Citizen ID", value: "1-2345-67890-12-3",
                        field: .id, mono: true, copy: true)
                dataRow(label: "Full name (English)", value: "Maya Chen", field: .name)
                dataRow(label: "Full name (Thai)", value: "เมย่า เฉิน",
                        field: .name, showToggle: false)
                dataRow(label: "Date of birth", value: "12 / 08 / 1990",
                        field: .dob, mono: true)
                dataRow(label: "Phone number", value: "+66 89 123 4567",
                        field: .phone, mono: true, last: true)
            }
            .padding(.horizontal, 16)
            .background(N.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(N.border, lineWidth: 1))
        }
    }

    private func dataRow(label: String, value: String, field: Field,
                         mono: Bool = false, copy: Bool = false,
                         showToggle: Bool = true, last: Bool = false) -> some View {
        let hidden = masked.contains(field)
        return VStack(spacing: 0) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label.uppercased())
                        .font(.system(size: 11.5, weight: .semibold)).tracking(0.5)
                        .foregroundStyle(N.faint)
                    Text(mask(value, if: hidden))
                        .font(.system(size: 16, weight: .semibold, design: mono ? .monospaced : .default))
                        .tracking(mono ? 1 : 0)
                        .foregroundStyle(N.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 4) {
                    if copy && !hidden {
                        Button {} label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 15, weight: .medium)).foregroundStyle(N.faint)
                                .padding(4)
                        }
                        .buttonStyle(.plain)
                    }
                    if showToggle {
                        Button { toggle(field) } label: {
                            Image(systemName: hidden ? "eye.slash" : "eye")
                                .font(.system(size: 15, weight: .medium)).foregroundStyle(N.faint)
                                .padding(4)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(hidden ? "Reveal \(label)" : "Hide \(label)")
                    }
                }
            }
            .padding(.vertical, 13)
            if !last { Rectangle().fill(N.hair).frame(height: 1) }
        }
    }

    // MARK: - Verification details

    private var verificationDetails: some View {
        section("Verification details") {
            VStack(spacing: 0) {
                detailRow(0, "Identity provider") {
                    HStack(spacing: 7) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 13, weight: .medium)).foregroundStyle(idpColor)
                        Text("Kasikornbank").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(N.text)
                    }
                }
                detailRow(1, "Verified on") {
                    Text("18 Jun 2026").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(N.text)
                }
                detailRow(2, "KYC level") {
                    Text("Level 2 — Full settlement")
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(N.violetSoft)
                }
                detailRow(3, "NDID ref") {
                    Text("NDID-8F4A2E91")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(N.text)
                }
            }
            .background(N.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(N.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func detailRow<V: View>(_ i: Int, _ label: String,
                                    @ViewBuilder value: () -> V) -> some View {
        VStack(spacing: 0) {
            if i > 0 { Rectangle().fill(N.hair).frame(height: 1) }
            HStack {
                Text(label).font(.system(size: 14)).foregroundStyle(N.muted)
                Spacer()
                value()
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
        }
    }

    // MARK: - Unlocked

    private var unlocked: some View {
        section("Unlocked") {
            VStack(spacing: 0) {
                let items = ["THB bank withdrawals",
                             "Settlement up to ฿200,000/mo",
                             "On-chain identity proof"]
                ForEach(Array(items.enumerated()), id: \.offset) { i, label in
                    VStack(spacing: 0) {
                        if i > 0 { Rectangle().fill(N.hair).frame(height: 1) }
                        HStack(spacing: 13) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold)).foregroundStyle(N.up)
                            Text(label).font(.system(size: 14.5)).foregroundStyle(N.text)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                    }
                }
            }
            .background(N.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(N.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // MARK: - Re-verify CTA

    private var reVerifyButton: some View {
        Button {} label: {
            HStack(spacing: 9) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(N.faint)
                Text("Re-verify identity")
                    .font(.system(size: 14.5, weight: .semibold)).foregroundStyle(N.muted)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(N.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section helper

    private func section<Content: View>(_ title: String,
                                        @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold)).tracking(0.6)
                .foregroundStyle(N.faint)
            content()
        }
    }
}

#Preview {
    NDIDProfileView()
}
