import SwiftUI

/// The block screen. On a real device every non-essential app shows this
/// once today's time runs out. The only way through is to declare an
/// emergency and retype a paragraph exactly — no autocorrect.
struct BlockedView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showEmergency = false
    @State private var paragraph = emergencyParagraphs[0]
    @State private var typed = ""

    private var typedMatches: Bool {
        typed.trimmingCharacters(in: .whitespacesAndNewlines)
            == paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            if showEmergency {
                emergencyFlow
            } else {
                blockedScreen
            }
        }
        .animation(DS.motion(reduceMotion), value: showEmergency)
        .onAppear {
            paragraph = emergencyParagraphs.randomElement() ?? emergencyParagraphs[0]
        }
    }

    private var blockedScreen: some View {
        VStack(spacing: DS.Space.l) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(DS.Palette.accent)

            Text("Time's up for today")
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Your apps are locked until tomorrow.\nSleep well tonight to earn more time.")
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            SecondaryButton(title: "This is an emergency") {
                typed = ""
                showEmergency = true
            }

            Text("Phone, Settings, and SleepFuel stay open.")
                .font(.system(size: 12))
                .foregroundStyle(DS.Palette.textTertiary)
        }
        .padding(DS.Space.l)
        .transition(.opacity)
    }

    private var emergencyFlow: some View {
        VStack(spacing: DS.Space.l) {
            HStack {
                Button {
                    showEmergency = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DS.Palette.textSecondary)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.l) {
                    Text("Type this to unlock")
                        .font(DS.Fonts.title)
                        .foregroundStyle(DS.Palette.textPrimary)

                    Text("Every letter must match. No autocorrect.")
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)

                    Text(paragraph)
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .lineSpacing(4)
                        .padding(DS.Space.m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dsCard()

                    TextField("Type here…", text: $typed, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .lineLimit(5...10)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding(DS.Space.m)
                        .background(DS.Palette.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                                .strokeBorder(
                                    typedMatches ? DS.Palette.success : DS.Palette.border,
                                    lineWidth: 1
                                )
                        )
                }
            }

            PrimaryButton(title: "Unlock 15 minutes", isEnabled: typedMatches) {
                state.emergencyUnlock()
                showEmergency = false
            }
        }
        .padding(DS.Space.l)
        .transition(.opacity)
    }
}
