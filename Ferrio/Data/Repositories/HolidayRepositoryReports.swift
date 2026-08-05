//
//  Created by Claude on 14/02/2026.
//

import Foundation

extension HolidayRepository {
	private static let reportsPath = "\(API.baseURL)/users/reports"

	private static func endpoint(_ category: ReportCategory, _ holidayType: HolidayType) throws -> URL {
		guard let url = URL(string: "\(reportsPath)?reportType=\(category.rawValue)&holidayType=\(holidayType.rawValue)") else {
			throw APIError.invalidURL
		}
		return url
	}

	func fetchReports() async throws -> (fixed: [HolidayReport], floating: [HolidayReport]) {
		let fixedURL = try Self.endpoint(.error, .fixed)
		let floatingURL = try Self.endpoint(.error, .floating)
		// The two calls are independent, so they run concurrently — serialising them doubled the
		// time the Reports tab spends on its spinner for no reason.
		async let fixed = URLSession.shared.authenticatedDecode(
			[HolidayReport].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		async let floating = URLSession.shared.authenticatedDecode(
			[HolidayReport].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return try await (fixed, floating)
	}

	func fetchSuggestions() async throws -> (fixed: [MissingFixedHoliday], floating: [MissingFloatingHoliday]) {
		let fixedURL = try Self.endpoint(.suggestion, .fixed)
		let floatingURL = try Self.endpoint(.suggestion, .floating)
		async let fixed = URLSession.shared.authenticatedDecode(
			[MissingFixedHoliday].self,
			from: fixedURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		async let floating = URLSession.shared.authenticatedDecode(
			[MissingFloatingHoliday].self,
			from: floatingURL,
			keyDecodingStrategy: .convertFromSnakeCase
		)
		return try await (fixed, floating)
	}

	func sendReport(payload: HolidayReportPayload, holidayType: HolidayType) async throws {
		try await post(payload, to: Self.endpoint(.error, holidayType))
	}

	// Generic rather than taking the existential: `MissingHolidayPayload` refines `Encodable`, but
	// the existential itself does not conform, so `encode` needs the concrete type.
	func sendMissingSuggestion<T: MissingHolidayPayload>(payload: T, holidayType: HolidayType) async throws {
		try await post(payload, to: Self.endpoint(.suggestion, holidayType))
	}

	private func post<T: Encodable>(_ payload: T, to url: URL) async throws {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		try await URLSession.shared.authenticatedPost(jsonData: encoder.encode(payload), url: url)
	}
}
