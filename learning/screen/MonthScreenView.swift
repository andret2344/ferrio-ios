//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct MonthScreenView: View {
    let holidayDays: [HolidayDay]
    var body: some View {
        ScrollView {
            LazyHStack {
                NavigationView {
                    TabView {
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
                        .tabViewStyle(.page)
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
                VStack(alignment: .leading, spacing: 8) {
                    let rows: [[HolidayDay]] = days.chunked(into: 7)
                    ForEach(0..<rows.endIndex, id: \.self) { weekIndex in
                        HStack(spacing: 16) {
                            ForEach(0..<rows[weekIndex].endIndex, id: \.self) { dayIndex in
                                HolidayDayView(
                                        day: weekIndex * 7 + dayIndex + 1,
                                        holidayDay: rows[weekIndex][dayIndex]
                                )
                                        .frame(width: getWidth(geometry: geometry), height: getHeight(geometry: geometry))
                                        .background(.red)
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
        (geometry.size.width - 16 * 8) / 7
    }

    func getHeight(geometry: GeometryProxy) -> CGFloat {
        (geometry.size.height - 16 * 7) / 6
    }
}
