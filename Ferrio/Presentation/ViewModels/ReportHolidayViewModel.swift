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
	@Published var isSending: Bool = false

	private let repository = HolidayRepository()

	func sendReport(reportPayload: HolidayReportPayload, holidayType: HolidayType) async {
		guard !isSending else { return }
		isSending = true
		defer { isSending = false }
		do {
			try await repository.sendReport(payload: reportPayload, holidayType: holidayType)
			alertTitle = "report-sent".localized()
			alertMessage = "report-sent-description".localized()
			success = true
		} catch let error as APIError {
			alertTitle = "error".localized()
			alertMessage = error.localizedDescription
		} catch is EncodingError {
			alertTitle = "error".localized()
			alertMessage = "invalid-data-format".localized()
		} catch {
			alertTitle = "error".localized()
			alertMessage = "could-not-connect".localized()
		}
		showAlert = true
	}
}
