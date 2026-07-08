//
// Created by Andrzej Chmiel on 13/02/2026.
//

import Foundation

class HolidayRepository {
	func fetchHolidays(language: String, includeMatureContent: Bool) async throws -> [HolidayDay] {
		let url = try getUrl(language: language, includeMatureContent: includeMatureContent)
		let dtos: [HolidayDTO] = try await URLSession.shared.decode(from: url)
		return Self.groupIntoHolidayDays(dtos)
	}

	private func getUrl(language: String, includeMatureContent: Bool) throws -> URL {
		var urlString = "\(API.baseURL)/holidays?lang=\(language)"
		if includeMatureContent {
			urlString += "&includeMatureContent=true"
		}
		guard let url = URL(string: urlString) else {
			throw APIError.invalidURL
		}
		return url
	}

	static func groupIntoHolidayDays(_ dtos: [HolidayDTO]) -> [HolidayDay] {
		let grouped = Dictionary(grouping: dtos) { "\($0.month)-\($0.day)" }
		return grouped.compactMap { (_, group) -> HolidayDay? in
			guard let first = group.first else { return nil }
			return HolidayDay(day: first.day, month: first.month, holidays: group.map(\.toHoliday))
		}
	}
}
