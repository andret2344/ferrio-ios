//
//  Created by Claude on 14/02/2026.
//

import FirebaseAuth
import Foundation

@MainActor
class SuggestionsViewModel: ObservableObject {
	@Published var suggestionsFixed: [MissingFixedHoliday] = []
	@Published var suggestionsFloating: [MissingFloatingHoliday] = []

	private let repository = HolidayRepository()

	func fetchData() async {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		do {
			let result = try await repository.fetchSuggestions(uid: uid)
			suggestionsFixed = result.fixed
			suggestionsFloating = result.floating
		} catch {
			suggestionsFixed = []
			suggestionsFloating = []
		}
	}
}
