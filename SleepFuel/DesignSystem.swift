import SwiftUI
import UIKit

// MARK: - Design tokens

enum DS {

    enum Palette {
        static let obsidian = Color(hex: 0x0B0B0C)
        static let surface = Color(hex: 0x161618)
        static let elevated = Color(hex: 0x1E1E21)
        static let border = Color(hex: 0x242426)
        static let accent = Color(hex: 0xFF5722)
        static let textPrimary = Color(hex: 0xF4F4F5)
        static let textSecondary = Color(hex: 0xF4F4F5).opacity(0.70)
        static let textTertiary = Color(hex: 0xF4F4F5).opacity(0.45)
        static let success = Color(uiColor: .systemGreen)
        static let destructive = Color(uiColor: .systemRed)
    }

    enum Space {
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 8
    }

    /// One physical pixel.
    static let hairline: CGFloat = 1.0 / UIScreen.main.scale

    /// The only spring used anywhere in the app.
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)

    /// Spring that respects Reduce Motion.
    static func motion(_ reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : spring
    }
}

// MARK: - Color hex support

extension Color {
    init(hex: UInt) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Card treatment

struct CardBackground: ViewModifier {
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(elevated ? DS.Palette.elevated : DS.Palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
            )
    }
}

extension View {
    func dsCard(elevated: Bool = false) -> some View {
        modifier(CardBackground(elevated: elevated))
    }
}
