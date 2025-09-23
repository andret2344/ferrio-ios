//
//  Created by Andrzej Chmiel on 19/07/2024.
//

import Foundation

protocol MissingHolidayPayload : Encodable {
	var name: String {get}
	var description: String {get}
	var userId: String {get}
}

struct MissingFixedHolidayPayload : MissingHolidayPayload {
	var name: String
	var description: String
	var userId: String
	var country: String?
	var day: Int
	var month: Int
}

struct MissingFloatingHolidayPayload : MissingHolidayPayload {
	var name: String
	var description: String
	var userId: String
	var country: String?
	var date: String
}
