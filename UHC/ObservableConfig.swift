//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

class ObservableConfig: ObservableObject {
	@AppStorage("includeUsualHolidays")
	var includeUsualHolidays: Bool = true
}
