# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

If a change introduces something new that belongs here (a new pattern, module, constraint, or
intentional non-default), add it — don't leave the file describing only the old state. A change
that makes this file stale is considered incomplete.

## Project Overview

Ferrio is an iOS app for browsing unusual/niche holidays (e.g., "National Pizza Day"). Users browse
a month calendar, open a holiday for its description, share it as a rendered card, report data
errors, and suggest missing holidays. Ships with a WidgetKit widget and an iMessage extension.

## Build & Run

- **IDE**: Xcode 26 (project: `Ferrio.xcodeproj`, scheme: `Ferrio`)
- **First-time setup**: `Ferrio/Resources/GoogleService-Info.plist` is **not in the repo** (see Repo
  hygiene) but `project.pbxproj` references it and the app target copies it as a resource. Download
  it from the Firebase console (project settings » iOS app) before the first build; without it the
  build fails on a missing input file, which does not look like a configuration problem.
- **Build**: `xcodebuild -scheme Ferrio -destination 'generic/platform=iOS Simulator' build`
- **Test**: `xcodebuild -scheme Ferrio -destination 'id=<booted-simulator>' test`. Unlike a plain
  build, the test action needs a **real** simulator, not the generic destination. The shared scheme
  lists `FerrioTests` under `<Testables>`; without that entry `xcodebuild` refuses with "Scheme
  Ferrio is not currently configured for the test action".
- **Prefer the generic destination.** Named simulators (`platform=iOS Simulator,name=…`) change
  between machines, and `-showdestinations` sometimes lists only the placeholder even while
  `xcrun simctl list devices available` shows a booted device — `generic/platform=iOS Simulator`
  sidesteps both and is enough to verify that everything compiles and links.
- **Quit Xcode before a terminal build.** An open Xcode holds locks that leave `xcodebuild` idling:
  a full build with a clean `-derivedDataPath` took 22 minutes wall-clock for 40 seconds of CPU, and
  finished promptly once Xcode was closed.
- **Dependencies**: Swift Package Manager (no CocoaPods/Carthage). Resolved automatically on build.
- **Deployment target**: iOS 26.0. **Swift version**: 5.0. **Version**: 2.1.5 (build 13).
  `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` must stay identical across `Ferrio`,
  `FerrioWidgetExtension` and `FerrioMessagesExtension` — App Store Connect rejects a submission
  whose embedded extensions disagree with the host app. The two test targets keep the template's
  `1.0` / `1` and are irrelevant.
- **Swift 6 is not enabled anywhere, deliberately.** `SWIFT_APPROACHABLE_CONCURRENCY` and
  `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY` used to be set on `FerrioMessagesExtension`
  only; promoting them to the project broke `ObservableConfig` ("does not conform to protocol
  'ObservableObject'"), so they were removed everywhere instead. All targets now share one Swift
  setting. Turning them back on is part of a real Swift 6 migration, not a settings tweak.

## Adding files

**Every** top-level folder is a `PBXFileSystemSynchronizedRootGroup` — `Ferrio`, `FerrioWidget`,
`FerrioMessagesExtension`, `FerrioTests`, `FerrioUITests`. Dropping a `.swift` file into one of them
is enough; there is nothing to register in `project.pbxproj`, and no `PBXGroup` hierarchy to keep in
step with the folder layout. What is left in the project file is only products, the three SDK
framework references, `FerrioWidgetExtension.entitlements`, and the sync/exception bookkeeping
below.

Deviations from "the whole folder belongs to the owning target" live in
`PBXFileSystemSynchronizedBuildFileExceptionSet`s, and `membershipExceptions` means the *opposite*
thing depending on which target the set names:

- **the target that owns the folder** — the listed paths are **excluded**. `Ferrio` excludes
  `Resources/Info.plist`; `FerrioWidget` and `FerrioMessagesExtension` each exclude their own
  `Info.plist` (consumed via `INFOPLIST_FILE`, never through a build phase).
- **any other target** — the listed paths are **included**. This is how the widget gets its share of
  the app's code: the `Ferrio` folder has a second exception set naming `FerrioWidgetExtension`,
  listing the 15 shared sources (`Holiday`, `HolidayDay`, `HolidayReport`, `HolidayDTO`,
  `HolidayReportPayload`, `MissingFixedHoliday`, `MissingFloatingHoliday`, `ReportState`,
  `ObservableConfig`, `HolidayRepository`, `CalendarService` and the four extensions) plus
  `Resources/Assets.xcassets`.

So a **new type the widget also needs still requires a manual step** — add it to that second
exception set (in Xcode: tick `FerrioWidgetExtension` in the file's Target Membership). Only
app-only files are truly zero-effort. `Ferrio/Ferrio.entitlements` needs no exception: Xcode keeps
entitlements out of the resource phase by itself (verified — it is absent from the built bundle).

Verify project-file edits with `plutil -lint` and a real build. SourceKit diagnostics in the editor
lag behind — after a folder conversion it will report things like `No such module 'UIKit'` until it
reindexes — and are not proof of anything.

Converting a group to a synchronized folder requires the group tree and the folder to match
*exactly*, and Xcode counts dotfiles other than `.DS_Store`: a stray `.gitignore` inside the folder
is enough to make it refuse with "Content Missing From Group". Xcode also holds its own in-memory
copy of the project, so edit `project.pbxproj` on disk only while Xcode is closed.

## Architecture

**MVVM with SwiftUI**, layered folders under `Ferrio/`:

- **App/** — `FerrioApp` (`@main`; switches between `LogInView` / `ContentView` / spinner on
  `AuthenticationViewModel.state`, injects the environment objects, syncs the Settings bundle on
  launch and foreground, routes `onOpenURL` to Google Sign-In and Firebase), `AppDelegate`
  (Firebase init), `ObservableConfig`
- **Domain/Entities/** — plain structs: `Holiday`, `HolidayDay`, `HolidayReport`,
  `MissingFixedHoliday`, `MissingFloatingHoliday`, `ReportState`, `FaqEntry`, plus the
  `HolidayType` / `ReportCategory` query-parameter enums
- **Data/DTOs/** — `HolidayDTO` (API response), `HolidayReportPayload`, `MissingHolidayPayload`
  (request bodies)
- **Data/Repositories/** — `HolidayRepository` (holiday fetch + grouping into `HolidayDay`s),
  `HolidayRepositoryReports` (reports and suggestions, all authenticated; the country list is no
  longer fetched)
- **Core/Extensions/** — `DateExtension`, `StringExtension`, `ArrayExtension`, `UIColorExtension`
  (seeded random colour for colorized days), `URLSessionExtension` (also hosts `enum API` and
  `enum APIError`), `AuthenticatedURLSession` (Firebase-bearer decode/post)
- **Core/Services/** — `CalendarService` (month-grid date math, pads to a 6×7 grid),
  `FaqCatalog` (in-app FAQ content)
- **Presentation/ViewModels/** — `AuthenticationViewModel`, `ContentViewModel`, `ReportsViewModel`,
  `SuggestionsViewModel`, `ReportHolidayViewModel`, `SuggestHolidayViewModel`. All are
  `@MainActor ObservableObject` with `@Published` properties; every screen that talks to the API
  goes through one.
- **Presentation/Views/** — `ContentView` (root `TabView`: Calendar, Reports, More, Search),
  `CalendarView`, `HolidayDetailView`, `LogInView`, `MoreView`, `ReportsView`
- **Presentation/Views/Screens/** — `MyReportsScreenView`, `MySuggestionsScreenView`,
  `SearchScreenView`, `SuggestHolidayScreenView`, `FaqScreenView`
- **Presentation/Views/Components/** — `MonthAdapterView` (the month grid), `ShareButton`
  (share-card views + rendering + `UIActivityViewController` presentation), `StatusBadge`,
  `SendingOverlayView`
- **Presentation/Sheets/** — `HolidayDaySheetView`, `ReportHolidaySheetView`,
  `ReportDetailsSheetView`
- **Presentation/Extensions/** — `ReportState+Color`

**Dependency injection** is via `@EnvironmentObject` for `AuthenticationViewModel` and
`ObservableConfig`; the other view models are `@StateObject`s owned by their screen.

## Key Technical Details

- **Backend API**: `https://api.ferrio.app/v3` (`API.baseURL`). Holidays come from
  `/holidays?lang=…` (`&includeMatureContent=true` when enabled, `&month=&day=` for the widget);
  reports and suggestions from `/users/reports?reportType=error|suggestion&holidayType=fixed|floating`,
  built by `HolidayRepository.endpoint(_:_:)` from the `ReportCategory` and `HolidayType` enums —
  those two query values were bare strings until a typo could only be caught at runtime.
  `API.language` resolves to `pl` for Polish locales and `en` for everything else.
  There is no `/countries` call any more: the suggestion picker builds its list from
  `Locale.Region.isoRegions`, so the country list needs no network and works offline. The old
  hardcoded `…/v2/countries?format=code` endpoint is unused and can be retired server-side.
- **Networking**: plain `URLSession` with two async extensions — `decode` for public endpoints and
  `authenticatedDecode` / `authenticatedPost`, which attach a Firebase ID token as
  `Authorization: Bearer …`. No third-party HTTP libraries.
- **Data flow**: the app persists nothing. `ContentViewModel.loadData()` refetches the whole
  holiday set on launch and whenever the locale changes; there is no offline copy. The **widget**
  is the one exception — see below.
  Floating holidays arrive from the API already resolved (ids prefixed `floating-`); there is no
  client-side JavaScript evaluation.
- **Auth**: Firebase Auth with Google Sign-In, GitHub (`OAuthProvider`) and anonymous login.
  Anonymous users may browse and search but not report or suggest — screens are gated with
  `.disabled(viewModel.isAnonymous)`. `AuthenticationViewModel` handles credential linking when an
  account already exists with a different provider.
- **Settings**: user preferences live in the iOS Settings app (`Resources/Settings.bundle`), not
  in-app. `ObservableConfig` (singleton, `@AppStorage` on the `group.eu.andret.uhc` suite) mirrors
  `UserDefaults.standard` into the app group so the widget sees the same values, and stores the
  resolved API language for the widget process. Keys: `includeUsual`, `colorizedDays`,
  `showAdultContent`, plus `isRealUserLoggedIn`.
- **Widget**: `FerrioWidget` (`AppIntentTimelineProvider`) reuses `ObservableConfig.shared`,
  `HolidayDTO` and `HolidayRepository.groupIntoHolidayDays`. One entry per timeline, refreshed at
  the next midnight; it renders a signed-out placeholder unless
  `ObservableConfig.isRealUserLoggedIn`. Configurable via `ConfigurationAppIntent`
  (`plusDays`, `colorized`, `showWeekday`), and **both** `timeline` and `snapshot` must honour that
  configuration — `snapshot` is what the widget gallery renders while the user is editing settings.
  It has **its own** `FerrioWidget/Localizable.xcstrings`, separate from the app's; a string used in
  widget code has to be added there.
  `HolidayDayCache` keeps the raw JSON of the last successful response for **one** date in the app
  group. A failed refresh falls back to it instead of rendering an empty day, because an empty day
  is a legitimate result and the two used to be indistinguishable; only when nothing is cached does
  the entry set `loadFailed` and the views show `widget-load-failed`. A failed refresh also retries
  after 15 minutes rather than waiting for midnight. The cache holds one day on purpose — a cached
  entry for a different date would be worse than showing nothing.
- **iMessage extension**: `FerrioMessagesExtension` is deliberately self-contained — it re-declares
  its own holiday model, decoding and card rendering inside `MessagesViewController.swift` and has
  its own `Localizable.xcstrings`. It does not share code with the app target; changes to the app's
  models do not propagate there.
- **Share cards**: `HolidayShareCardView` / `HolidayDayShareCardView` are SwiftUI views rasterized
  with `ImageRenderer` (`scale = 3`) and handed to `UIActivityViewController`.
- **FAQ**: `FaqScreenView` (reached from the More tab) renders `FaqCatalog.entries` as
  `DisclosureGroup`s. A `FaqEntry` holds only an id; question and answer live in
  `Localizable.xcstrings` under `faq-question-<id>` / `faq-answer-<id>`, so the content ships with
  the app and follows the normal translation pipeline — it is deliberately **not** served from
  api.ferrio.app, because the AI disclosure must never depend on a successful network call.
  Answers are authored as Markdown and parsed with
  `interpretedSyntax: .inlineOnlyPreservingWhitespace`, since `Text(LocalizedStringKey)` parses
  Markdown inline-only and would swallow the blank lines.
- **AI-generated content**: `Holiday.aiGenerated` (API field `ai_generated`) drives the
  `AI-generated` badge in `HolidayDetailView` and on the holiday share card. The badge is the
  transparency disclosure required by Art. 50(4) of Regulation (EU) 2024/1689, so it must stay
  visible next to the description rather than being hidden behind the help alert, and it must
  travel with any surface that publishes the description outside the app. `HolidayDTO.aiGenerated`
  is optional with a `false` fallback so a response predating the flag still decodes.

## Localization

Two languages: English (`en`, source) and Polish (`pl`). UI strings live in the string catalog
`Ferrio/Resources/Localizable.xcstrings`; views pass the key directly as a `LocalizedStringKey`
literal, and code paths that need a resolved `String` use `String.localized()` (wraps
`NSLocalizedString`). The Settings bundle has its own strings in
`Resources/Settings.bundle/{en,pl}.lproj/Root.strings` (**UTF-16LE** — keep the encoding when
editing), and the iMessage extension has a separate catalog of its own.

**Keep the in-app FAQ current — but ask, don't guess.** The FAQ (`FaqCatalog`) describes
user-facing behaviour, and a change can silently make an answer wrong or leave a new feature
undocumented. Whenever a change touches something a user would ask about — a setting, a filter, a
status, the auth flow, the widget, the share card, where content comes from, the refresh
behaviour — **ask the user whether it should be added to or corrected in the FAQ before finishing
the change.** Name the entry you have in mind and propose the wording; do not add or reword FAQ
entries on your own initiative, and do not assume silence means no. The same applies in reverse: if
you notice an existing answer that no longer matches the code, raise it even when the current task
did not cause the drift.

## Targets

1. `Ferrio` — main app (`eu.andret.uhc`)
2. `FerrioWidgetExtension` — widget (`eu.andret.uhc.widget`)
3. `FerrioMessagesExtension` — iMessage extension (`eu.andret.uhc.FerrioMessagesExtension`)
4. `FerrioTests` — Swift Testing (`import Testing`, `@Test`/`#expect`) unit tests for the pure
   logic: `CalendarServiceTests` (6×7 grid padding, first-weekday handling) and
   `HolidayRepositoryTests` (`groupIntoHolidayDays`, DTO decoding incl. the `ai_generated`
   fallback, `getHolidays` filtering). `CalendarService` is constructed with an explicit
   `Calendar` so the tests do not depend on the machine's locale.
5. `FerrioUITests` — still an Xcode template stub

App icons: the main app uses Icon Composer (`Ferrio/AppIcon.icon`); the iMessage extension uses the
`iMessage App Icon.stickersiconset` in its own asset catalog
(`ASSETCATALOG_COMPILER_APPICON_NAME = "iMessage App Icon"`).

## CI

`.github/workflows/ci.yml` runs on pushes to `main`, on pull requests, and on demand.

- **build-and-test** (macOS): selects the newest Xcode on the image, writes
  `Ferrio/Resources/GoogleService-Info.plist` from the `GOOGLE_SERVICE_INFO_PLIST` secret (base64;
  the job fails fast with a clear message when it is unset, because the build cannot start without
  the file), builds against `generic/platform=iOS Simulator`, then resolves an actual iPhone
  simulator from the image with `simctl` and runs `test` against it. The `.xcresult` is uploaded as
  an artifact.
- **hygiene** (Linux, no Xcode): asserts that the Firebase config, `xcuserdata`, `.DS_Store` and any
  nested `.gitignore` under `Ferrio/` are untracked; that every string catalog entry with an English
  value also has a Polish one (a key with *no* localizations is fine — it resolves to itself);
  and that every `FaqCatalog` id has both a `faq-question-<id>` and a `faq-answer-<id>` key, with no
  orphan `faq-*` keys left behind. That last check exists because a missing FAQ key is a blank
  `DisclosureGroup` at runtime and nothing at build time.

Catalog entries whose state is not `translated` produce warnings, not failures — Xcode marks
auto-extracted format strings like `%@ %@` as `new` and they need no translation.

## Repo hygiene

`.gitignore` covers `/build/`, `/graphify-out/`, `.DS_Store` and `**/xcuserdata/`. The xcuserdata
pattern matters: those files (`UserInterfaceState.xcuserstate`, `xcschememanagement.plist`,
`Breakpoints_v2.xcbkptlist`, `IDEFindNavigatorScopes.plist`) are rewritten by merely opening Xcode
or running a build, and used to be tracked; they were untracked with `git rm --cached` and must
stay out of the index.

`Ferrio/Resources/Info.plist` carries `ITSAppUsesNonExemptEncryption = false`. The app only uses
HTTPS, which is exempt; the key is there so App Store Connect stops asking on every upload.

`Ferrio/Resources/GoogleService-Info.plist` is ignored and untracked as well, but stays on disk —
see Build & Run for how to obtain it. Treat this as tidiness, not as a secret: every value in that
file (`API_KEY`, `CLIENT_ID`, `GOOGLE_APP_ID`, …) also ships inside the app binary, so it is
readable from any copy of the IPA. The Firebase API key identifies the project, it does not
authorize; what actually protects the backend is server-side verification of the Firebase ID token
with per-`uid` authorization, App Check, and bundle-ID restrictions on the key. Client-side gates
like `.disabled(viewModel.isAnonymous)` are UI affordances and enforce nothing. A Firebase Admin
service-account key would be a real secret — none is present in this repo, and none belongs here.

There is no nested `.gitignore` anywhere under `Ferrio/`. One used to sit in `Resources/`; it was
removed because a stray file inside a group's folder blocks Xcode's "Convert to Folder" (it counts
dotfiles other than `.DS_Store`), and because its rule never matched anyway.
