//
//  NDIDView.swift
//  gridtokexios
//
//  Verify account with NDID (Thai National Digital ID). Choose a Thai bank
//  Identity Provider, approve in the bank app, unlock full settlement (THB
//  withdrawals). Native port of mock-ui/ndid.jsx (VerifyNDID). States flow
//  select → pending → verified; the pending step auto-advances after a delay
//  (the mock's setTimeout). Bank marks fall back to brand-colored monograms —
//  no official logos bundled.
//

import SwiftUI

struct NDIDView: View {
    var onBack: () -> Void = {}
    var onVerified: () -> Void = {}

    @ObserveInjection var inject

    enum Step { case select, pending, verified }

    @State private var step: Step = .select
    @State private var bankID: String?
    @State private var query = ""

    // Palette (mock-ui `N`).
    private enum N {
        static let bg         = Color(hex: "#0B0712")
        static let hair       = Color.white.opacity(0.08)
        static let surface    = Color.white.opacity(0.04)
        static let text       = Color(hex: "#F4F1FA")
        static let muted      = Color(hex: "#F4F1FA", alpha: 0.5)
        static let faint      = Color(hex: "#F4F1FA", alpha: 0.3)
        static let violet     = Color(hex: "#9B6BFF")
        static let violetSoft = Color(hex: "#C9B4FF")
        static let grad       = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Thai bank Identity Providers. Brand colors + monogram fallback.
    private struct Bank: Identifiable {
        let id: String
        let name: String
        let full: String
        let code: String
        let c: Color
    }
    private let banks: [Bank] = [
        Bank(id: "scb",   name: "SCB",          full: "Siam Commercial Bank", code: "SCB", c: Color(hex: "#4E2E92")),
        Bank(id: "kbank", name: "KBank",        full: "Kasikornbank",         code: "K",   c: Color(hex: "#138F2C")),
        Bank(id: "bbl",   name: "Bangkok Bank", full: "Bualuang",             code: "BBL", c: Color(hex: "#1A3F7A")),
        Bank(id: "ktb",   name: "Krungthai",    full: "KTB next",             code: "KTB", c: Color(hex: "#00A4E4")),
        Bank(id: "bay",   name: "Krungsri",     full: "Bank of Ayudhya",      code: "KMA", c: Color(hex: "#A88438")),
        Bank(id: "ttb",   name: "ttb",          full: "TMBThanachart",        code: "ttb", c: Color(hex: "#1652F0")),
    ]

    private var chosen: Bank? { banks.first { $0.id == bankID } }
    private var shown: [Bank] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return banks }
        return banks.filter { ($0.name + " " + $0.full).lowercased().contains(q) }
    }

    var body: some View {
        ZStack {
            N.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                switch step {
                case .select:   selectStep
                case .pending:  pendingStep
                case .verified: verifiedStep
                }
            }
            .gtxUniversalWidth()
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
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(N.muted)
            }
            .accessibilityLabel("Back")
            Spacer()
            if step == .select {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill").font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(N.violetSoft)
                    Text("Secured by NDID").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(N.muted)
                }
            }
        }
        .frame(height: 24)
        .padding(.horizontal, 20).padding(.top, 8)
    }

    // MARK: - Select

    private var selectStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // trust badge
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(N.violetSoft)
                        .frame(width: 56, height: 56)
                        .background(N.violet.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(N.violet.opacity(0.28), lineWidth: 1))
                        .padding(.bottom, 18)

                    Text("Verify your identity")
                        .font(.system(size: 28, weight: .bold)).tracking(-0.7)
                        .foregroundStyle(N.text)

                    (Text("Choose your bank to confirm your identity through ")
                        + Text("NDID").foregroundStyle(N.text).bold()
                        + Text(" and unlock full settlement."))
                        .font(.system(size: 15)).foregroundStyle(N.muted).lineSpacing(3)
                        .padding(.top, 10)

                    // search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium)).foregroundStyle(N.faint)
                        TextField("Search your bank", text: $query)
                            .font(.system(size: 15)).foregroundStyle(N.text)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14).frame(height: 48)
                    .background(N.surface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(N.hair, lineWidth: 1))
                    .padding(.top, 22).padding(.bottom, 6)

                    // bank list
                    VStack(spacing: 8) {
                        ForEach(shown) { b in bankRow(b) }
                        if shown.isEmpty {
                            Text("No banks match \u{201C}\(query)\u{201D}.")
                                .font(.system(size: 14)).foregroundStyle(N.faint)
                                .frame(maxWidth: .infinity).padding(.vertical, 24)
                        }
                    }
                    .padding(.top, 8)

                    Text("Available to Thai nationals with a registered Thai bank account. \u{1F1F9}\u{1F1ED}")
                        .font(.system(size: 12)).foregroundStyle(N.faint).lineSpacing(2)
                        .padding(.top, 20).padding(.horizontal, 2)
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 16)
            }

            // CTA
            VStack(spacing: 12) {
                Button { start() } label: {
                    Text(chosen.map { "Continue with \($0.name)" } ?? "Select your bank")
                        .font(.system(size: 16.5, weight: .bold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(
                            chosen != nil ? AnyShapeStyle(N.grad) : AnyShapeStyle(Color.white.opacity(0.07)),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .opacity(chosen != nil ? 1 : 0.55)
                }
                .buttonStyle(.plain)
                .disabled(chosen == nil)

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill").font(.system(size: 11, weight: .semibold)).foregroundStyle(N.faint)
                    Text("Bank-grade encrypted \u{00B7} we never see your password")
                        .font(.system(size: 11.5)).foregroundStyle(N.faint)
                }
            }
            .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 32)
        }
    }

    private func bankRow(_ b: Bank) -> some View {
        let on = bankID == b.id
        return Button { bankID = b.id } label: {
            HStack(spacing: 13) {
                bankMark(b, size: 40, radius: 12)
                VStack(alignment: .leading, spacing: 1) {
                    Text(b.name).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(N.text)
                    Text(b.full).font(.system(size: 12.5)).foregroundStyle(N.faint)
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle()
                        .fill(on ? N.violet : Color.clear)
                        .overlay(Circle().stroke(on ? N.violet : N.faint, lineWidth: 1.5))
                        .frame(width: 22, height: 22)
                    if on {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 13).padding(.vertical, 12)
            .background(on ? N.violet.opacity(0.1) : N.surface,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(on ? N.violet : N.hair, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func bankMark(_ b: Bank, size: CGFloat, radius: CGFloat) -> some View {
        Text(b.code)
            .font(.system(size: b.code.count > 2 ? size * 0.28 : size * 0.42, weight: .heavy))
            .tracking(0.2)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(b.c, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(b.c.opacity(0.33), lineWidth: 1))
    }

    // MARK: - Pending

    private var pendingStep: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(N.violet, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(spinning ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spinning)
                Circle().stroke(N.violet.opacity(0.18), lineWidth: 2)
                if let chosen { bankMark(chosen, size: 56, radius: 16) }
            }
            .frame(width: 84, height: 84)
            .padding(.bottom, 30)

            Text("Approve in your \(chosen?.name ?? "bank") app")
                .font(.system(size: 23, weight: .bold)).tracking(-0.5)
                .foregroundStyle(N.text)
                .multilineTextAlignment(.center)

            Text("Open the \(chosen?.full ?? "bank") app and confirm your identity to finish verifying via NDID.")
                .font(.system(size: 15)).foregroundStyle(N.muted).lineSpacing(3)
                .multilineTextAlignment(.center).frame(maxWidth: 280)
                .padding(.top, 14)

            HStack(spacing: 9) {
                Circle().fill(N.violet).frame(width: 7, height: 7)
                    .opacity(spinning ? 0.3 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: spinning)
                Text("Waiting for approval\u{2026}").font(.system(size: 13.5, weight: .medium)).foregroundStyle(N.muted)
            }
            .padding(.top, 28)

            Button { step = .select } label: {
                Text("Cancel").font(.system(size: 14.5, weight: .semibold)).foregroundStyle(N.faint)
            }
            .buttonStyle(.plain)
            .padding(.top, 30)

            Spacer()
        }
        .padding(.horizontal, 36).padding(.bottom, 40)
        .frame(maxWidth: .infinity)
        .onAppear { spinning = true }
        .onDisappear { spinning = false }
    }

    @State private var spinning = false

    // MARK: - Verified

    private var verifiedStep: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 38, weight: .semibold)).foregroundStyle(N.violetSoft)
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(N.violet, lineWidth: 1.5))
                .background(Circle().stroke(N.violet.opacity(0.08), lineWidth: 8))

            Text("You're verified")
                .font(.system(size: 26, weight: .bold)).tracking(-0.6)
                .foregroundStyle(N.text)
                .padding(.top, 28)

            Text("Verified with \(chosen?.full ?? "your bank") via NDID. Full settlement is now unlocked.")
                .font(.system(size: 15.5)).foregroundStyle(N.muted).lineSpacing(3)
                .multilineTextAlignment(.center).frame(maxWidth: 290)
                .padding(.top, 14)

            VStack(spacing: 0) {
                let lines = ["THB bank withdrawals enabled",
                             "Settlement limit \u{0E3F}200,000 / month",
                             "Identity verified \u{00B7} KYC complete"]
                ForEach(Array(lines.enumerated()), id: \.offset) { i, l in
                    HStack(spacing: 13) {
                        Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(N.violet)
                        Text(l).font(.system(size: 14.5)).foregroundStyle(N.text)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 15).padding(.horizontal, 2)
                    .overlay(alignment: .top) {
                        if i > 0 { Rectangle().fill(N.hair).frame(height: 1) }
                    }
                }
            }
            .padding(.top, 30)

            Spacer()

            Button { onVerified() } label: {
                Text("Done")
                    .font(.system(size: 16.5, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(N.grad, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .padding(.horizontal, 32).padding(.bottom, 32)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Flow

    private func start() {
        guard bankID != nil else { return }
        withAnimation(.smooth(duration: 0.3)) { step = .pending }
        Task {
            try? await Task.sleep(for: .seconds(2.8))
            if step == .pending {
                await MainActor.run { withAnimation(.smooth(duration: 0.3)) { step = .verified } }
            }
        }
    }
}

#Preview {
    NDIDView()
}
