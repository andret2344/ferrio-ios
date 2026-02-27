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

	/// Copies values written by the iOS Settings bundle (UserDefaults.standard)
	/// into the app group suite so the app and widget see them.
	/// Also persists the resolved API language so the widget (separate process) can read it.
	func syncFromSettingsBundle() {
		let standard = UserDefaults.standard
		if let value = standard.object(forKey: "includeUsual") as? Bool {
			includeUsual = value
		}
		if let value = standard.object(forKey: "colorizedDays") as? Bool {
			colorizedDays = value
		}
		ObservableConfig.sharedDefaults?.set(API.language, forKey: "language")
	}

	static var isRealUserLoggedIn: Bool {
		get { sharedDefaults?.bool(forKey: "isRealUserLoggedIn") ?? false }
		set { sharedDefaults?.set(newValue, forKey: "isRealUserLoggedIn") }
	}

	private init() {}
}
