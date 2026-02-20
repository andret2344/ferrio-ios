//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class SuggestHolidayViewModel: ObservableObject {
	@Published var countries: [Locale.Region]? = nil
	@Published var sortedCountries: [Locale.Region] = []
	@Published var showAlert: Bool = false
	@Published var alertTitle: String = ""
	@Published var alertMessage: String = ""
	@Published var success: Bool = false

	private let repository = HolidayRepository()

	func fetchCountries() async {
		do {
			let fetched = try await repository.fetchCountries()
			countries = fetched
			sortedCountries = fetched.sorted { lhs, rhs in
				let lName = Locale.current.localizedString(forRegionCode: lhs.identifier) ?? lhs.identifier
				let rName = Locale.current.localizedString(forRegionCode: rhs.identifier) ?? rhs.identifier
				return lName < rName
			}
		} catch {
			countries = []
			sortedCountries = []
		}
	}

	func sendMissingSuggestion<T: MissingHolidayPayload>(payload: T, holidayType: String) async {
		do {
			try await repository.sendMissingSuggestion(payload: payload, holidayType: holidayType)
			alertTitle = "suggestion-sent".localized()
			alertMessage = "suggestion-sent-description".localized()
			success = true
		} catch let error as APIError {
			print("[Suggestion] APIError: \(error)")
			alertTitle = "error".localized()
			alertMessage = error.localizedDescription
		} catch let error as EncodingError {
			print("[Suggestion] EncodingError: \(error)")
			alertTitle = "error".localized()
			alertMessage = "invalid-data-format".localized()
		} catch {
			print("[Suggestion] Error: \(error)")
			alertTitle = "error".localized()
			alertMessage = "could-not-connect".localized()
		}
		showAlert = true
	}
}
