//
//  Created by Claude on 08/07/2026.
//

import SwiftUI

struct SendingOverlayView: View {
	var body: some View {
		ZStack {
			Color.black.opacity(0.35)
				.ignoresSafeArea()
			VStack(spacing: 16) {
				ProgressView()
					.progressViewStyle(.circular)
					.controlSize(.large)
				Text("sending")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.padding(28)
			.background(.regularMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 16))
		}
		.transition(.opacity)
		.allowsHitTesting(true)
	}
}
