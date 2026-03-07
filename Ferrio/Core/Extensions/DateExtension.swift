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

func formatDatetime(_ datetime: String) -> String {
	let isoFormatter = ISO8601DateFormatter()
	isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
	let displayFormatter = DateFormatter()
	displayFormatter.dateStyle = .medium
	displayFormatter.timeStyle = .short

	if let date = isoFormatter.date(from: datetime) {
		return displayFormatter.string(from: date)
	}

	// Fallback without fractional seconds
	isoFormatter.formatOptions = [.withInternetDateTime]
	if let date = isoFormatter.date(from: datetime) {
		return displayFormatter.string(from: date)
	}

	return datetime
}

func formatFixedDate(day: Int, month: Int) -> String {
	var components = DateComponents()
	components.day = day
	components.month = month
	components.year = Calendar.current.component(.year, from: Date())

	guard let date = Calendar.current.date(from: components) else {
		return "\(day).\(month)"
	}

	let formatter = DateFormatter()
	formatter.setLocalizedDateFormatFromTemplate("d MMMM")
	return formatter.string(from: date)
}
