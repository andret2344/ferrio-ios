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
		VStack(alignment: .leading) {
			let holidayDays: [HolidayDay] = getHolidayDays();
			let rows: [[HolidayDay]] = holidayDays.chunked(into: 7)
			ForEach(0..<rows.endIndex, id: \.self) { weekIndex in
				HStack(spacing: 6) {
					ForEach(0..<rows[weekIndex].endIndex, id: \.self) { dayIndex in
						let day: Int = weekIndex * 7 + dayIndex
						let holidayDay: HolidayDay = holidayDays[day]
						let components: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())

						renderButton(holidayDay: holidayDay)
							.overlay(
								components.day == holidayDay.day && components.month == holidayDay.month ?
								RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 3) : nil
							)
					}
				}
			}
			Spacer()
		}
		.padding()
		.navigationTitle(Text(DateFormatter().standaloneMonthSymbols[month - 1].capitalized))
	}

	private func renderButton(holidayDay: HolidayDay) -> some View {
		Button(action: {
			selectedDay = holidayDay
		}) {
			ZStack {
				if holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays).count == 0 {
					Image("SadIcon")
						.resizable()
						.aspectRatio(contentMode: .fit)
				} else {
					Text(String(holidayDay.day))
						.font(.system(size: 25))
				}
			}
			.frame(width: getWidth(), height: getHeight())
		}
		.background(Color(getColor(currentMonth: holidayDay.month == month, holidayDay: holidayDay)))
		.foregroundColor(Color(.label))
		.cornerRadius(5)
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

	func getWidth() -> CGFloat {
		(UIScreen.main.bounds.width - 63) / 7
	}

	func getHeight() -> CGFloat {
		(UIScreen.main.bounds.height - 261) / 7
	}

	func getHolidayDays() -> [HolidayDay] {
		let year: Int = Calendar.current.component(.year, from: Date())
		let date: Date = Date.from(year: year, month: month, day: 1)
		let before: Date = getBefore(date: date)
		let after: Date = Calendar.current.date(byAdding: .day, value: 41, to: before)!
		return getDays(from: before, to: after)
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
			holidayDays.append(getDay(month: calendarDate.month!, day: calendarDate.day!))
			date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
		}
		return holidayDays
	}

	func getDay(month: Int, day: Int) -> HolidayDay {
		days.first(where: { $0.month == month && $0.day == day }) ?? HolidayDay(day: day, month: month, holidays: [])
	}
}
