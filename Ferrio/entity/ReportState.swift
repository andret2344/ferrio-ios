//
//  Created by Andrzej Chmiel on 26/07/2024.
//

import Foundation

enum ReportState: String, Codable {
	case REPORTED = "REPORTED"
	case APPLIED = "APPLIED"
	case DECLINED = "DECLINED"
	case ON_HOLD = "ON_HOLD"
}
