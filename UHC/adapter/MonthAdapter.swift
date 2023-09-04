//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

struct MonthAdapter: View {
    @StateObject
    var observableConfig = ObservableConfig()
    let month: Int
    let days: [HolidayDay]
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    let holidayDays: [HolidayDay] = getHolidayDays();
                    let rows: [[HolidayDay]] = holidayDays.chunked(into: 7)
                    ForEach(0..<rows.endIndex, id: \.self) { weekIndex in
                        HStack(spacing: 6) {
                            ForEach(0..<rows[weekIndex].endIndex, id: \.self) { dayIndex in
                                let day: Int = weekIndex * 7 + dayIndex
                                let holidayDay: HolidayDay = holidayDays[day]
                                NavigationLink {
                                    DayScreenView(holidayDay: holidayDay)
                                } label: {
                                    let content = holidayDay.holidays.count == 0
                                            ? AnyView(Image("SadIcon"))
                                            : AnyView(Text(String(holidayDay.day)))
                                    content
                                            .frame(width: getWidth(geometry: geometry), height: getHeight(geometry: geometry))
                                            .background(Color(holidayDay.month == month ? .systemFill : .systemGray6))
                                            .foregroundColor(Color(.label))
                                            .cornerRadius(5)
                                }
                            }
                        }
                    }
                }
                        .padding()
                        .navigationBarTitle(Text(DateFormatter().standaloneMonthSymbols[month - 1].capitalized))
            }
        }
    }

    func getWidth(geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width - 8 * 8) / 7
    }

    func getHeight(geometry: GeometryProxy) -> CGFloat {
        (geometry.size.height - 24 * 7) / 6
    }

    func getHolidayDays() -> [HolidayDay] {
        let year: Int = Calendar.current.component(.year, from: Date())
        let date: Date = Date.from(year: year, month: month, day: 1)
        let before = getBefore(date: date)
        let after = getAfter(date: date)
        return getDays(from: before, to: after)
    }

    func getAfter(date: Date) -> Date {
        let endOfMonth: Date = Calendar.current.date(byAdding: .day, value: -1, to: date.endOfMonth())!
        let weekday: Int = Calendar.current.component(.weekday, from: endOfMonth)
        let remainingDays: Int = (13 + observableConfig.firstDayOfWeek - weekday) % 7
        return Calendar.current.date(byAdding: .day, value: remainingDays, to: endOfMonth)!
    }

    func getBefore(date: Date) -> Date {
        let startOfMonth: Date = date.startOfMonth()
        let weekday: Int = Calendar.current.component(.weekday, from: startOfMonth)
        let remainingDays: Int = (7 - observableConfig.firstDayOfWeek + weekday) % 7
        return Calendar.current.date(byAdding: .day, value: -remainingDays, to: date)!
    }

    func getDays(from: Date, to: Date) -> [HolidayDay] {
        var holidayDays: [HolidayDay] = []
        var date = from
        while date <= to {
            let calendarDate = Calendar.current.dateComponents([.day, .month], from: date)
            holidayDays.append(getDay(month: calendarDate.month!, day: calendarDate.day!))
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        return holidayDays
    }

    func getDay(month: Int, day: Int) -> HolidayDay {
        days.filter { holiday in
                    holiday.month == month && holiday.day == day
                }
                .first ?? HolidayDay(id: "\(day).\(month)", day: day, month: month, holidays: [])
    }
}
