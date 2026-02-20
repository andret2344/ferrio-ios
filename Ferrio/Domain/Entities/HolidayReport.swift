//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import Foundation

struct HolidayReport: Decodable {
	let id: Int
	let languageCode: String
	let metadataId: Int
	let reportType: String
	let description: String
	let datetime: String
	let reportState: ReportState

	enum CodingKeys: CodingKey {
		case id, languageCode, metadataId, reportType, description, datetime, reportState
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		languageCode = try container.decode(String.self, forKey: .languageCode)
		metadataId = try container.decode(Int.self, forKey: .metadataId)
		reportType = try container.decode(String.self, forKey: .reportType)
		description = try container.decode(String.self, forKey: .description)
		datetime = try container.decode(String.self, forKey: .datetime)
		reportState = try container.decode(ReportState.self, forKey: .reportState)
	}
}
