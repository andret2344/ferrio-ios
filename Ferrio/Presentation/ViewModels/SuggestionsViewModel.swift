//
//  Created by Claude on 14/02/2026.
//

import Foundation

@MainActor
class SuggestionsViewModel: ObservableObject {
	@Published var suggestionsFixed: [MissingFixedHoliday] = []
	@Published var suggestionsFloating: [MissingFloatingHoliday] = []

	private let repository = HolidayRepository()

	func fetchData() async {
		do {
			let result = try await repository.fetchSuggestions()
			suggestionsFixed = result.fixed.sorted { $0.datetime > $1.datetime }
			suggestionsFloating = result.floating.sorted { $0.datetime > $1.datetime }
		} catch {
			suggestionsFixed = []
			suggestionsFloating = []
		}
	}
}
