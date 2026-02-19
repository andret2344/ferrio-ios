//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import Foundation

struct Holiday: Identifiable, Equatable {
	let id: String
	let usual: Bool
	let name: String
	let description: String
	let url: String
	let countryCode: String?
	let matureContent: Bool?

	var numericId: Int {
		Int(id.split(separator: "-").last.flatMap { String($0) } ?? "0") ?? 0
	}

	var isFloating: Bool {
		id.hasPrefix("floating")
	}

	var flagEmoji: String? {
		guard let code = countryCode, code.count == 2 else { return nil }
		let base: UInt32 = 0x1F1E6 - 65
		let flag = code.uppercased().unicodeScalars.compactMap {
			UnicodeScalar(base + $0.value).map(String.init)
		}.joined()
		return flag
	}

	var nameWithFlag: String {
		if let flag = flagEmoji {
			return "\(name) \(flag)"
		}
		return name
	}

	var countryName: String? {
		guard let code = countryCode, code.count == 2 else { return nil }
		return Locale.current.localizedString(forRegionCode: code)
	}
}
