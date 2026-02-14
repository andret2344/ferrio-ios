//
// Created by Andrzej Chmiel on 14/09/2023.
//

import Foundation

struct UnusualCalendar: Decodable {
	var fixed: [HolidayDay]
	let floating: [FloatingHoliday]

	enum CodingKeys: CodingKey {
		case fixed, floating
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		fixed = try container.decode([HolidayDay].self, forKey: .fixed)
		floating = try container.decode([FloatingHoliday].self, forKey: .floating)
	}

	init(fixed: [HolidayDay], floating: [FloatingHoliday]) {
		self.fixed = fixed
		self.floating = floating
	}

	mutating func add(day: Int, month: Int, holiday: Holiday) {
		if let index = fixed.firstIndex(where: { $0.day == day && $0.month == month }) {
			fixed[index].holidays.append(holiday)
		} else {
			fixed.append(HolidayDay(day: day, month: month, holidays: [holiday]))
		}
	}
}
