//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import WidgetKit
import SwiftUI
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
	static var title: LocalizedStringResource = "widget-configuration"
	static var description = IntentDescription("widget-description")

	@Parameter(title: "widget-plus-days", default: 0, inclusiveRange: (-30, 30))
	var plusDays: Int

	@Parameter(title: "widget-colorized", default: false)
	var colorized: Bool

	@Parameter(title: "widget-show-weekday", default: false)
	var showWeekday: Bool
}

struct Provider: AppIntentTimelineProvider {
	typealias Entry = WidgetEntry
	typealias Intent = ConfigurationAppIntent

	func placeholder(in context: Context) -> WidgetEntry {
		let holiday: Holiday = Holiday(
			id: "fixed-0",
			usual: true,
			name: "perfect-day",
			description: "",
			url: "",
			countryCode: "",
			matureContent: false,
			aiGenerated: false
		)
		return WidgetEntry(date: Date(), holidayDay: HolidayDay(day: 1, month: 1, holidays: [holiday]), dayOffset: 0, colorized: false, includeUsual: false, showAdult: false, showWeekday: false, isLoggedIn: true, loadFailed: false)
	}

	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetEntry {
		guard ObservableConfig.isRealUserLoggedIn else {
			return WidgetEntry.loggedOut()
		}
		let result = await fetchHolidayDay(plusDays: 0)
		// Colorization has to follow the configuration here too: while the widget is being edited
		// the snapshot is rebuilt with the pending settings, and hardcoding `false` meant the
		// preview never reflected the switch the user had just flipped.
		return WidgetEntry(date: Date(), holidayDay: result.day, dayOffset: 0, colorized: configuration.colorized, includeUsual: ObservableConfig.shared.includeUsual, showAdult: ObservableConfig.shared.showAdultContent, showWeekday: configuration.showWeekday, isLoggedIn: true, loadFailed: result.failed)
	}

	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetEntry> {
		let now = Date()
		let midnight = Calendar.current.startOfDay(for: now)
		let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight) ?? now

		guard ObservableConfig.isRealUserLoggedIn else {
			let entry = WidgetEntry(date: now, holidayDay: nil, dayOffset: 0, colorized: false,
				includeUsual: ObservableConfig.shared.includeUsual, showAdult: ObservableConfig.shared.showAdultContent, showWeekday: configuration.showWeekday, isLoggedIn: false, loadFailed: false)
			return Timeline(entries: [entry], policy: .after(nextMidnight))
		}
		let plusDays = configuration.plusDays
		let result = await fetchHolidayDay(plusDays: plusDays)
		let entry = WidgetEntry(date: now, holidayDay: result.day, dayOffset: plusDays, colorized: configuration.colorized, includeUsual: ObservableConfig.shared.includeUsual, showAdult: ObservableConfig.shared.showAdultContent, showWeekday: configuration.showWeekday, isLoggedIn: true, loadFailed: result.failed)
		// Waiting until midnight after a failure would leave the widget broken all day.
		let refresh = result.failed ? min(now.addingTimeInterval(15 * 60), nextMidnight) : nextMidnight
		return Timeline(entries: [entry], policy: .after(refresh))
	}

	/// - Returns: the day to render, and whether the refresh failed with nothing to fall back on.
	///   A cached hit is reported as a success: it is real data, just not fresh.
	private func fetchHolidayDay(plusDays: Int) async -> (day: HolidayDay?, failed: Bool) {
		guard let url = getUrl(plusDays: plusDays), let dayKey = Self.dayKey(plusDays: plusDays) else {
			return (nil, true)
		}
		if let payload = await download(from: url) {
			HolidayDayCache.store(payload, forDay: dayKey)
			return (Self.holidayDay(from: payload), false)
		}
		// `try?` used to turn every timeout, 500 and offline state into `nil`, which renders
		// exactly like a genuinely empty day. Fall back to the last successful response for this
		// same date instead, and only admit failure when there is nothing cached.
		if let cached = HolidayDayCache.payload(forDay: dayKey) {
			return (Self.holidayDay(from: cached), false)
		}
		return (nil, true)
	}

	private func download(from url: URL) async -> Data? {
		guard let (data, response) = try? await URLSession.shared.data(from: url),
			  let http = response as? HTTPURLResponse,
			  (200...299).contains(http.statusCode) else { return nil }
		return data
	}

	private static func holidayDay(from payload: Data) -> HolidayDay? {
		guard let dtos = try? JSONDecoder().decode([HolidayDTO].self, from: payload) else { return nil }
		return HolidayRepository.groupIntoHolidayDays(dtos).first
	}

	private static func dayKey(plusDays: Int) -> String? {
		guard let date = Calendar.current.date(byAdding: .day, value: plusDays, to: Date()) else { return nil }
		let components = Calendar.current.dateComponents([.day, .month], from: date)
		guard let month = components.month, let day = components.day else { return nil }
		return String(format: "%02d-%02d", month, day)
	}

	func getUrl(plusDays: Int) -> URL? {
		guard let current = Calendar.current.date(byAdding: .day, value: plusDays, to: Date()) else { return nil }
		let components = Calendar.current.dateComponents([.day, .month], from: current)
		guard let month = components.month, let day = components.day else { return nil }
		let language = ObservableConfig.sharedDefaults?.string(forKey: "language") ?? API.language
		var urlString = "\(API.baseURL)/holidays?lang=\(language)&month=\(month)&day=\(day)"
		if ObservableConfig.shared.showAdultContent {
			urlString += "&includeMatureContent=true"
		}
		return URL(string: urlString)
	}
}

// MARK: - Entry

struct WidgetEntry: TimelineEntry {
	let date: Date
	let holidayDay: HolidayDay?
	let dayOffset: Int
	let colorized: Bool
	let includeUsual: Bool
	let showAdult: Bool
	let showWeekday: Bool
	let isLoggedIn: Bool
	/// The refresh failed and no cached day was available — distinct from "this day has no
	/// unusual holidays", which used to look identical.
	let loadFailed: Bool

	static func loggedOut() -> WidgetEntry {
		WidgetEntry(date: Date(), holidayDay: nil, dayOffset: 0, colorized: false, includeUsual: false, showAdult: false, showWeekday: false, isLoggedIn: false, loadFailed: false)
	}
}

// MARK: - Entry View

struct FerrioWidgetEntryView: View {
	@Environment(\.widgetFamily) private var family
	var entry: Provider.Entry

	var body: some View {
		if entry.isLoggedIn {
			let holidays = entry.holidayDay?.getHolidays(includeUsual: entry.includeUsual, showAdult: entry.showAdult) ?? []
			switch family {
			case .accessoryInline:
				FerrioAccessoryInlineView(entry: entry, holidays: holidays)
			case .accessoryRectangular:
				FerrioAccessoryRectangularView(entry: entry, holidays: holidays)
			default:
				FerrioRegularView(entry: entry, holidays: holidays)
			}
		} else {
			switch family {
			case .accessoryInline:
				LoginRequiredInlineView()
			case .accessoryRectangular:
				LoginRequiredRectangularView()
			default:
				LoginRequiredRegularView()
			}
		}
	}
}

// MARK: - Login Required Views

struct LoginRequiredInlineView: View {
	var body: some View {
		Label {
			Text("widget-login-required")
				.lineLimit(1)
				.minimumScaleFactor(0.8)
		} icon: {
			Image(systemName: "person.crop.circle.badge.exclamationmark")
				.widgetAccentable()
		}
		.widgetURL(URL(string: "ferrio://open"))
	}
}

struct LoginRequiredRectangularView: View {
	var body: some View {
		ZStack {
			AccessoryWidgetBackground()
			VStack(spacing: 4) {
				Image(systemName: "person.crop.circle.badge.exclamationmark")
				Text("widget-login-required")
					.font(.caption)
					.multilineTextAlignment(.center)
			}
			.padding(6)
		}
		.containerBackground(Color.clear, for: .widget)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
	}
}

struct LoginRequiredRegularView: View {
	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: "person.crop.circle.badge.exclamationmark")
				.font(.largeTitle)
			Text("widget-login-required")
				.font(.body)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.containerBackground(Color(UIColor.systemBackground).gradient, for: .widget)
		.widgetURL(URL(string: "ferrio://open"))
	}
}

// MARK: - Holiday Views

struct FerrioAccessoryInlineView: View {
	let entry: WidgetEntry
	let holidays: [Holiday]

	var body: some View {
		Label {
			titleText
				.lineLimit(1)
				.minimumScaleFactor(0.8)
		} icon: {
			Image(systemName: "calendar")
				.widgetAccentable()
		}
		.widgetURL(URL(string: "ferrio://open"))
	}

	var titleText: Text {
		let deviceCountry = Locale.current.region?.identifier
		let localHolidays = holidays.filter { holiday in
			guard let countryCode = holiday.countryCode, !countryCode.isEmpty,
				  let deviceCountry else { return false }
			return countryCode.caseInsensitiveCompare(deviceCountry) == .orderedSame
		}
		if let holiday = localHolidays.randomElement() ?? holidays.randomElement() {
			return Text(holiday.nameWithFlag)
		}
		return Text(entry.loadFailed ? "widget-load-failed" : "no-unusual-holidays")
	}
}

struct FerrioAccessoryRectangularView: View {
	let entry: WidgetEntry
	let holidays: [Holiday]

	var body: some View {
		ZStack {
			AccessoryWidgetBackground()

			VStack(spacing: 4) {
				if holidays.isEmpty {
					VStack(spacing: 4) {
						Text(entry.loadFailed ? "widget-load-failed" : "no-unusual-holidays")
							.font(.caption)
						Image("SadIcon")
					}
					.frame(maxWidth: .infinity, alignment: .center)
				} else {
					VStack(alignment: .leading, spacing: 4) {
						ForEach(holidays.prefix(3)) { holiday in
							HStack(alignment: .top, spacing: 4) {
								Text("•")
								Text(holiday.nameWithFlag)
							}
							.font(.caption)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			.padding(6)
		}
		.containerBackground(Color.clear, for: .widget)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
	}
}

struct FerrioRegularView: View {
	@Environment(\.widgetFamily) private var family
	let entry: WidgetEntry
	let holidays: [Holiday]

	private var maxHolidays: Int {
		switch family {
		case .systemLarge: return 15
		default: return 7
		}
	}

	var body: some View {
		VStack {
			let date = Date.from(month: entry.holidayDay?.month ?? 1, day: entry.holidayDay?.day ?? 1) ?? Date()
			Text(entry.showWeekday
				? date.formatted(.dateTime.weekday(.wide).day().month(.wide))
				: date.formatted(.dateTime.day().month(.wide)))
				.bold()
				.padding(8)
				.frame(maxWidth: .infinity)

			if holidays.isEmpty {
				Text(entry.loadFailed ? "widget-load-failed" : "no-unusual-holidays")
					.font(.body)
					.multilineTextAlignment(.center)
				Image("SadIcon")
			} else {
				ForEach(Array(holidays.prefix(maxHolidays))) { holiday in
					HStack(alignment: .top) {
						Text("\u{2022}").padding(.leading, 6)
						Text(holiday.nameWithFlag)
					}
					.font(.caption)
					.padding(.horizontal, 6)
					.frame(maxWidth: .infinity, alignment: .topLeading)
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.containerBackground(getColor(colorized: entry.colorized).gradient, for: .widget)
		.widgetURL(URL(string: "ferrio://open"))
	}

	func getColor(colorized: Bool) -> Color {
		if !colorized {
			return Color(UIColor.systemBackground)
		}
		return Color(UIColor.random(seed: Int(entry.holidayDay?.id ?? "0") ?? 0))
	}
}

// MARK: - Widget Configuration

struct FerrioWidget: Widget {
	let kind: String = "FerrioWidget"
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			FerrioWidgetEntryView(entry: entry)
		}
		.configurationDisplayName("Ferrio")
		.description("widget-description")
		.supportedFamilies(
			[
				.systemSmall,
				.systemMedium,
				.systemLarge,
				.accessoryInline,
				.accessoryRectangular,
			]
		)
		.contentMarginsDisabled()
	}
}
