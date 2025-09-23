//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
	typealias Entry = WidgetEntry
	typealias Intent = ConfigurationIntent

	func placeholder(in context: Context) -> WidgetEntry {
		let holiday: Holiday = Holiday(
			id: 1,
			usual: true,
			name: "perfect-day",
			description: "",
			url: "",
			countryCode: "",
			category: "",
			matureContent: false
		)
		return WidgetEntry(date: Date(), holidayDay: HolidayDay(id: "-1", day: 1, month: 1, holidays: [holiday]), dayOffset: 0, colorized: false)
	}

	func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> Void) {
		Task {
			guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: getUrl(plusDays: 0)) else {
				return
			}
			let entry = WidgetEntry(date: Date(), holidayDay: holidayDay, dayOffset: 0, colorized: false)
			completion(entry)
		}
	}

	func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
		Task {
			let plusDays = configuration.plusDays?.intValue ?? 0
			guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: getUrl(plusDays: plusDays)) else {
				return
			}
			let target: Date = Calendar.current.date(bySettingHour: 0, minute: .random(in: 0..<3), second: .random(in: 0..<59), of: Date())!
			let entry: WidgetEntry = WidgetEntry(date: getProperDate(targetDate: target), holidayDay: holidayDay, dayOffset: plusDays, colorized: configuration.colorized?.boolValue ?? false)
			completion(Timeline(entries: [entry], policy: .after(target)))
		}
	}

	func getProperDate(targetDate: Date) -> Date {
		let timeDifference: Double = targetDate.timeIntervalSince(Date())
		if timeDifference > 0 {
			return targetDate;
		}
		return Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
	}

	func getUrl(plusDays: Int) -> URL {
		let current: Date = Calendar.current.date(byAdding: .day, value: plusDays, to: Date())!
		let components: DateComponents = Calendar.current.dateComponents([.day, .month], from: current)
		let code: String? = Locale.current.language.languageCode?.identifier
		let lang: String = ["pl"].contains(code!) ? code! : "en"
		return URL(string: "https://api.ferrio.app/v2/holiday/\(lang)/day/\(components.month!)/\(components.day!)")!
	}
}

struct WidgetEntry: TimelineEntry {
	let date: Date
	let holidayDay: HolidayDay
	let dayOffset: Int
	let colorized: Bool
}

struct FerrioWidgetEntryView: View {
	@Environment(\.widgetFamily) private var family
	@StateObject var observableConfig = ObservableConfig()
	var entry: Provider.Entry

	var body: some View {
		let holidays = entry.holidayDay.getHolidays(includeUsual: observableConfig.includeUsual)
		switch family {
		case .accessoryInline:
			FerrioAccessoryInlineView(
				entry: entry,
				holidays: holidays
			)
		case .accessoryRectangular:
			FerrioAccessoryRectangularView(
				entry: entry,
				holidays: holidays
			)
		default:
			FerrioRegularView(
				entry: entry,
				holidays: holidays
			)
		}
	}
}

struct FerrioAccessoryInlineView: View {
	@StateObject var observableConfig = ObservableConfig()
	let entry: WidgetEntry
	let holidays: [Holiday]

	var body: some View {
		Label {
			Text(getTitle())
				.lineLimit(1)
				.minimumScaleFactor(0.8)
		} icon: {
			Image(systemName: "calendar")
				.widgetAccentable()
		}
		.widgetURL(URL(string: "ferrio://open"))
	}

	func getTitle() -> String {
		let holidays = entry.holidayDay.getHolidays(includeUsual: observableConfig.includeUsual)
		if holidays.isEmpty {
			return "no-unusual-holidays"
		}
		return holidays[Int.random(in: 0..<holidays.count)].name
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
						Text("no-unusual-holidays")
							.font(.caption)
						Image("SadIcon")
					}
					.frame(maxWidth: .infinity, alignment: .center)
				} else {
					VStack(alignment: .leading, spacing: 4) {
						ForEach(holidays.prefix(3)) { holiday in
							HStack(alignment: .top, spacing: 4) {
								Text("•")
								Text(holiday.name)
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
	let entry: WidgetEntry
	let holidays: [Holiday]

	var body: some View {
		VStack {
			let date = Date.from(month: entry.holidayDay.month, day: entry.holidayDay.day)!
			Text(date.formatted(.dateTime.day().month(.wide)))
				.bold()
				.padding(8)
				.frame(maxWidth: .infinity)

			if holidays.isEmpty {
				Text("no-unusual-holidays").font(.body).multilineTextAlignment(.center)
				Image("SadIcon")
			} else {
				ForEach(holidays) { holiday in
					HStack(alignment: .top) {
						Text("\u{2022}").padding(.leading, 6)
						Text(holiday.name)
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
		if !entry.colorized {
			return Color(UIColor.systemBackground)
		}
		return Color(UIColor.random(seed: Int(entry.holidayDay.id)!))
	}
}

struct FerrioWidget: Widget {
	let kind: String = "FerrioWidget"
	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
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
