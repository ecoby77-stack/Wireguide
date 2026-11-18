# WireGuide

California electrician reference. Single-screen SwiftUI app for wire size and ampacity (iOS 17+, dark mode).

## Contents

- `WireGuide/WireData.swift` — hardcoded copper THHN ampacity (NEC 2023 Table 310.16) and quick-match list
- `WireGuide/ContentView.swift` — ampacity table, quick match, and disclaimer
- `WireGuide/WireGuideApp.swift` — app entry, forced dark mode
- `project.yml` — XcodeGen project (bundle id `com.wireguide.app`)

## Build (macOS)

```bash
brew install xcodegen
xcodegen generate
open WireGuide.xcodeproj
```

Or build from the CLI:

```bash
xcodegen generate
xcodebuild -project WireGuide.xcodeproj -scheme WireGuide \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## CI

`.github/workflows/simulator.yml` runs on `macos-latest` for pull requests, pushes to `main`/`master`, and `workflow_dispatch`. It generates the Xcode project with XcodeGen, builds for an available iOS 17+ iPhone simulator, launches the app, and uploads `screenshot.png` as the `simulator-screenshot` artifact.

## Disclaimer

For reference only. Verify with the 2025 CEC and your local building department.
