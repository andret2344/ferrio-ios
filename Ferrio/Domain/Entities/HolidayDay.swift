//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import Foundation

struct HolidayDay: Identifiable, Equatable {
	let id: String
	let day: Int
	let month: Int
	var holidays: [Holiday]

	init(day: Int, month: Int, holidays: [Holiday]) {
		self.id = String(format: "%02d%02d", month, day)
		self.day = day
		self.month = month
		self.holidays = holidays
	}

	func getDate() -> String {
		String(format: "%02d", day) + "." + String(format: "%02d", month)
	}

	func getHolidays(includeUsual: Bool) -> [Holiday] {
		if includeUsual {
			return holidays
		}
		return holidays.filter { !$0.usual }
	}
}
