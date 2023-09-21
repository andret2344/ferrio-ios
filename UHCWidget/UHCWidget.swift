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
		let holiday: Holiday = Holiday(id: 1, usual: true, name: "Perfect day!", description: "", url: "")
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

struct UHCWidgetEntryView: View {
	var entry: Provider.Entry
	var body: some View {
		let text: String = entry.holidayDay.holidays.map { holiday in
					"- \(holiday.name)"
				}
				.joined(separator: "\n");
		VStack {
			Text("\(entry.holidayDay.getDate()):")
					.bold()
					.padding(10)
					.frame(maxWidth: .infinity)
			if text == "" {
				Text("No unusual holidays today.")
						.font(.body)
						.multilineTextAlignment(.center)
				Image("SadIcon")
			} else {
				Text(text)
						.font(.caption)
						.padding(5)
						.frame(maxWidth: .infinity, alignment: .topLeading)
			}
		}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				.background(entry.colorized ? Color(UIColor.random(seed: Int(entry.holidayDay.id)!)) : nil)
				.overlay(RoundedRectangle(cornerRadius: 23)
						.stroke(.black, lineWidth: 4))
	}
}

struct UHCWidget: Widget {
	let kind: String = "UHCWidget"
	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
			UHCWidgetEntryView(entry: entry)
		}
				.configurationDisplayName("Unusual Holiday Calendar")
				.description("Simply check what holidays are today.")
	}
}
