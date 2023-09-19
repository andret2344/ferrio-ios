//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
	func placeholder(in context: Context) -> WidgetEntry {
		let holiday: Holiday = Holiday(id: 1, usual: true, name: "Perfect day!", description: "", url: "")
		return WidgetEntry(date: Date(), holidayDay: HolidayDay(id: "-1", day: 1, month: 1, holidays: [holiday]))
	}

	func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) -> Void {
		Task {
			guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: getUrl()) else {
				return
			}
			let entry = WidgetEntry(date: Date(), holidayDay: holidayDay)
			completion(entry)
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) -> Void {
		Task {
			guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: getUrl()) else {
				return
			}
			let target: Date = Calendar.current.date(bySettingHour: 0, minute: .random(in: 0..<3), second: .random(in: 0..<59), of: Date())!
			let entry: WidgetEntry = WidgetEntry(date: getProperDate(targetDate: target), holidayDay: holidayDay)
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

	func getUrl() -> URL {
		let components: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())
		let code: String? = Locale.current.language.languageCode?.identifier
		let lang: String = ["pl"].contains(code!) ? code! : "en"
		return URL(string: "https://api.unusualcalendar.net/holiday/\(lang)/day/\(components.month!)/\(components.day!)")!
	}
}

struct WidgetEntry: TimelineEntry {
	let date: Date
	let holidayDay: HolidayDay
}

struct UHCWidgetEntryView: View {
	var entry: Provider.Entry
	var body: some View {
		let text: String = entry.holidayDay.holidays.map { holiday in
					"- \(holiday.name)"
				}
				.joined(separator: "\n");
		HStack {
			if text == "" {
				VStack {
					Text("No unusual holidays today.")
							.font(.body)
							.multilineTextAlignment(.center)
					Image("SadIcon")
				}
			} else {
				Text(text).font(.caption)
			}
		}
	}
}

struct UHCWidget: Widget {
	let kind: String = "UHCWidget"
	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
			UHCWidgetEntryView(entry: entry)
		}
				.configurationDisplayName("Unusual Holiday Calendar")
				.description("Simply check what holidays are today.")
	}
}
