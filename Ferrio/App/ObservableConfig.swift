//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

class ObservableConfig: ObservableObject {
	@AppStorage("includeUsual") var includeUsual: Bool = false
	@AppStorage("colorizedDays") var colorizedDays: Bool = false
}
