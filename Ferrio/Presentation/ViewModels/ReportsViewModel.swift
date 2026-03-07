//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class ReportsViewModel: ObservableObject {
	@Published var reportsFixed: [HolidayReport] = []
	@Published var reportsFloating: [HolidayReport] = []
	@Published var isLoading = true
	@Published var error: Error? = nil

	private let repository = HolidayRepository()

	func fetchData() async {
		isLoading = true
		error = nil
		do {
			let result = try await repository.fetchReports()
			reportsFixed = result.fixed.sorted { $0.datetime > $1.datetime }
			reportsFloating = result.floating.sorted { $0.datetime > $1.datetime }
		} catch {
			reportsFixed = []
			reportsFloating = []
			self.error = error
		}
		isLoading = false
	}
}
