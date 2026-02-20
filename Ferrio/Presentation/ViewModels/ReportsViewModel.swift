//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class ReportsViewModel: ObservableObject {
	@Published var reportsFixed: [HolidayReport] = []
	@Published var reportsFloating: [HolidayReport] = []

	private let repository = HolidayRepository()

	func fetchData() async {
		do {
			let result = try await repository.fetchReports()
			reportsFixed = result.fixed.sorted { $0.datetime > $1.datetime }
			reportsFloating = result.floating.sorted { $0.datetime > $1.datetime }
		} catch {
			reportsFixed = []
			reportsFloating = []
		}
	}
}
