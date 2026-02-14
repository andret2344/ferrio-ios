//
// Created by Andrzej Chmiel on 13/02/2026.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
	@Published var fetching: Bool = true
	@Published var holidayDays = [HolidayDay]()
	@Published var error: Bool = false

	private let repository = HolidayRepository()

	var allHolidaysCount: Int {
		holidayDays.reduce(0) { $0 + $1.holidays.count }
	}

	func loadData() async {
		defer { fetching = false }
		do {
			fetching = true
			error = false

			holidayDays = try await repository.fetchHolidays(language: API.language)
		} catch {
			self.error = true
			holidayDays = []
		}
	}
}
