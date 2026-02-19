//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

class ObservableConfig: ObservableObject {
	static let shared = ObservableConfig()
	static let appGroupId = "group.eu.andret.uhc"
	static let sharedDefaults = UserDefaults(suiteName: appGroupId)

	@AppStorage("includeUsual", store: ObservableConfig.sharedDefaults) var includeUsual: Bool = false
	@AppStorage("colorizedDays", store: ObservableConfig.sharedDefaults) var colorizedDays: Bool = false
	@Published var favoriteIds: Set<String> = []

	static var isRealUserLoggedIn: Bool {
		get { sharedDefaults?.bool(forKey: "isRealUserLoggedIn") ?? false }
		set { sharedDefaults?.set(newValue, forKey: "isRealUserLoggedIn") }
	}

	func isFavorite(_ holiday: Holiday) -> Bool {
		favoriteIds.contains(holiday.id)
	}

	func toggleFavorite(_ holiday: Holiday) {
		if favoriteIds.contains(holiday.id) {
			favoriteIds.remove(holiday.id)
		} else {
			favoriteIds.insert(holiday.id)
		}
		saveFavorites()
	}

	private func saveFavorites() {
		Self.sharedDefaults?.set(Array(favoriteIds), forKey: "favoriteHolidayIds")
	}

	private func loadFavorites() {
		let ids = Self.sharedDefaults?.stringArray(forKey: "favoriteHolidayIds") ?? []
		favoriteIds = Set(ids)
	}

	private init() {
		loadFavorites()
	}
}
