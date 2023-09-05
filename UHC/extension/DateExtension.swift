//
// Created by Andrzej Chmiel on 03/09/2023.
//

import Foundation

extension Date {
	static func from(year: Int, month: Int, day: Int) -> Date {
		let calendar = Calendar(identifier: .gregorian)
		var dateComponents = DateComponents()
		dateComponents.year = year
		dateComponents.month = month
		dateComponents.day = day
		return calendar.date(from: dateComponents)!
	}

	func startOfMonth() -> Date {
		let interval = Calendar.current.dateInterval(of: .month, for: self)
		return (interval?.start.toLocalTime())!
	}

	func endOfMonth() -> Date {
		let interval = Calendar.current.dateInterval(of: .month, for: self)
		return interval!.end
	}

	func toLocalTime() -> Date {
		let timezone = TimeZone.current
		let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
		return Date(timeInterval: seconds, since: self)
	}
}
