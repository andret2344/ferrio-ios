//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct MonthScreenView: View {
    let holidayDays: [HolidayDay]
    @State
    private var selection = Calendar.current.component(.month, from: Date()) - 1
    var body: some View {
        ScrollView {
            LazyHStack {
                NavigationView {
                    TabView(selection: $selection) {
                        ForEach(1..<13) { i in
                            let days = holidayDays.filter { day in
                                day.month == i
                            }
                            ZStack {
                                MonthView(month: i, days: days)
                            }
                        }
                    }
                }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

struct MonthView: View {
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
                                } label : {
                                    Text(holidayDay.holidays.count == 0 ? "SAD" : String(day + 1))
                                            .frame(width: getWidth(geometry: geometry), height: getHeight(geometry: geometry))
                                            .background(.red)
                                            .cornerRadius(5)
                                }
                            }
                        }
                                .padding()
                    }
                }
            }
                    .navigationBarTitle(Text(DateFormatter().standaloneMonthSymbols[month - 1].capitalized))
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
        return getDays(from: date.startOfMonth(), to: date.endOfMonth())
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
