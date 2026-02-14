//
//  Created by Andrzej Chmiel on 09/07/2024.
//

import Foundation

extension Encodable {
	var prettyPrint: String? {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		guard let data = try? encoder.encode(self) else { return nil }
		return String(data: data, encoding: .utf8) ?? nil
	}
}
