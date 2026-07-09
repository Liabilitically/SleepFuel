import SwiftUI

struct MockAnchorSetupView: View {
    let mode: ScreenMode
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scanning = false
    @State private var scanned = false
    @State private var placedAway = false

    var body: some View {
        Group {
            if case .onboarding(let onContinue) = mode {
                OnboardingChrome(
                    step: 3,
                    totalSteps: 4,
                    title: "Anchor mode",
                    subtitle: "Your anchor is a physical checkpoint placed away from your bed. Scanning it each night proves your phone ended up out of reach.",
                    continueTitle: "Finish setup",
                    continueEnabled: scanned && placedAway,
                    onContinue: {
                        state.anchorConfigured = true
                        state.save()
                        onContinue()
                    }
                ) {
                    ScrollView(showsIndicators: false) {
                        anchorContent
                    }
                }
            } else {
                ScrollView(showsIndicators: false) {
                    anchorContent
                        .padding(DS.Space.l)
                }
                .background(DS.Palette.obsidian)
                .navigationTitle("Anchor Mode")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            if state.anchorConfigured {
                scanned = true
                placedAway = true
            }
        }
    }

    private var anchorContent: some View {
        VStack(spacing: DS.Space.m) {
            // QR card
            VStack(spacing: DS.Space.m) {
                MockQRView(scanned: scanned)
                    .frame(width: 160, height: 160)

                Text(scanned ? "Anchor linked" : "SleepFuel Anchor")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(scanned ? DS.Palette.success : DS.Palette.textPrimary)

                Text(scanned
                     ? "This anchor is now bound to your sleep window."
                     : "Print or display this code where your phone should sleep — a hallway, kitchen, or desk.")
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !scanned {
                    Button {
                        startScan()
                    } label: {
                        HStack(spacing: DS.Space.s) {
                            if scanning {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.white)
                            } else {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            Text(scanning ? "Scanning…" : "Scan anchor")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(DS.Palette.accent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                    }
                    .disabled(scanning)
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(DS.Space.l)
            .frame(maxWidth: .infinity)
            .dsCard()

            // How it works
            VStack(alignment: .leading, spacing: DS.Space.m) {
                SectionHeader(title: "How it works")
                anchorPoint(symbol: "1.circle.fill", text: "Place the anchor where your phone should spend the night.")
                anchorPoint(symbol: "2.circle.fill", text: "At bedtime, scan it to arm the session and dock your phone there.")
                anchorPoint(symbol: "3.circle.fill", text: "Skipping the anchor costs 30 minutes of protected sleep.")
            }
            .padding(DS.Space.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsCard()

            // Placement confirmation
            Button {
                withAnimation(DS.motion(reduceMotion)) {
                    placedAway.toggle()
                }
                if case .standalone = mode {
                    state.anchorConfigured = scanned && placedAway
                    state.save()
                }
            } label: {
                HStack(spacing: DS.Space.m) {
                    Image(systemName: placedAway ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(placedAway ? DS.Palette.accent : DS.Palette.textTertiary)
                    Text("I placed my anchor away from bed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Spacer()
                }
                .padding(DS.Space.m)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .dsCard()
        }
    }

    private func anchorPoint(symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Space.m) {
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundStyle(DS.Palette.accent)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(DS.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func startScan() {
        scanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(DS.motion(reduceMotion)) {
                scanning = false
                scanned = true
            }
            if case .standalone = mode {
                state.anchorConfigured = scanned && placedAway
                state.save()
            }
        }
    }
}

// MARK: - Deterministic mock QR pattern

struct MockQRView: View {
    let scanned: Bool
    private let modules = 21

    var body: some View {
        Canvas { context, size in
            let cell = size.width / CGFloat(modules)
            let ink = scanned ? DS.Palette.success : DS.Palette.textPrimary

            for row in 0..<modules {
                for col in 0..<modules {
                    guard isFilled(row: row, col: col) else { continue }
                    let rect = CGRect(
                        x: CGFloat(col) * cell,
                        y: CGFloat(row) * cell,
                        width: cell,
                        height: cell
                    ).insetBy(dx: cell * 0.08, dy: cell * 0.08)
                    context.fill(Path(rect), with: .color(ink))
                }
            }
        }
        .padding(DS.Space.m)
        .background(DS.Palette.obsidian)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                .strokeBorder(scanned ? DS.Palette.success.opacity(0.5) : DS.Palette.border, lineWidth: DS.hairline)
        )
        .accessibilityLabel("SleepFuel anchor code")
    }

    /// Stable pseudo-QR: three finder squares plus a deterministic data pattern.
    private func isFilled(row: Int, col: Int) -> Bool {
        if let finder = finderModule(row: row, col: col) {
            return finder
        }
        let hash = (row &* 31 &+ col &* 17 &+ row &* col &* 7) % 5
        return hash == 0 || hash == 3
    }

    private func finderModule(row: Int, col: Int) -> Bool? {
        let anchors = [(0, 0), (0, modules - 7), (modules - 7, 0)]
        for (ar, ac) in anchors {
            let r = row - ar
            let c = col - ac
            if (0..<7).contains(r) && (0..<7).contains(c) {
                let ring = min(min(r, c), min(6 - r, 6 - c))
                return ring == 0 || ring >= 2
            }
        }
        return nil
    }
}
