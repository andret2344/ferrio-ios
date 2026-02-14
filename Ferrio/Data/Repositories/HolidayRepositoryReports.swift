//
//  Created by Claude on 14/02/2026.
//

import Foundation

extension HolidayRepository {
	func fetchReports(uid: String) async throws -> (fixed: [HolidayReport], floating: [HolidayReport]) {
		guard let fixedURL = URL(string: "\(API.baseURL)/report/\(uid)/fixed"),
			  let floatingURL = URL(string: "\(API.baseURL)/report/\(uid)/floating") else {
			throw APIError.invalidURL
		}
		let fixed = try await URLSession.shared.decode(
			[HolidayReport].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		let floating = try await URLSession.shared.decode(
			[HolidayReport].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return (fixed, floating)
	}

	func fetchSuggestions(uid: String) async throws -> (fixed: [MissingFixedHoliday], floating: [MissingFloatingHoliday]) {
		guard let fixedURL = URL(string: "\(API.baseURL)/missing/\(uid)/fixed"),
			  let floatingURL = URL(string: "\(API.baseURL)/missing/\(uid)/floating") else {
			throw APIError.invalidURL
		}
		let fixed = try await URLSession.shared.decode(
			[MissingFixedHoliday].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		let floating = try await URLSession.shared.decode(
			[MissingFloatingHoliday].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return (fixed, floating)
	}

	func fetchCountries() async throws -> [Locale.Region] {
		guard let url = URL(string: "\(API.baseURL)/countries?format=code") else {
			throw APIError.invalidURL
		}
		let codes = try await URLSession.shared.decode(
			[String].self,
			from: url
		)
		return codes.compactMap { Locale.Region($0) }
	}

	func sendReport(reportPayload: HolidayReportPayload, path: String) async throws {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		let jsonData = try encoder.encode(reportPayload)
		try await URLSession.shared.sendRequest(jsonData: jsonData, path: path)
	}

	func sendMissingSuggestion(payload: MissingHolidayPayload, path: String) async throws {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		let jsonData = try encoder.encode(payload)
		try await URLSession.shared.sendRequest(jsonData: jsonData, path: path)
	}
}
