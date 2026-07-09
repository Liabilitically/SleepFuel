import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showResetConfirm = false

    private let unlockDurations = [5, 10, 15, 20]

    var body: some View {
        @Bindable var state = state

        return ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.m) {

                // Sleep
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    SectionHeader(title: "Sleep")
                    VStack(spacing: 0) {
                        navRow(
                            symbol: "moon.fill",
                            title: "Schedule",
                            value: state.sleepWindowLabel
                        ) {
                            state.path.append(.editSchedule)
                        }
                        divider
                        navRow(
                            symbol: "gauge.with.needle.fill",
                            title: "Fuel mode",
                            value: state.fuelMode.title
                        ) {
                            state.path.append(.editSchedule)
                        }
                    }
                    .dsCard()
                }

                // Blocking
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    SectionHeader(title: "Blocking")
                    VStack(spacing: 0) {
                        navRow(
                            symbol: "square.grid.2x2.fill",
                            title: "Blocked apps",
                            value: "\(state.selectedTargets.count) selected"
                        ) {
                            state.path.append(.editApps)
                        }
                        divider
                        navRow(
                            symbol: "qrcode",
                            title: "Anchor mode",
                            value: state.anchorConfigured ? "Configured" : "Not set up"
                        ) {
                            state.path.append(.anchorSetup)
                        }
                        divider
                        HStack {
                            IconBadge(symbol: "exclamationmark.triangle.fill", tint: DS.Palette.textTertiary)
                            Text("Emergency unlock")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(DS.Palette.textPrimary)
                            Spacer()
                            Picker("", selection: $state.emergencyUnlockMinutes) {
                                ForEach(unlockDurations, id: \.self) { minutes in
                                    Text("\(minutes) min").tag(minutes)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(DS.Palette.textSecondary)
                        }
                        .padding(DS.Space.m)
                    }
                    .dsCard()
                }

                // Subscription
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    SectionHeader(title: "Subscription")
                    Button {
                        if !state.isPro {
                            state.showPaywall = true
                        }
                    } label: {
                        HStack(spacing: DS.Space.m) {
                            IconBadge(
                                symbol: "lock.shield.fill",
                                tint: state.isPro ? DS.Palette.accent : DS.Palette.textTertiary
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(state.isPro ? "SleepFuel Pro" : "Free plan")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(DS.Palette.textPrimary)
                                Text(state.isPro
                                     ? "All enforcement features unlocked"
                                     : "Limited to \(AppState.freeSelectionLimit) blocked apps")
                                    .font(.system(size: 12))
                                    .foregroundStyle(DS.Palette.textTertiary)
                            }
                            Spacer()
                            if !state.isPro {
                                Text("Upgrade")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DS.Palette.accent)
                            }
                        }
                        .padding(DS.Space.m)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .dsCard()
                }

                // Privacy
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    SectionHeader(title: "Privacy")
                    Text("SleepFuel is designed to work locally. In the real app, selected apps are handled through Apple's Screen Time APIs. This prototype uses mock data only.")
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                        .padding(DS.Space.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dsCard()
                }

                // Prototype
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    HStack {
                        SectionHeader(title: "Prototype")
                        TagView(text: "Sim")
                    }
                    VStack(spacing: 0) {
                        Toggle(isOn: $state.isPro) {
                            Text("Pro subscription")
                                .font(.system(size: 15))
                                .foregroundStyle(DS.Palette.textPrimary)
                        }
                        .tint(DS.Palette.accent)
                        .padding(DS.Space.m)

                        divider

                        Button {
                            state.screenTimeGranted = true
                            state.notificationsGranted = true
                            state.anchorConfigured = true
                            state.save()
                        } label: {
                            HStack {
                                Text("Grant all mock permissions")
                                    .font(.system(size: 15))
                                    .foregroundStyle(DS.Palette.textPrimary)
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(DS.Palette.textTertiary)
                            }
                            .padding(DS.Space.m)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PressableButtonStyle())

                        divider

                        Button {
                            showResetConfirm = true
                        } label: {
                            HStack {
                                Text("Reset prototype data")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(DS.Palette.destructive)
                                Spacer()
                            }
                            .padding(DS.Space.m)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .dsCard()
                }

                Text("SleepFuel prototype · Mock data only")
                    .font(.system(size: 11))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .padding(.top, DS.Space.s)
            }
            .padding(DS.Space.m)
        }
        .background(DS.Palette.obsidian)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: state.emergencyUnlockMinutes) { state.save() }
        .onChange(of: state.isPro) { state.save() }
        .confirmationDialog(
            "Reset prototype data?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset everything", role: .destructive) {
                withAnimation(DS.motion(reduceMotion)) {
                    state.resetPrototype()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Returns the app to first launch with fresh mock data.")
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(DS.Palette.border)
            .frame(height: DS.hairline)
            .padding(.leading, 68)
    }

    private func navRow(
        symbol: String,
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Space.m) {
                IconBadge(symbol: symbol, tint: DS.Palette.textTertiary)
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
                Text(value)
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.Palette.textTertiary)
            }
            .padding(DS.Space.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
