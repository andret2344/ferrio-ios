//
// Created by Andrzej Chmiel on 02/08/2026.
//

import SwiftUI

struct FaqScreenView: View {
	var body: some View {
		List(FaqCatalog.entries) { entry in
			DisclosureGroup {
				Text(entry.answer)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.padding(.top, 4)
			} label: {
				Text(entry.question)
					.font(.headline)
			}
		}
		.navigationTitle("faq")
		.navigationBarTitleDisplayMode(.large)
	}
}
