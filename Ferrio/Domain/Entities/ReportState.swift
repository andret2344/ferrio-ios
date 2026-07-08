//
//  Created by Andrzej Chmiel on 26/07/2024.
//

import Foundation

enum ReportState: String, Codable {
	case REPORTED = "REPORTED"
	case APPLIED = "APPLIED"
	case DECLINED = "DECLINED"
	case ON_HOLD = "ON_HOLD"
	case DUPLICATE = "DUPLICATE"
	case ALREADY_EXISTS = "ALREADY_EXISTS"
	case UNKNOWN = "UNKNOWN"

	init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		self = ReportState(rawValue: raw) ?? .UNKNOWN
	}
}
