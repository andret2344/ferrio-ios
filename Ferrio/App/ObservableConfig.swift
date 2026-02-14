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

	static var isRealUserLoggedIn: Bool {
		get { sharedDefaults?.bool(forKey: "isRealUserLoggedIn") ?? false }
		set { sharedDefaults?.set(newValue, forKey: "isRealUserLoggedIn") }
	}

	private init() {}
}
