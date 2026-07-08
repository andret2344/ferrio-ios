//
//  Created by Claude on 14/02/2026.
//

import SwiftUI

extension ReportState {
	var color: Color {
		switch self {
		case .REPORTED:
			Color(UIColor.systemBlue)
		case .APPLIED:
			Color(UIColor.systemGreen)
		case .DECLINED:
			Color(UIColor.systemRed)
		case .ON_HOLD:
			Color(UIColor.systemYellow)
		case .DUPLICATE:
			Color(UIColor.systemPurple)
		case .ALREADY_EXISTS:
			Color(UIColor.systemTeal)
		case .UNKNOWN:
			Color(UIColor.systemGray)
		}
	}
}
