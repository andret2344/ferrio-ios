//
// Created by Andrzej Chmiel on 13/02/2026.
//

import Foundation

class CalendarService {
	private let calendar: Calendar

	init(calendar: Calendar = .current) {
		self.calendar = calendar
	}

	func getHolidayDaysForMonth(_ month: Int, from days: [HolidayDay]) -> [HolidayDay] {
		let year: Int = calendar.component(.year, from: Date())
		guard let date = Date.from(year: year, month: month, day: 1),
			  let before = getBefore(date: date),
			  let after = calendar.date(byAdding: .day, value: 41, to: before) else { return [] }
		return getDays(from: before, to: after, source: days)
	}

	private func getBefore(date: Date) -> Date? {
		guard let startOfMonth = date.startOfMonth() else { return nil }
		let weekday: Int = calendar.component(.weekday, from: startOfMonth)
		let remainingDays: Int = (7 - calendar.firstWeekday + weekday) % 7
		return calendar.date(byAdding: .day, value: -remainingDays, to: date)
	}

	private func getDays(from: Date, to: Date, source: [HolidayDay]) -> [HolidayDay] {
		var holidayDays: [HolidayDay] = []
		var date = from
		while date <= to {
			let calendarDate = calendar.dateComponents([.day, .month], from: date)
			if let month = calendarDate.month, let day = calendarDate.day {
				holidayDays.append(getDay(month: month, day: day, from: source))
			}
			guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
			date = nextDate
		}
		return holidayDays
	}

	private func getDay(month: Int, day: Int, from days: [HolidayDay]) -> HolidayDay {
		days.first(where: { $0.month == month && $0.day == day }) ?? HolidayDay(day: day, month: month, holidays: [])
	}
}
