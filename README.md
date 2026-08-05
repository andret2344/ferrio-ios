# Ferrio (iOS)

iOS app for browsing unusual holidays — "National Pizza Day" and friends. Browse a month calendar,
open a holiday for its description, share it as a rendered card, report data errors and suggest
missing holidays. Ships with a WidgetKit widget and an iMessage extension.

Backend: `https://api.ferrio.app/v3`. The app stores nothing on the device.

## Requirements

- Xcode 26 (iOS 26 SDK)
- iOS 26.0 deployment target, Swift 5.0 language mode
- Dependencies via Swift Package Manager, resolved on first build — no CocoaPods, no Carthage

## Getting started

```sh
git clone git@github.com:andret2344/ferrio-ios.git
cd ferrio-ios
```

**Then add the Firebase config.** `Ferrio/Resources/GoogleService-Info.plist` is intentionally not
in the repository, but the project references it and the build copies it into the app bundle.
Download it from the Firebase console (project settings » iOS app) and drop it at that exact path.
Without it the build fails on a missing input file, which does not look like a configuration
problem.

```sh
xcodebuild -scheme Ferrio -destination 'generic/platform=iOS Simulator' build
```

The generic destination is deliberate: named simulators differ between machines, and
`-showdestinations` sometimes lists only a placeholder even while a device is booted.

## Tests

```sh
xcodebuild -scheme Ferrio -destination 'id=<booted-simulator-udid>' test
```

Unlike a build, the test action needs a real simulator. Get a UDID with
`xcrun simctl list devices available`.

`FerrioTests` uses Swift Testing (`@Test` / `#expect`) and covers the pure logic: month-grid
padding in `CalendarService`, and DTO decoding, grouping and filtering in `HolidayRepository`.
`FerrioUITests` is still an Xcode template stub.

## Targets

| Target | Bundle id | Notes |
| --- | --- | --- |
| `Ferrio` | `eu.andret.uhc` | the app |
| `FerrioWidgetExtension` | `eu.andret.uhc.widget` | WidgetKit, shares 15 sources with the app |
| `FerrioMessagesExtension` | `eu.andret.uhc.FerrioMessagesExtension` | self-contained, shares no code |
| `FerrioTests` / `FerrioUITests` | — | unit tests / template stub |

Every top-level folder is a file-system-synchronized group, so a new `.swift` file needs no
`project.pbxproj` edit. A file the **widget** also needs is the exception — tick
`FerrioWidgetExtension` in its Target Membership.

## Localization

English (source) and Polish. Three separate string catalogs:

- `Ferrio/Resources/Localizable.xcstrings` — the app
- `FerrioWidget/Localizable.xcstrings` — the widget
- `FerrioMessagesExtension/Localizable.xcstrings` — the iMessage extension

User-facing settings live in the iOS Settings app, so they have their own strings in
`Ferrio/Resources/Settings.bundle/{en,pl}.lproj/Root.strings` — **UTF-16LE**, keep the encoding.

## A note on `GoogleService-Info.plist`

It is untracked for tidiness, not secrecy. Every value in it (`API_KEY`, `CLIENT_ID`,
`GOOGLE_APP_ID`, …) also ships inside the app binary and is readable from any copy of the IPA. The
Firebase API key identifies the project; it does not authorize. What actually protects the backend
is server-side verification of the Firebase ID token with per-`uid` authorization, App Check, and
bundle-id restrictions on the key.

## Contributing

`CLAUDE.md` is the detailed architecture and conventions document — read it before changing
anything structural. Two rules that bite:

- `Ferrio.xcodeproj/**/xcuserdata/` is ignored and must stay out of the index.
- The in-app FAQ (`FaqCatalog` + `faq-*` keys) describes user-facing behaviour. If a change makes an
  answer wrong, fix the answer in the same change.
