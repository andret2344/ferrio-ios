//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

struct MonthAdapter: View {
	@Environment(\.calendar)
	var calendar
	@StateObject
	var observableConfig = ObservableConfig()
	@Binding
	var selectedDay: HolidayDay?
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
								let button: Button = Button {
									selectedDay = holidayDay
								} label: {
									if holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays).count == 0 {
										Image("SadIcon")
												.resizable()
												.aspectRatio(contentMode: .fit)
									} else {
										Text(String(holidayDay.day))
												.font(.system(size: 25))
									}
								}
								let components: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())
								let view: some View = button
										.frame(width: getWidth(geometry: geometry), height: getHeight(geometry: geometry))
										.background(Color(getColor(currentMonth: holidayDay.month == month, holidayDay: holidayDay)))
										.foregroundColor(Color(.label))
										.cornerRadius(5)
										.sheet(item: $selectedDay) { item in
											SheetView(holidayDay: item)
													.presentationDetents([.fraction(0.5), .fraction(0.9)])
										}
								if components.day == holidayDay.day && components.month == holidayDay.month {
									view.overlay(RoundedRectangle(cornerRadius: 5).stroke(.red, lineWidth: 3))
								} else {
									view
								}
							}
						}
					}
				}
						.padding()
						.navigationTitle(Text(DateFormatter().standaloneMonthSymbols[month - 1].capitalized))
			}
		}
	}

	func getColor(currentMonth: Bool, holidayDay: HolidayDay) -> UIColor {
		if !currentMonth {
			return .systemGray6
		}
		if observableConfig.colorizedDays {
			return UIColor.random(seed: Int(holidayDay.id)!)
		}
		return .systemFill
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
		let remainingDays: Int = (13 + calendar.firstWeekday - weekday) % 7
		return Calendar.current.date(byAdding: .day, value: remainingDays, to: endOfMonth)!
	}

	func getBefore(date: Date) -> Date {
		let startOfMonth: Date = date.startOfMonth()
		let weekday: Int = Calendar.current.component(.weekday, from: startOfMonth)
		let remainingDays: Int = (7 - calendar.firstWeekday + weekday) % 7
		return Calendar.current.date(byAdding: .day, value: -remainingDays, to: date)!
	}

	func getDays(from: Date, to: Date) -> [HolidayDay] {
		var holidayDays: [HolidayDay] = []
		var date = from
		while date <= to {
			let calendarDate = Calendar.current.dateComponents([.day, .month], from: date)
			if let day: HolidayDay = getDay(month: calendarDate.month!, day: calendarDate.day!) {
				holidayDays.append(day)
			}
			date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
		}
		return holidayDays
	}

	func getDay(month: Int, day: Int) -> HolidayDay? {
		days.first(where: { $0.month == month && $0.day == day })
	}
}
