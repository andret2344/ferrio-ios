//
// Created by Andrzej Chmiel on 03/09/2023.
//

import Foundation

extension Date {
	static func from(year: Int, month: Int, day: Int) -> Date? {
		var dateComponents = DateComponents()
		dateComponents.year = year
		dateComponents.month = month
		dateComponents.day = day
		return Calendar.current.date(from: dateComponents)
	}

	static func from(month: Int, day: Int) -> Date? {
		var components = DateComponents()
		components.day = day
		components.month = month
		return Calendar.current.date(from: components)
	}

	func startOfMonth() -> Date? {
		Calendar.current.dateInterval(of: .month, for: self)?.start
	}
}
