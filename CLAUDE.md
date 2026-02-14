# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ferrio is an iOS app for browsing unusual/niche holidays (e.g., "National Pizza Day"). Users can view daily holidays on a calendar, report data errors, and suggest missing holidays. Includes a WidgetKit extension for home screen display.

## Build & Run

- **IDE**: Xcode (project: `Ferrio.xcodeproj`, scheme: `Ferrio`)
- **Build**: `xcodebuild -scheme Ferrio -destination 'platform=iOS Simulator,name=iPhone 16' build`
- **Test**: `xcodebuild -scheme Ferrio -destination 'platform=iOS Simulator,name=iPhone 16' test`
- **Dependencies**: Swift Package Manager (no CocoaPods/Carthage). Dependencies resolve automatically on build.
- **Deployment target**: iOS 26.0
- **Swift version**: 5.0

## Architecture

**MVVM with SwiftUI**, organized in a layered folder structure:

- **App/** — Entry point (`FerrioApp`), `AppDelegate` (Firebase init), `ObservableConfig` (singleton wrapping `@AppStorage` preferences, shared with widget)
- **Domain/Entities/** — Pure Swift structs: `Holiday`, `HolidayDay`, `FloatingHoliday`, `HolidayReport`, `ReportState`, etc.
- **Data/DTOs/** — API request payloads. **Data/Repositories/** — `HolidayRepository` handles API calls + floating holiday JS evaluation
- **Core/Extensions/** — Swift extensions (Date, String, UIColor, URLSession, Array, Encodable)
- **Core/Services/** — `CalendarService` for month-grid date math
- **Presentation/ViewModels/** — `AuthenticationViewModel` (auth state), `ContentViewModel` (holiday data loading). Both are `@MainActor ObservableObject` with `@Published` properties
- **Presentation/Views/** — SwiftUI views. `ContentView` is the root tab container (Calendar, Reports, More, Search)
- **Presentation/Sheets/** — Bottom sheets for holiday details and reporting

**Dependency injection** is via `@EnvironmentObject` for `AuthenticationViewModel` and `ObservableConfig`.

**Note**: Some screen views (e.g., `MyReportsScreenView`, `MySuggestionsScreenView`) make API calls directly instead of going through a ViewModel.

## Key Technical Details

- **JavaScriptCore**: `FloatingHoliday` entities include a JS `script` field evaluated at runtime via `JSContext` to compute date-variable holidays. This logic lives in `HolidayRepository`.
- **Backend API**: `https://api.ferrio.app/v2/` — endpoints for holidays, reports, suggestions, and countries. Language is auto-detected from `Locale.current.language.languageCode` (defaults to `"en"` for non-Polish).
- **Auth**: Firebase Auth with Google Sign-In and anonymous login. Anonymous users have restricted access (no reports/suggestions).
- **Widget**: `FerrioWidget` shares `ObservableConfig.shared` and domain models with the main app. Located in `FerrioWidget/`.
- **Networking**: Plain `URLSession` with a custom async extension (`URLSessionExtension.swift`), no third-party HTTP libraries.

## Localization

Two languages: English (`en`) and Polish (`pl`). All UI strings use `String.localized()` (wraps `NSLocalizedString`). Strings files are in `Resources/en.lproj/` and `Resources/pl.lproj/`. The Settings bundle also has localized strings.

## Targets

1. `Ferrio` — main app (`eu.andret.uhc`)
2. `FerrioWidgetExtension` — widget (`eu.andret.uhc.widget`)
3. `FerrioTests` / `FerrioUITests` — test targets (currently stubs with no real tests)
