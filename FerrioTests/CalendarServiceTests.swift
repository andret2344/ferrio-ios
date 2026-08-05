//
// Created by Andrzej Chmiel on 03/08/2026.
//

import Testing
import Foundation
@testable import Ferrio

/// `CalendarService` pads every month to a fixed 6×7 grid, which the month view relies on for its
/// layout. The tests pin a Gregorian calendar with an explicit `firstWeekday` rather than using
/// `.current`, so they do not change meaning on a device set to a Sunday-first locale.
struct CalendarServiceTests {
	private func service(firstWeekday: Int) -> CalendarService {
		var calendar = Calendar(identifier: .gregorian)
		calendar.firstWeekday = firstWeekday
		return CalendarService(calendar: calendar)
	}

	@Test("a month grid is always 42 cells", arguments: 1...12)
	func gridIsAlwaysFullSixWeeks(month: Int) {
		let days = service(firstWeekday: 2).getHolidayDaysForMonth(month, from: [])
		#expect(days.count == 42)
	}

	@Test("days that carry no holidays are still emitted, empty")
	func missingDaysArePaddedNotDropped() {
		let days = service(firstWeekday: 2).getHolidayDaysForMonth(3, from: [])
		#expect(days.allSatisfy { $0.holidays.isEmpty })
	}

	@Test("a holiday is placed on its own day and nowhere else")
	func holidayLandsOnItsDay() {
		let holiday = Holiday(id: "fixed-1", usual: false, name: "Test", description: "",
							  url: "", countryCode: nil, matureContent: false, aiGenerated: false)
		let source = [HolidayDay(day: 15, month: 3, holidays: [holiday])]

		let days = service(firstWeekday: 2).getHolidayDaysForMonth(3, from: source)
		let matching = days.filter { !$0.holidays.isEmpty }

		#expect(matching.count == 1)
		#expect(matching.first?.day == 15)
		#expect(matching.first?.month == 3)
	}

	@Test("the grid starts on the configured first weekday", arguments: [1, 2])
	func gridStartsOnFirstWeekday(firstWeekday: Int) throws {
		var calendar = Calendar(identifier: .gregorian)
		calendar.firstWeekday = firstWeekday

		let days = service(firstWeekday: firstWeekday).getHolidayDaysForMonth(3, from: [])
		let first = try #require(days.first)
		let date = try #require(Date.from(year: calendar.component(.year, from: Date()),
										  month: first.month, day: first.day))

		#expect(calendar.component(.weekday, from: date) == firstWeekday)
	}

	@Test("the grid spans the whole month it was asked for")
	func gridContainsEveryDayOfTheMonth() {
		let days = service(firstWeekday: 2).getHolidayDaysForMonth(2, from: [])
		let februaryDays = days.filter { $0.month == 2 }.map(\.day)

		// A short February is 28 days; a leap year adds one. Either way the first and last must
		// be present, and the padding cells belong to the neighbouring months.
		#expect(februaryDays.contains(1))
		#expect(februaryDays.contains(28))
		#expect(days.contains { $0.month != 2 })
	}
}
