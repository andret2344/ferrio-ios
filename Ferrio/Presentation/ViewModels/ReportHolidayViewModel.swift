//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class ReportHolidayViewModel: ObservableObject {
	@Published var showAlert: Bool = false
	@Published var alertTitle: String = ""
	@Published var alertMessage: String = ""
	@Published var success: Bool = false

	private let repository = HolidayRepository()

	func sendReport(reportPayload: HolidayReportPayload, holidayType: String) async {
		do {
			try await repository.sendReport(payload: reportPayload, holidayType: holidayType)
			alertTitle = "report-sent".localized()
			alertMessage = "report-sent-description".localized()
			success = true
		} catch let error as APIError {
			print("[Report] APIError: \(error)")
			alertTitle = "error".localized()
			alertMessage = error.localizedDescription
		} catch let error as EncodingError {
			print("[Report] EncodingError: \(error)")
			alertTitle = "error".localized()
			alertMessage = "invalid-data-format".localized()
		} catch {
			print("[Report] Error: \(error)")
			alertTitle = "error".localized()
			alertMessage = "could-not-connect".localized()
		}
		showAlert = true
	}
}
