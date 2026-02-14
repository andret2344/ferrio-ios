//
//  Created by Andrzej Chmiel on 09/08/2024.
//

import Foundation

enum ReportType: String, Encodable, CaseIterable {
	case WRONG_NAME
	case WRONG_DESCRIPTION
	case WRONG_DATE
	case OTHER
}

struct HolidayReportPayload: Encodable {
	var userId: String
	var metadata: Int
	var language: String
	var reportType: ReportType
	var description: String
}
