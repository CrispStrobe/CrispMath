# CrispCalc — distribution prep

Status of getting CrispCalc onto the App Store, Mac App Store, and Google
Play. Written 2026-07-04 from a config audit. The engine is competitive;
this is the remaining gate to reaching users (PLAN.md Tier 1 ship blocker).

## Account decision (do this first)

Register the **Gewerbeanmeldung before the Apple Developer account.**
Rationale: it's cheap (~€20–60) and often same-day, it unblocks BOTH Apple
account types, and it removes tax-timing ambiguity.

- **Apple account type — the consequential choice.** *Individual* (seller =
  your personal legal name, no D-U-N-S needed) vs. *Organization* (needs a
  D-U-N-S number → a registered entity). Moving apps from an individual to
  an organization account later is painful, so decide deliberately. If you
  want a business name from day one, do the Gewerbe/entity first, then
  enroll as an organization.
- **Google Play**: one-time $25, individual or business.
- **Apple Developer Program**: $99/year; enrollment identity check can take
  several days, so start it in parallel with the Gewerbe.
- Confirm the Kleinunternehmer (§19 UStG) vs. regular-VAT choice with a
  Steuerberater — it affects App Store pricing.

## Blockers (must fix before any store submission)

1. **Placeholder bundle identifiers — `com.example.crispCalc`** (iOS main +
   RunnerTests, and macOS). The App Store rejects `com.example.*`. Pick a
   real reverse-domain and set it everywhere. **Recommended:**
   `be.crispstro.crispCalc` (matches the existing Android applicationId
   `be.crispstro.crisp_calc`). This is IDENTITY-SENSITIVE and permanent
   once published — left for you to confirm the domain, then set in:
   - `ios/Runner.xcodeproj/project.pbxproj` (Runner + RunnerTests targets)
   - `macos/Runner.xcodeproj/project.pbxproj`
   - keep Android's `be.crispstro.crisp_calc` as-is (already real).

2. **Android release build is signed with the DEBUG keystore**
   (`android/app/build.gradle.kts:37` — `signingConfigs.getByName("debug")`
   under `buildTypes.release`, with a `// TODO` already noting it). Play
   rejects debug-signed AABs. Needs: generate an upload keystore
   (`keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048
   -validity 10000 -alias upload`), add a `key.properties` (git-ignored),
   and a real `release` signing config. Then enroll in Play App Signing.
   Left for you — the keystore is a secret you must generate and hold.

3. **macOS sandbox was missing `network.client`** — FIXED this session in
   both `Release.entitlements` and `DebugProfile.entitlements`. Without it,
   a sandboxed Mac App Store build would block every outbound request
   (CrispAssist AI, cloud OCR, crash reporting). Also review whether the
   OCR model DOWNLOAD-to-disk paths need `network.client` (they do — now
   covered) and whether any feature needs additional sandbox exceptions
   (e.g. user-selected file read for image OCR — currently the app uses
   the image_picker plugin, which is sandbox-friendly).

## Non-blocking cleanups (done this session)

- **Android display label** `crisp_calc` → `CrispCalc`
  (`AndroidManifest.xml`).

## Recommended follow-ups (not blocking, low risk)

- **Wire iOS/macOS `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` to the
  Flutter build variables** (`$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`)
  so the store version tracks `pubspec.yaml` (currently `0.5.0+1`) instead
  of the hardcoded `1.0` / `1`. Bump pubspec to a real launch version
  (e.g. `1.0.0+1`) at submission.
- **iOS `CFBundleName`** is `crisp_calc` (internal); `CFBundleDisplayName`
  is already `CrispCalc` (what users see), so this is cosmetic.

## What exists already

- `.github/workflows/release.yml` builds UNSIGNED release artifacts for
  every platform on a `v*` tag and attaches them to a GitHub Release. Good
  foundation, but it is NOT store submission — it produces downloadable
  binaries. Store pipelines (fastlane / Transporter / Play Console upload)
  are additive on top.
- CI builds all 7 platforms green on every push.

## Signing / notarization pipeline (draft — needs your credentials)

Once the account + bundle IDs + keystore exist, the store pipeline adds:

- **iOS/macOS**: import the Apple distribution cert + provisioning profile
  as CI secrets; `flutter build ipa` / `flutter build macos`; `xcrun
  notarytool submit … --wait` + `xcrun stapler staple` for macOS; upload
  via `xcrun altool` / Transporter or fastlane `deliver`.
- **Android**: decode the keystore from a base64 CI secret, write
  `key.properties`, `flutter build appbundle --release`, upload via
  fastlane `supply` or the Play Developer API.
- All credentials (certs, keystore, API keys) as encrypted CI secrets —
  none committed.

## Store listing assets (ready to generate)

- **Screenshots**: the verify harness already produces real app
  screenshots (used this session for the plot modes). Can generate the
  full required set (per-device sizes) for the CAS features, graphing,
  notepad, and stats on request.
- **Copy**: app name (CrispCalc), subtitle, description, keywords, and the
  privacy nutrition labels (network use for CrispAssist/OCR/crash reports,
  no tracking) — drafts on request.

## Ordered next steps

1. Gewerbeanmeldung.
2. Decide Apple account type (individual vs. organization); enroll (+ Play).
3. Set the real bundle identifier (blocker #1).
4. Generate the Android upload keystore + release signing config (blocker #2).
5. Bump `pubspec.yaml` to the launch version; wire the iOS/macOS version vars.
6. Build the store signing/notarization pipeline (draft above) with your
   credentials as CI secrets.
7. Generate screenshots + write store copy.
