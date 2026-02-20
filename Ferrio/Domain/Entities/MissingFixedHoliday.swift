//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import Foundation

struct MissingFixedHoliday: Decodable {
	let id: Int
	let userId: String
	let name: String
	let description: String
	let day: Int
	let month: Int
	let datetime: String
	let holidayId: Int?
	let reportState: ReportState

	enum CodingKeys: CodingKey {
		case id, userId, name, description, day, month, datetime, holidayId, reportState
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		userId = try container.decode(String.self, forKey: .userId)
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		day = try container.decode(Int.self, forKey: .day)
		month = try container.decode(Int.self, forKey: .month)
		datetime = try container.decode(String.self, forKey: .datetime)
		holidayId = try container.decodeIfPresent(Int.self, forKey: .holidayId)
		reportState = try container.decode(ReportState.self, forKey: .reportState)
	}
}
