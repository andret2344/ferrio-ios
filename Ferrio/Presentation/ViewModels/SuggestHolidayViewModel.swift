//
//  Created by Claude on 14/02/2026.
//

import FirebaseAuth
import Foundation

@MainActor
class SuggestHolidayViewModel: ObservableObject {
	@Published var countries: [Locale.Region]? = nil
	@Published var sortedCountries: [Locale.Region] = []
	@Published var showAlert: Bool = false
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

	func sendMissingSuggestion(payload: MissingHolidayPayload, path: String) async {
		do {
			try await repository.sendMissingSuggestion(payload: payload, path: path)
			alertMessage = "suggestion-sent-description".localized()
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
