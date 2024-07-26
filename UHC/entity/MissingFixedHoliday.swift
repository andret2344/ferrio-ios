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
	let holidayId: Int?
	let reportState: ReportState

	enum CodingKeys: CodingKey {
		case id, userId, name, description, day, month, holidayId, reportState
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		userId = try container.decode(String.self, forKey: .userId)
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		day = Int(try container.decode(String.self, forKey: .day))!
		month = Int(try container.decode(String.self, forKey: .month))!
		holidayId = try container.decode(Int?.self, forKey: .holidayId)
		reportState = try container.decode(ReportState.self, forKey: .reportState)
	}

	init(id: Int, userId: String, name: String, description: String, day: Int, month: Int, holidayId: Int?, reportState: ReportState) {
		self.id = id
		self.userId = userId
		self.name = name
		self.description = description
		self.day = day
		self.month = month
		self.holidayId = holidayId
		self.reportState = reportState
	}
}
