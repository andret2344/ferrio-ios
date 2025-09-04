//
//  Created by Andrzej Chmiel on 04/09/2025.
//

import Foundation
import SwiftData

@Model
class Favorite {
	var holidayId: Int

	init(holidayId: Int) {
		self.holidayId = holidayId
	}
}
