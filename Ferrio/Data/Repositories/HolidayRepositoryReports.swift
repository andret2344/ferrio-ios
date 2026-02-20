//
//  Created by Claude on 14/02/2026.
//

import Foundation

extension HolidayRepository {
	private static let reportsURL = "\(API.baseURL)/users/reports"

	func fetchReports() async throws -> (fixed: [HolidayReport], floating: [HolidayReport]) {
		guard let fixedURL = URL(string: "\(Self.reportsURL)?reportType=error&holidayType=fixed"),
			  let floatingURL = URL(string: "\(Self.reportsURL)?reportType=error&holidayType=floating") else {
			throw APIError.invalidURL
		}
		let fixed = try await URLSession.shared.authenticatedDecode(
			[HolidayReport].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		let floating = try await URLSession.shared.authenticatedDecode(
			[HolidayReport].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return (fixed, floating)
	}

	func fetchSuggestions() async throws -> (fixed: [MissingFixedHoliday], floating: [MissingFloatingHoliday]) {
		guard let fixedURL = URL(string: "\(Self.reportsURL)?reportType=suggestion&holidayType=fixed"),
			  let floatingURL = URL(string: "\(Self.reportsURL)?reportType=suggestion&holidayType=floating") else {
			throw APIError.invalidURL
		}
		let fixed = try await URLSession.shared.authenticatedDecode(
			[MissingFixedHoliday].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		let floating = try await URLSession.shared.authenticatedDecode(
			[MissingFloatingHoliday].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return (fixed, floating)
	}

	func fetchCountries() async throws -> [Locale.Region] {
		guard let url = URL(string: "https://api.ferrio.app/v2/countries?format=code") else {
			throw APIError.invalidURL
		}
		let codes = try await URLSession.shared.decode(
			[String].self,
			from: url
		)
		return codes.compactMap { Locale.Region($0) }
	}

	func sendReport(payload: HolidayReportPayload, holidayType: String) async throws {
		guard let url = URL(string: "\(Self.reportsURL)?reportType=error&holidayType=\(holidayType)") else {
			throw APIError.invalidURL
		}
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		let jsonData = try encoder.encode(payload)
		try await URLSession.shared.authenticatedPost(jsonData: jsonData, url: url)
	}

	func sendMissingSuggestion(payload: MissingHolidayPayload, holidayType: String) async throws {
		guard let url = URL(string: "\(Self.reportsURL)?reportType=suggestion&holidayType=\(holidayType)") else {
			throw APIError.invalidURL
		}
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		let jsonData = try encoder.encode(payload)
		try await URLSession.shared.authenticatedPost(jsonData: jsonData, url: url)
	}
}
