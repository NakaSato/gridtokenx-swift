//
//  ProfileEditView.swift
//  gridtokexios
//
//  08b · Edit profile — name/username/email/phone/bio form reached from the
//  Settings profile card. Native port of mock-ui/settings.jsx `ProfileEdit`
//  (dark theme). Fields drive local @State; Save just pops back (no store yet).
//  Role + verified status come from NDID and are read-only here.
//

import SwiftUI

struct ProfileEditView: View {
    var onBack: () -> Void = {}

    @ObserveInjection var inject

    @State private var name     = "Maya Chen"
    @State private var username = "mayachen"
    @State private var email    = "maya.chen@gmail.com"
    @State private var phone    = "+66 89 123 4567"
    @State private var bio      = "Solar prosumer in Bangkok, trading clean energy with my neighbours."

    // Palette (mock-ui `SET_DARK` + `SET`).
    private enum S {
        static let bg      = Color(hex: "#0B0712")
        static let surface = Color.white.opacity(0.05)
        static let border  = Color.white.opacity(0.08)
        static let rowSep  = Color.white.opacity(0.07)
        static let text    = Color(hex: "#F4F1FA")
        static let muted   = Color(hex: "#F4F1FA", alpha: 0.5)
        static let faint   = Color(hex: "#F4F1FA", alpha: 0.3)
        static let link    = Color(hex: "#C9B4FF")
        static let violet  = Color(hex: "#9B6BFF")
        static let grad    = LinearGradient(
            colors: [Color(hex: "#A974FF"), Color(hex: "#7C3AED")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            S.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(spacing: 16) {
                        avatar
                        field("person", "Display name", $name)
                        field("at", "Username", $username, prefix: "@")
                        field("envelope", "Email", $email)
                        field("phone", "Phone", $phone)
                        field("text.alignleft", "Bio", $bio, multiline: true)

                        Text("Your role (Prosumer) and verified status come from NDID and can't be edited here.")
                            .font(.system(size: 12)).foregroundStyle(S.faint)
                            .lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8).padding(.bottom, 16)
                }
                saveBar
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onEnded { v in
                    if v.startLocation.x < 24, v.translation.width > 70,
                       abs(v.translation.height) < 60 {
                        onBack()
                    }
                }
        )
        .enableInjection()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(S.link)
                    .frame(width: 38, height: 38)
                    .background(S.surface, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(S.border, lineWidth: 1))
            }
            .accessibilityLabel("Back")

            Text("Edit profile")
                .font(.system(size: 20, weight: .bold)).tracking(-0.3)
                .foregroundStyle(S.text)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8).padding(.bottom, 8)
    }

    // MARK: - Avatar

    private var avatar: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(S.grad)
                    .frame(width: 88, height: 88)
                    .overlay(Text("MC").font(.system(size: 32, weight: .bold)).foregroundStyle(.white))
                    .shadow(color: Color(hex: "#7C3AED", alpha: 0.45), radius: 11, y: 8)
                Circle().fill(S.violet)
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(S.bg, lineWidth: 3))
                    .overlay(Image(systemName: "camera.fill").font(.system(size: 13)).foregroundStyle(.white))
                    .offset(x: 2, y: 2)
            }
            Button("Change photo") {}
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(S.link)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: - Field

    private func field(_ icon: String, _ label: String, _ text: Binding<String>,
                       prefix: String? = nil, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(S.muted)
                .padding(.leading, 2)
            HStack(alignment: multiline ? .top : .center, spacing: 10) {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(S.muted)
                    .frame(width: 20)
                    .padding(.top, multiline ? 2 : 0)
                if let prefix {
                    Text(prefix).font(.system(size: 15.5)).foregroundStyle(S.muted)
                        .padding(.trailing, -4)
                }
                if multiline {
                    TextField("", text: text, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .font(.system(size: 15.5)).foregroundStyle(S.text)
                        .textInputAutocapitalization(.sentences)
                } else {
                    TextField("", text: text)
                        .font(.system(size: 15.5)).foregroundStyle(S.text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, multiline ? 13 : 0)
            .frame(minHeight: multiline ? nil : 50)
            .background(S.surface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(S.border, lineWidth: 1))
        }
    }

    // MARK: - Save

    private var saveBar: some View {
        Button(action: onBack) {
            Text("Save changes")
                .font(.system(size: 16.5, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(S.grad, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: Color(hex: "#7C3AED", alpha: 0.42), radius: 13, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 10).padding(.bottom, 8)
        .background(S.bg)
        .overlay(Rectangle().fill(S.rowSep).frame(height: 1), alignment: .top)
    }
}

#Preview {
    ProfileEditView()
}
