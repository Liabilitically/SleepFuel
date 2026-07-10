import SwiftUI

// MARK: - Buttons

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isEnabled ? .white : DS.Palette.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? DS.Palette.accent : DS.Palette.elevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        }
        .disabled(!isEnabled)
        .buttonStyle(PressableButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(DS.Palette.elevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
                )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(DS.motion(reduceMotion), value: configuration.isPressed)
    }
}

// MARK: - Tags

struct TagView: View {
    let text: String
    var color: Color = DS.Palette.textSecondary

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, DS.Space.s)
            .padding(.vertical, 4)
            .background(DS.Palette.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous)
                    .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
            )
    }
}

struct ProTag: View {
    var body: some View {
        Text("PRO")
            .font(.system(size: 10, weight: .bold))
            .tracking(1.0)
            .foregroundStyle(DS.Palette.accent)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous)
                    .strokeBorder(DS.Palette.accent.opacity(0.6), lineWidth: DS.hairline)
            )
    }
}

// MARK: - Checkbox

struct CheckBox: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous)
                .fill(isOn ? DS.Palette.accent : DS.Palette.elevated)
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 24, height: 24)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous)
                .strokeBorder(isOn ? DS.Palette.accent : DS.Palette.border, lineWidth: 1)
        )
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(DS.Palette.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Stat tile

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(DS.Palette.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(DS.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }
}

// MARK: - Icon badge (app icons in lists)

struct IconBadge: View {
    let symbol: String
    var size: CGFloat = 36
    var tint: Color = DS.Palette.textSecondary

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(DS.Palette.elevated)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.small, style: .continuous)
                    .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
            )
    }
}

// MARK: - Status row (label + value)

struct StatusRow: View {
    let label: String
    let value: String
    var valueColor: Color = DS.Palette.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(valueColor)
                .monospacedDigit()
        }
    }
}

// MARK: - Hold to confirm

struct HoldToConfirmButton: View {
    let title: String
    var holdDuration: Double = 1.6
    let action: () -> Void

    @State private var progress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                .fill(DS.Palette.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .strokeBorder(DS.Palette.accent.opacity(0.5), lineWidth: DS.hairline)
                )

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .fill(DS.Palette.accent)
                    .frame(width: geo.size.width * progress)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(height: 52)
        .contentShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        .onLongPressGesture(minimumDuration: holdDuration, maximumDistance: 60) {
            progress = 0
            action()
        } onPressingChanged: { pressing in
            if pressing {
                // Progress fill communicates hold state; it stays even with Reduce Motion.
                withAnimation(.linear(duration: holdDuration)) {
                    progress = 1
                }
            } else {
                withAnimation(DS.motion(reduceMotion)) {
                    progress = 0
                }
            }
        }
        .accessibilityHint("Press and hold to confirm")
    }
}

// MARK: - Onboarding step header

struct OnboardingStepHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(title)
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, DS.Space.l)
    }
}
