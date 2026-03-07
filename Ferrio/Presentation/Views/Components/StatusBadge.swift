//
//  Created by Andrzej Chmiel on 07/03/2026.
//

import SwiftUI

struct StatusBadge: View {
	let state: ReportState

	var body: some View {
		Text(state.rawValue.localized())
			.font(.caption)
			.fontWeight(.medium)
			.foregroundStyle(state.color)
			.padding(.horizontal, 10)
			.padding(.vertical, 4)
			.background(
				RoundedRectangle(cornerRadius: 6)
					.fill(state.color.opacity(0.12))
			)
	}
}
