//
//  Created by Claude on 14/02/2026.
//

import FirebaseAuth
import Foundation

@MainActor
class ReportsViewModel: ObservableObject {
	@Published var reportsFixed: [HolidayReport] = []
	@Published var reportsFloating: [HolidayReport] = []

	private let repository = HolidayRepository()

	func fetchData() async {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		do {
			let result = try await repository.fetchReports(uid: uid)
			reportsFixed = result.fixed
			reportsFloating = result.floating
		} catch {
			reportsFixed = []
			reportsFloating = []
		}
	}
}
