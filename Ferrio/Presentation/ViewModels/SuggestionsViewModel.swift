//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class SuggestionsViewModel: ObservableObject {
	@Published var suggestionsFixed: [MissingFixedHoliday] = []
	@Published var suggestionsFloating: [MissingFloatingHoliday] = []
	@Published var isLoading = true
	@Published var error: Error? = nil

	private let repository = HolidayRepository()

	func fetchData() async {
		isLoading = true
		error = nil
		do {
			let result = try await repository.fetchSuggestions()
			suggestionsFixed = result.fixed.sorted { $0.datetime > $1.datetime }
			suggestionsFloating = result.floating.sorted { $0.datetime > $1.datetime }
		} catch {
			suggestionsFixed = []
			suggestionsFloating = []
			self.error = error
		}
		isLoading = false
	}
}
