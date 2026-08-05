//
//  Created by Andrzej Chmiel on 19/02/2026.
//

import Foundation

struct HolidayDTO: Decodable {
	let id: String
	let day: Int
	let month: Int
	let name: String
	let usual: Bool
	let description: String
	let country: String?
	let url: String
	let matureContent: Bool
	/// Optional so that a response predating the flag still decodes instead of failing the whole load.
	let aiGenerated: Bool?

	enum CodingKeys: String, CodingKey {
		case id, day, month, name, usual, description, country, url
		case matureContent = "mature_content"
		case aiGenerated = "ai_generated"
	}

	var toHoliday: Holiday {
		Holiday(id: id, usual: usual, name: name, description: description, url: url, countryCode: country, matureContent: matureContent, aiGenerated: aiGenerated ?? false)
	}
}
