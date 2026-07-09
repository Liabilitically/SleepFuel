import SwiftUI

struct PermissionSetupView: View {
    let mode: ScreenMode
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if case .onboarding(let onContinue) = mode {
                OnboardingChrome(
                    step: 0,
                    totalSteps: 4,
                    title: "Set up enforcement",
                    subtitle: "SleepFuel needs Screen Time access later to block selected apps. For now, this prototype simulates it.",
                    onContinue: onContinue
                ) {
                    rows
                }
            } else {
                ScrollView {
                    VStack(spacing: DS.Space.m) {
                        Text("SleepFuel needs Screen Time access later to block selected apps. For now, this prototype simulates it.")
                            .font(.system(size: 14))
                            .foregroundStyle(DS.Palette.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        rows
                    }
                    .padding(DS.Space.l)
                }
                .background(DS.Palette.obsidian)
                .navigationTitle("Permissions")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var rows: some View {
        VStack(spacing: 0) {
            permissionRow(
                symbol: "hourglass",
                title: "Screen Time Access",
                detail: "Required to shield your selected apps.",
                isOn: state.screenTimeGranted
            ) {
                state.screenTimeGranted.toggle()
                state.save()
            }
            divider
            permissionRow(
                symbol: "bell.badge.fill",
                title: "Notifications",
                detail: "Bedtime warnings and morning reports.",
                isOn: state.notificationsGranted
            ) {
                state.notificationsGranted.toggle()
                state.save()
            }
            divider
            permissionRow(
                symbol: "qrcode",
                title: "Anchor Mode",
                detail: "Physical checkpoint away from your bed.",
                isOn: state.anchorConfigured
            ) {
                state.anchorConfigured.toggle()
                state.save()
            }
        }
        .dsCard()
    }

    private var divider: some View {
        Rectangle()
            .fill(DS.Palette.border)
            .frame(height: DS.hairline)
            .padding(.leading, 68)
    }

    private func permissionRow(
        symbol: String,
        title: String,
        detail: String,
        isOn: Bool,
        toggle: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DS.Space.m) {
            IconBadge(symbol: symbol, tint: isOn ? DS.Palette.accent : DS.Palette.textTertiary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Palette.textPrimary)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Palette.textTertiary)
            }

            Spacer()

            Button {
                withAnimation(DS.motion(reduceMotion)) {
                    toggle()
                }
            } label: {
                Text(isOn ? "Enabled" : "Enable")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isOn ? DS.Palette.success : DS.Palette.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DS.Palette.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                            .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
                    )
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(DS.Space.m)
    }
}
