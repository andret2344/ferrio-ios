//
//  Created by Andrzej Chmiel on 09/08/2024.
//

import Foundation

struct HolidayReportPayload: Encodable {
	var userId: String
	var metadata: Int
	var language: String
	var reportType: String
	var description: String
}
