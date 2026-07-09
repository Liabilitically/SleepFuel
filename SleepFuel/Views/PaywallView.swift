import SwiftUI

struct PaywallView: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Plan {
        case monthly
        case yearly
    }

    @State private var plan: Plan = .yearly
    @State private var purchased = false

    private let benefits: [(String, String)] = [
        ("square.grid.2x2.fill", "Unlimited blocked apps"),
        ("flame.fill", "Strict mode"),
        ("qrcode", "Anchor mode"),
        ("exclamationmark.triangle.fill", "Emergency unlock controls"),
        ("chart.bar.fill", "Weekly history"),
        ("lock.shield.fill", "Premium enforcement screens")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DS.Space.m) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.Palette.textTertiary)
                            .frame(width: 32, height: 32)
                            .background(DS.Palette.elevated)
                            .clipShape(Circle())
                    }
                }

                if purchased {
                    successContent
                } else {
                    purchaseContent
                }
            }
            .padding(DS.Space.l)
        }
        .background(DS.Palette.obsidian.ignoresSafeArea())
        .presentationDetents([.large])
    }

    // MARK: - Purchase state

    private var purchaseContent: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            Text("Make SleepFuel strict enough to actually work.")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DS.Space.m) {
                ForEach(benefits, id: \.1) { symbol, text in
                    HStack(spacing: DS.Space.m) {
                        Image(systemName: symbol)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(DS.Palette.accent)
                            .frame(width: 24)
                        Text(text)
                            .font(.system(size: 15))
                            .foregroundStyle(DS.Palette.textPrimary)
                    }
                }
            }
            .padding(DS.Space.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsCard()

            VStack(spacing: DS.Space.s) {
                planCard(
                    .yearly,
                    title: "Yearly",
                    price: "$39.99/yr",
                    detail: "$3.33 per month",
                    tag: "Best value"
                )
                planCard(
                    .monthly,
                    title: "Monthly",
                    price: "$6.99/mo",
                    detail: "Cancel anytime",
                    tag: nil
                )
            }

            PrimaryButton(title: "Start Pro") {
                withAnimation(DS.motion(reduceMotion)) {
                    state.startPro()
                    purchased = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    dismiss()
                }
            }

            HStack {
                Button("Restore purchases") {
                    dismiss()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DS.Palette.textTertiary)

                Spacer()

                Button("Continue free") {
                    dismiss()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DS.Palette.textTertiary)
            }
            .padding(.horizontal, DS.Space.s)

            Text("Prototype only — no payment is processed.")
                .font(.system(size: 11))
                .foregroundStyle(DS.Palette.textTertiary)
                .frame(maxWidth: .infinity)
        }
    }

    private var successContent: some View {
        VStack(spacing: DS.Space.m) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(DS.Palette.success)

            Text("You're Pro.")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Unlimited apps, strict mode, and anchor enforcement are unlocked.")
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Space.xl * 2)
    }

    // MARK: - Plan card

    private func planCard(_ value: Plan, title: String, price: String, detail: String, tag: String?) -> some View {
        let isSelected = plan == value

        return Button {
            withAnimation(DS.motion(reduceMotion)) {
                plan = value
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? DS.Palette.accent : DS.Palette.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DS.Space.s) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DS.Palette.textPrimary)
                        if let tag {
                            TagView(text: tag, color: DS.Palette.accent)
                        }
                    }
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()

                Text(price)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
                    .monospacedDigit()
            }
            .padding(DS.Space.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .background(isSelected ? DS.Palette.elevated : DS.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .strokeBorder(isSelected ? DS.Palette.accent : DS.Palette.border,
                              lineWidth: isSelected ? 1 : DS.hairline)
        )
    }
}
