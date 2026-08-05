//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class SuggestHolidayViewModel: ObservableObject {
	@Published var sortedCountries: [Locale.Region] = []
	@Published var showAlert: Bool = false
	@Published var alertTitle: String = ""
	@Published var alertMessage: String = ""
	@Published var success: Bool = false
	@Published var isSending: Bool = false

	private let repository = HolidayRepository()

	/// The country list comes from the system's ISO 3166 table rather than from the API: it never
	/// changes between releases, needs no network round trip, and works offline. It is a superset
	/// of what `/v2/countries` used to return.
	func loadCountries() {
		sortedCountries = Locale.Region.isoRegions
			.filter { $0.identifier.count == 2 && $0.subRegions.isEmpty }
			.sorted { countryName($0) < countryName($1) }
	}

	private func countryName(_ region: Locale.Region) -> String {
		Locale.current.localizedString(forRegionCode: region.identifier) ?? region.identifier
	}

	func sendMissingSuggestion<T: MissingHolidayPayload>(payload: T, holidayType: HolidayType) async {
		guard !isSending else { return }
		isSending = true
		defer { isSending = false }
		do {
			try await repository.sendMissingSuggestion(payload: payload, holidayType: holidayType)
			alertTitle = "suggestion-sent".localized()
			alertMessage = "suggestion-sent-description".localized()
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
