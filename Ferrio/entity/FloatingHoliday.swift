//
// Created by Andrzej Chmiel on 14/09/2023.
//

import Foundation

struct FloatingHoliday: Identifiable, Decodable {
	let id: Int
	let usual: Bool
	let name: String
	let description: String
	let url: String
	let script: String
	let countryCode: String?
	let category: String?
	let matureContent: Bool?

	enum CodingKeys: CodingKey {
		case id, usual, name, description, url, script, countryCode, category, matureContent
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		usual = try container.decode(Bool.self, forKey: .usual)
		name = try container.decode(String.self, forKey: .name)
		description = try container.decode(String.self, forKey: .description)
		url = try container.decode(String.self, forKey: .url)
		script = try container.decode(String.self, forKey: .script)
		countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
		category = try container.decodeIfPresent(String.self, forKey: .category)
		matureContent = try container.decodeIfPresent(Bool.self, forKey: .matureContent)
	}

	init(id: Int, usual: Bool, name: String, description: String, url: String, script: String, countryCode: String?, category: String?, matureContent: Bool?) {
		self.id = id
		self.usual = usual
		self.name = name
		self.description = description
		self.url = url
		self.script = script
		self.countryCode = countryCode
		self.category = category
		self.matureContent = matureContent
	}
}
