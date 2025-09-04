//
// Created by Andrzej Chmiel on 14/10/2023.
//

import Foundation

extension String {
	func localized() -> String {
		NSLocalizedString(
			self,
			tableName: "Localizable",
			bundle: .main,
			value: self,
			comment: self)
	}

	func norm() -> String {
		self.folding(options: .diacriticInsensitive, locale: .current).lowercased()
	}
}
