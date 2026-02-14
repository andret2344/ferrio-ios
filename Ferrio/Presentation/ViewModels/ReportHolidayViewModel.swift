//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class ReportHolidayViewModel: ObservableObject {
	@Published var showAlert: Bool = false
	@Published var alertMessage: String = ""
	@Published var success: Bool = false

	private let repository = HolidayRepository()

	func sendReport(reportPayload: HolidayReportPayload, path: String) async {
		do {
			try await repository.sendReport(reportPayload: reportPayload, path: path)
			alertMessage = "sent"
			success = true
		} catch let error as APIError {
			alertMessage = error.localizedDescription
		} catch is EncodingError {
			alertMessage = "invalid-data-format".localized()
		} catch {
			alertMessage = "could-not-connect".localized()
		}
		showAlert = true
	}
}
