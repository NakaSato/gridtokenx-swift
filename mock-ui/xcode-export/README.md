# GridTokenX — Xcode handoff package

iOS design export for the GridTokenX P2P energy-trading app. Dark + purple system; green/red reserved for buy/sell and gains/losses.

## What's in here

```
xcode-export/
├─ GTXDesignTokens.swift   → colors, gradient, spacing, radii, type, button style (SwiftUI)
├─ Screens/                → 17 reference screens, 402×874 (design points), PNG
└─ README.md
```

> ⚠️ These are **design references**, not auto-generated SwiftUI. Rebuild each screen
> natively in SwiftUI/UIKit using `GTXDesignTokens.swift` for exact colors/spacing,
> and the PNGs as the visual spec. The live, interactive HTML prototype
> (`GridTokenX Signup.html`) is the source of truth for behavior.

## Using the tokens

1. Drag `GTXDesignTokens.swift` into your project.
2. Reference anywhere:

```swift
ZStack {
    GTXColor.bg.ignoresSafeArea()
    VStack(spacing: GTXSpacing.gap) {
        Text("Trade clean energy,\npeer to peer.")
            .font(GTXFont.display)
            .foregroundStyle(GTXColor.text)
        Button("Create account") { }
            .buttonStyle(GTXPrimaryButtonStyle())
    }
    .padding(GTXSpacing.screenPadding)
}
```

3. Gradient: `LinearGradient.gtxBrand` (135°, #A974FF → #7C3AED).

## Asset catalog colors (hex)

| Token        | Hex / value            | Use |
|--------------|------------------------|-----|
| bg           | `#0B0712`              | App background |
| surface      | white @ 5%             | Cards, fields |
| border       | white @ 9%             | Hairlines, card borders |
| text         | `#F4F1FA`              | Primary text |
| muted        | `#F4F1FA` @ 54%        | Secondary text |
| violet       | `#9B6BFF`              | Primary accent |
| violetSoft   | `#C9B4FF`              | Links, highlights |
| violetDeep   | `#7C3AED`              | Gradient end / shadow |
| buy / up     | `#2FD08A`              | Buy, gains (only) |
| sell / down  | `#FF5C6C`              | Sell, losses, destructive (only) |
| warning      | `#FFD166`              | Alerts / partial states |

## Screen inventory

**Onboarding**
1. Welcome · 2. Create account · 3. Verify email · 4. Profile · 5. Success

**App**
6. Dashboard (trade / market / grid) · 6b. Dashboard — Easy view (accessible)
7. Wallet · 8. Settings (dark + light) · 9. Deposit · 10. Withdraw
11. Register meter (barcode scan + activation code) · 12. DCA strategy
13. Verify account (NDID) · 14. NDID verified identity
15. Notifications · 16. Order history

## Specs

- **Canvas:** 402 × 874 pt (designed at iPhone logical width). Re-flow to 393/390 as needed.
- **Type:** system **SF Pro Text/Display**; figures in **SF Mono** (`.monospaced`).
- **Currency:** Thai Baht (฿ / THB).
- **Status bar / home indicator:** drawn by iOS — not included in the screen art.
- **Touch targets:** ≥ 44 pt.

## Behavior reference

Interactions (tab switches, buy/sell toggles, amount keypad, theme switch, barcode
scan → activation code, NDID select → pending → verified) are all live in the HTML
prototype. Open `GridTokenX Signup.html` to step through each on the canvas.
