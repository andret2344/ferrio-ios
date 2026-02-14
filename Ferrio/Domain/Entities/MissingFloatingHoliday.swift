//
//  Created by Andrzej Chmiel on 26/07/2024.
//

import Foundation

struct MissingFloatingHoliday: Decodable {
	let id: Int
	let userId: String
	let name: String
	let description: String
	let date: String
	let holidayId: Int?
	let reportState: ReportState

	enum CodingKeys: CodingKey {
		case id, userId, name, description, date, holidayId, reportState
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		userId = try container.decode(String.self, forKey: .userId)
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		date = try container.decode(String.self, forKey: .date)
		holidayId = try container.decodeIfPresent(Int.self, forKey: .holidayId)
		reportState = try container.decode(ReportState.self, forKey: .reportState)
	}

	init(id: Int, userId: String, name: String, description: String, date: String, holidayId: Int?, reportState: ReportState) {
		self.id = id
		self.userId = userId
		self.name = name
		self.description = description
		self.date = date
		self.holidayId = holidayId
		self.reportState = reportState
	}
}
