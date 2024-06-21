//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import Foundation

struct Holiday: Identifiable, Decodable, Equatable {
	let id: Int
	let usual: Bool
	let name: String
	let description: String
	let url: String

	enum CodingKeys: CodingKey {
		case id, usual, name, description, url
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		usual = try container.decode(Bool.self, forKey: .usual)
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		url = try container.decode(String.self, forKey: .url)
	}

	init(id: Int, usual: Bool, name: String, description: String, url: String) {
		self.id = id
		self.usual = usual
		self.name = name
		self.description = description
		self.url = url
	}

	init(floatingHoliday: FloatingHoliday) {
		id = -floatingHoliday.id
		usual = floatingHoliday.usual
		name = floatingHoliday.name
		description = floatingHoliday.description
		url = floatingHoliday.url
	}

	static func ==(lhs: Holiday, rhs: Holiday) -> Bool {
		lhs.id == rhs.id &&
		lhs.usual == rhs.usual &&
		lhs.name == rhs.name &&
		lhs.description == rhs.description &&
		lhs.url == rhs.url
	}
}
