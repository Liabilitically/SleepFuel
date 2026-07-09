# SleepFuel — Frontend Prototype

Premium iOS self-control app prototype: **tomorrow's entertainment apps run on tonight's protected sleep.** Frontend-only — every feature is simulated with local mock state. No Screen Time APIs, StoreKit, HealthKit, camera, notifications, or backend.

## Opening the project (macOS required)

**Option A — XcodeGen (fastest):**

```bash
brew install xcodegen   # if needed
cd sleepfuel
xcodegen generate
open SleepFuel.xcodeproj
```

**Option B — manual (no tooling):**

1. In Xcode: File → New → Project → iOS App, name it `SleepFuel`, interface SwiftUI, language Swift, iOS 17 deployment target.
2. Delete the generated `ContentView.swift` and `SleepFuelApp.swift`.
3. Drag the entire `SleepFuel/` folder from this repo into the project navigator (check "Copy items if needed" is off if it's already in place, and add to the SleepFuel target).
4. Build and run on any iOS 17+ simulator.

There are no external packages, no entitlements, and no Info.plist keys beyond the generated defaults.

## Demo path (good for screen recording)

1. Launch → onboarding (4 pages) → permissions → app selection → schedule → anchor scan.
2. Dashboard → **Arm tonight** → **Start sleep session**.
3. In the active session, use the prototype controls: **+1 hour** a few times, then **Unlock** to walk the emergency-unlock friction flow, then **Complete night**.
4. Morning report appears with grade, penalty breakdown, and takeaway.
5. Check **History** (chart rows) and **Settings → Reset prototype data** to run it again fresh.
6. Tap any Pro-gated element (4th app selection, Strict mode, upsell card) to see the paywall; **Start Pro** simulates a purchase.

## What is mock

Everything interactive: permissions, app blocking, QR anchor scanning, session timing (simulated hours), fuel math (real formula, mock inputs), subscription, and history seed data. State persists between launches via `UserDefaults` and resets from Settings.
