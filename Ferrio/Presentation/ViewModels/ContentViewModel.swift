//
// Created by Andrzej Chmiel on 13/02/2026.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
	@Published var fetching: Bool = true
	@Published var holidayDays = [HolidayDay]()
	/// Holds the reason, not just the fact: `APIError` already carries a localized description
	/// (status code, "not authenticated", …) and the alert used to throw it away.
	@Published var errorMessage: String?

	var hasError: Bool {
		get { errorMessage != nil }
		set { if !newValue { errorMessage = nil } }
	}

	private let repository = HolidayRepository()

	var allHolidaysCount: Int {
		holidayDays.reduce(0) { $0 + $1.holidays.count }
	}

	func loadData() async {
		defer { fetching = false }
		do {
			fetching = true
			errorMessage = nil

			holidayDays = try await repository.fetchHolidays(
				language: API.language,
				includeMatureContent: ObservableConfig.shared.showAdultContent
			)
		} catch {
			errorMessage = error.localizedDescription
			holidayDays = []
		}
	}
}
