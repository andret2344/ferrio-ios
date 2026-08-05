//
// Created by Andrzej Chmiel on 03/08/2026.
//

import Foundation

/// The last successful `/holidays` response, kept in the app group so a failed refresh can show
/// what the widget already knew instead of a blank day.
///
/// Only one day is retained on purpose: the widget asks for a single date, and a cached entry for
/// some other date would be worse than showing nothing. The raw response is stored rather than a
/// decoded model — `Holiday` is not `Codable`, and keeping the bytes means the cache cannot drift
/// away from what the API actually said.
enum HolidayDayCache {
	private static let payloadKey = "widgetCachedHolidayPayload"
	private static let dayKey = "widgetCachedHolidayDay"

	static func store(_ payload: Data, forDay day: String) {
		guard let defaults = ObservableConfig.sharedDefaults else { return }
		defaults.set(payload, forKey: payloadKey)
		defaults.set(day, forKey: dayKey)
	}

	static func payload(forDay day: String) -> Data? {
		guard let defaults = ObservableConfig.sharedDefaults,
			  defaults.string(forKey: dayKey) == day else { return nil }
		return defaults.data(forKey: payloadKey)
	}
}
