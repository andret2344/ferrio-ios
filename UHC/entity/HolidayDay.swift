//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import Foundation

struct HolidayDay: Identifiable, Decodable {
	let id: String;
	let day: Int
	let month: Int
	let holidays: [Holiday]

	enum CodingKeys: String, CodingKey {
		case id, day, month, holidays
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		day = try values.decode(Int.self, forKey: .day)
		month = try values.decode(Int.self, forKey: .month)
		holidays = try values.decode([Holiday].self, forKey: .holidays)
	}

	init(id: String, day: Int, month: Int, holidays: [Holiday]) {
		self.id = id
		self.day = day
		self.month = month
		self.holidays = holidays
	}

	func getDate() -> String {
		String(format: "%02d", day) + "." + String(format: "%02d", month)
	}

	func getHolidays(includeUsualHolidays: Bool) -> [Holiday] {
		if includeUsualHolidays {
			return holidays
		}
		return holidays.filter { holiday in
			!holiday.usual
		}
	}
}
