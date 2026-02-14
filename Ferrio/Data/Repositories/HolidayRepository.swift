//
// Created by Andrzej Chmiel on 13/02/2026.
//

import Foundation
import JavaScriptCore

class HolidayRepository {
	func fetchHolidays(language: String) async throws -> [HolidayDay] {
		let url = try getUrl(language: language)
		var unusualCalendar: UnusualCalendar = try await URLSession.shared.decode(UnusualCalendar.self, from: url)

		guard let context = JSContext() else {
			throw HolidayRepositoryError.jsContextCreationFailed
		}

		for holiday in unusualCalendar.floating {
			guard let result = context.evaluateScript(holiday.script),
				  !result.isUndefined,
				  !result.isNull,
				  let (day, month) = parseDayMonth(from: result)
			else {
				continue
			}

			unusualCalendar.add(
				day: day,
				month: month,
				holiday: Holiday(floatingHoliday: holiday)
			)
		}

		return unusualCalendar.fixed
	}

	private func getUrl(language: String) throws -> URL {
		guard let url = URL(string: "\(API.baseURL)/holiday/\(language)") else {
			throw APIError.invalidURL
		}
		return url
	}

	private func parseDayMonth(from value: JSValue) -> (day: Int, month: Int)? {
		// Object: { day: 3, month: 8 }
		if value.isObject,
		   let day: Int = value.forProperty("day")?.toNumber()?.intValue,
		   let month: Int = value.forProperty("month")?.toNumber()?.intValue,
		   valid(day: day, month: month) {
			return (day, month)
		}

		// Array: [3, 8]
		if value.isArray,
		   let arr: [Any] = value.toArray(),
		   arr.count >= 2,
		   let day = (arr[0] as? NSNumber).map({ $0.intValue }),
		   let month = (arr[1] as? NSNumber).map({ $0.intValue }),
		   valid(day: day, month: month) {
			return (day, month)
		}

		// String: "3.8" / "03.08"
		let parts = value.toString().split(separator: ".", omittingEmptySubsequences: true)
		if parts.count == 2,
		   let day = Int(parts[0]),
		   let month = Int(parts[1]),
		   valid(day: day, month: month) {
			return (day, month)
		}

		return nil
	}

	@inline(__always)
	private func valid(day: Int, month: Int) -> Bool {
		(1...31).contains(day) && (1...12).contains(month)
	}
}

enum HolidayRepositoryError: Error {
	case jsContextCreationFailed
}
