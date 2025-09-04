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
		return URL(string: "https://api.unusualcalendar.net/holiday/\(lang)/day/\(components.month!)/\(components.day!)")!
	}
}

struct WidgetEntry: TimelineEntry {
	let date: Date
	let holidayDay: HolidayDay
	let dayOffset: Int
	let colorized: Bool
}

struct FerrioWidgetEntryView: View {
	@StateObject
	var observableConfig = ObservableConfig()
	var entry: Provider.Entry
	var body: some View {
		VStack {
			let date: Date? = Date.from(month: entry.holidayDay.month, day: entry.holidayDay.day)
			Text(date!.formatted(.dateTime.day().month(.wide)))
				.bold()
				.padding(8)
				.frame(maxWidth: .infinity)
			let holidays: [Holiday] = entry.holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays)
			if holidays.isEmpty {
				Text("no-unusual-holidays")
					.font(.body)
					.multilineTextAlignment(.center)
				Image("SadIcon")
			} else {
				ForEach(holidays) { holiday in
					HStack(alignment: .top) {
						Text("\u{2022}")
							.padding(.leading, 6)
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
		.contentMarginsDisabled()
	}
}
