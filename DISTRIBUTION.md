# CrispMath — distribution prep

Status of getting CrispMath onto the App Store, Mac App Store, and Google
Play. Updated 2026-07-10 after the full rename and app-store readiness pass.

## Account status

- **Apple Developer Program**: enrolled as individual, Team ID `N9XSJ4M3GT`,
  API key generated and working (used for CrispChess + CrispSudoku).
- **Google Play**: one-time $25, individual or business — not yet enrolled.

## Completed (2026-07-10)

1. **App renamed CrispCalc → CrispMath** — 189 files, GitHub repo, Vercel
   project, all CI workflows, env vars (`CRISPMATH_*`).
2. **Bundle IDs fixed** — `com.crispstrobe.crispmath` (iOS/macOS),
   `com.crispstrobe.crisp_math` (Android/Linux).
3. **Version bumped** — `1.0.0+1` in pubspec.yaml.
4. **iOS MARKETING_VERSION wired** — tracks `$(FLUTTER_BUILD_NAME)` from
   pubspec, no more hardcoded `1.0`.
5. **PrivacyInfo.xcprivacy** created and wired into iOS Xcode project
   (UserDefaults + FileTimestamp API declarations).
6. **ITSAppUsesNonExemptEncryption = false** in Info.plist — eliminates
   TestFlight export compliance prompt.
7. **Android release signing** wired in `build.gradle.kts` — reads
   `key.properties` when present, falls back to debug signing otherwise.
   `key.properties`, `*.jks`, `*.keystore` added to `.gitignore`.
8. **Privacy policy** published at `crisp-math.vercel.app/privacy.html`,
   linked from About screen.
9. **LGPL compliance** — written offer for object files added to
   `assets/licenses/SYMENGINE_STACK.txt` (FLINT/GMP/MPFR/MPC).
10. **AGPL §7 marketplace exception** — already in LICENSE file, documented
    in SYMENGINE_STACK.txt. App Store distribution is covered.
11. **CrispEmbed bumped** to v0.14.0 (robust deskew, LoRA hot-swap,
    Unlimited-OCR engine, WASM OCR pipeline).
12. **Store listing copy** drafted in `STORE_LISTING.md` (description,
    keywords, subtitle, promo text, review notes).
13. **App icons** verified present for all platforms (custom integral+sigma
    design on dark blue).
14. **macOS sandbox `network.client`** entitlement — already fixed in prior
    session.
15. **Vercel secret** `VERCEL_PROJECT_ID` updated for the renamed project.
16. **All CI green** — 7 workflows (CI, Web, iOS, Android, macOS, Linux,
    Windows) passing after rename.

## Remaining — on the Mac

These require the Mac with Xcode + the `.p8` API key:

1. **Register bundle ID** `com.crispstrobe.crispmath` via App Store Connect
   API (`POST /v1/bundleIds`). Use the `gen_token.py` pattern from
   `appstore.md` Step 2.

2. **Create app record** in App Store Connect — browser-only (Step 3).
   Name: CrispMath, Bundle ID from step 1, SKU: `crispmath`.

3. **Build + archive + upload** iOS IPA (Steps 5-7 in `appstore.md`).
   The `DEVELOPMENT_TEAM = N9XSJ4M3GT` is already in the pbxproj.

4. **Screenshots** via iOS Simulator (Step 11 in `appstore.md`). Need
   iPhone 6.7"/6.9" + iPad 13" at minimum.

5. **App Privacy nutrition label** — browser-only. Should be "Data Not
   Collected" since the app collects nothing.

6. **Fill store listing fields** via API using copy from `STORE_LISTING.md`
   (description, keywords, subtitle, privacy URL, support URL, category,
   age rating, pricing = free).

7. **Submit for Review** — human decision.

## Remaining — Android (Play Store)

1. Enroll in Google Play Developer Program ($25).
2. Generate upload keystore:
   ```bash
   keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias upload
   ```
3. Create `android/key.properties` (git-ignored):
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=../upload.jks
   ```
4. `flutter build appbundle --release` → upload to Play Console.

## What exists already

- `.github/workflows/release.yml` builds UNSIGNED release artifacts for
  every platform on a `v*` tag and attaches them to a GitHub Release.
- CI builds all 7 platforms green on every push.
- `appstore.md` (parent dir) has the full iOS submission playbook with all
  gotchas from CrispChess + CrispSudoku.
