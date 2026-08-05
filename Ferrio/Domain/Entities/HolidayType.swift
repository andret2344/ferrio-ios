//
// Created by Andrzej Chmiel on 03/08/2026.
//

import Foundation

/// The `holidayType` query parameter of `/users/reports`. Raw values are the API's spelling —
/// they used to be passed around as bare strings, where a typo produced a 4xx at runtime instead
/// of a compile error.
enum HolidayType: String {
	case fixed
	case floating

	init(isFloating: Bool) {
		self = isFloating ? .floating : .fixed
	}
}

/// The `reportType` query parameter of the same endpoint. An error report and a missing-holiday
/// suggestion share one route and differ only by this value.
///
/// Deliberately **not** called `ReportType`: that name is already taken by the payload field in
/// `HolidayReportPayload`, which describes what is wrong with a holiday (`WRONG_NAME`, …). The API
/// reuses one word for two unrelated things; the code does not have to.
enum ReportCategory: String {
	case error
	case suggestion
}
