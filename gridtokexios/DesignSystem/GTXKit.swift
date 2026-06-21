//
//  GTXKit.swift
//  gridtokexios
//
//  Standard component kit (atoms/molecules) built on GTX* tokens.
//  Phase 1: card container, list row, icon disc. Extend per migration.
//

import SwiftUI

// MARK: - Card container

/// Standard raised card: surface fill + hairline border on a continuous rounded rect.
/// Replaces the `.background(surface, in: RoundedRectangle) + .overlay(stroke)` boilerplate.
struct GTXCardModifier: ViewModifier {
    var radius: CGFloat = GTXRadius.card
    var fill: Color = GTXColor.surface
    var stroke: Color = GTXColor.border
    var padding: CGFloat? = GTXSpacing.gap

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
    }
}

extension View {
    /// Wrap content in the standard GTX card. Pass `padding: nil` to manage padding yourself.
    func gtxCard(radius: CGFloat = GTXRadius.card,
                 fill: Color = GTXColor.surface,
                 stroke: Color = GTXColor.border,
                 padding: CGFloat? = GTXSpacing.gap) -> some View {
        modifier(GTXCardModifier(radius: radius, fill: fill, stroke: stroke, padding: padding))
    }
}

// MARK: - Icon disc

/// Square rounded tile holding an SF Symbol (or any glyph). Used for list/leading icons.
struct GTXIconDisc: View {
    var systemName: String
    var size: CGFloat = 40
    var radius: CGFloat = 12
    var foreground: Color = GTXColor.violetSoft
    var background: Color = GTXColor.surface
    var glyphScale: CGFloat = 0.42   // glyph point size as fraction of tile

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * glyphScale, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Variant that shows text (e.g. token symbol / initials) instead of a symbol.
struct GTXTextDisc: View {
    var text: String
    var size: CGFloat = 40
    var radius: CGFloat = 12
    var foreground: Color = .white
    var background: AnyShapeStyle = AnyShapeStyle(LinearGradient.gtxBrand)

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - List row

/// Standard list item: leading view · title/subtitle · trailing view, with optional hairline.
/// Covers holdingRow / txnRow / settings rows / detailRow.
struct GTXListRow<Leading: View, Trailing: View>: View {
    var title: String
    var subtitle: String? = nil
    var showsSeparator: Bool = true
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    init(title: String,
         subtitle: String? = nil,
         showsSeparator: Bool = true,
         @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
         @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.showsSeparator = showsSeparator
        self.leading = leading
        self.trailing = trailing
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                leading()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(GTXFont.bodyBold)
                        .foregroundStyle(GTXColor.text)
                    if let subtitle {
                        Text(subtitle)
                            .font(GTXFont.caption)
                            .foregroundStyle(GTXColor.muted)
                    }
                }
                Spacer(minLength: 8)
                trailing()
            }
            .padding(.horizontal, GTXSpacing.gap)
            .padding(.vertical, 14)

            if showsSeparator {
                Rectangle()
                    .fill(Color.white.opacity(GTXOpacity.hairline))
                    .frame(height: 1)
                    .padding(.leading, GTXSpacing.gap)
            }
        }
    }
}

// MARK: - Section header

/// Uppercase muted section label.
struct GTXSectionHeader: View {
    var text: String
    var body: some View {
        Text(text.uppercased())
            .font(GTXFont.section)
            .tracking(0.5)
            .foregroundStyle(GTXColor.muted)
    }
}

// MARK: - Universal content constraint

extension View {
    /// Center & cap content width on regular (iPad) size class; full-bleed on compact (iPhone).
    func gtxUniversalWidth(_ maxWidth: CGFloat = GTXLayout.contentMaxWidth) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
