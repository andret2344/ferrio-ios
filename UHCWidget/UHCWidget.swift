//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        // Tworzenie przykładowego wpisu na potrzeby podglądu
        SimpleEntry(date: Date(), holidayDay: HolidayDay(id: "-1", day: 1, month: 1, holidays: [Holiday(id: 1, usual: true, name: "Perfect day!", description: "", url: "")]))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let url = URL(string: "https://api.unusualcalendar.net/holiday/pl/today")!
            guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: url) else {
                return
            }
            let entry = SimpleEntry(date: Date(), holidayDay: holidayDay)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let url = URL(string: "https://api.unusualcalendar.net/holiday/pl/today")!
            guard let holidayDay = try? await URLSession.shared.decode(HolidayDay.self, from: url) else {
                return
            }
            let currentDate: Date = Date()
            let targetDate: Date = Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: currentDate)!
            let entry: SimpleEntry = SimpleEntry(date: getProperDate(targetDate: targetDate), holidayDay: holidayDay)
            completion(Timeline(entries: [entry], policy: .after(targetDate)))
        }
    }

    func getProperDate(targetDate: Date) -> Date {
        let timeDifference: Double = targetDate.timeIntervalSince(Date())
        if timeDifference > 0 {
            return targetDate;
        }
        return Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
    }
}

struct SimpleEntry: TimelineEntry {
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
        Text(text)
                .multilineTextAlignment(.center)
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
