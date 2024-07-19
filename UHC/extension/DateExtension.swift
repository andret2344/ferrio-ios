//
// Created by Andrzej Chmiel on 03/09/2023.
//

import Foundation

extension Date {
	static func from(year: Int, month: Int, day: Int) -> Date {
		var dateComponents = DateComponents()
		dateComponents.year = year
		dateComponents.month = month
		dateComponents.day = day
		return Calendar.current.date(from: dateComponents)!
	}

	static func from(month: Int, day: Int) -> Date? {
		var components = DateComponents()
		components.day = day
		components.month = month
		return Calendar.current.date(from: components)
	}

	static func getDateString(month: Int, day: Int) -> String {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("dd MMM")
		return df.string(from: from(month: month, day: day)!)
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
