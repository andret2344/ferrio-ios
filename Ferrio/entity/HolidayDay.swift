//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import Foundation

struct HolidayDay: Identifiable, Decodable, Equatable {
	let id: String;
	let day: Int
	let month: Int
	var holidays: [Holiday]

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

	init(day: Int, month: Int, holidays: [Holiday]) {
		self.init(id: String(format: "%02d", month) + String(format: "%02d", day), day: day, month: month, holidays: holidays)
	}

	static func ==(lhs: HolidayDay, rhs: HolidayDay) -> Bool {
		lhs.id == rhs.id &&
		lhs.day == rhs.day &&
		lhs.month == rhs.month &&
		lhs.holidays == rhs.holidays
	}

	func getDate() -> String {
		String(format: "%02d", day) + "." + String(format: "%02d", month)
	}

	func getHolidays(includeUsual: Bool) -> [Holiday] {
		if includeUsual {
			return holidays
		}
		return holidays.filter { holiday in
			!holiday.usual
		}
	}
}
