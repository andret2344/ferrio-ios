//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI
import FirebaseAuth

struct ReportScreenView: View {
	var body: some View {
		NavigationView {
			List {
				NavigationLink {
					MissingHolidayScreenView()
				} label: {
					Label("Missing holiday?", systemImage: "pencil")
				}
				NavigationLink {
					SuggestionsScreenView()
				} label: {
					Label("My suggestions", systemImage: "checkmark")
				}
				NavigationLink {
					MissingHolidayScreenView()
				} label: {
					Label("My reports", systemImage: "calendar.badge.exclamationmark")
				}
				.disabled(true)
			}
			.disabled(Auth.auth().currentUser?.isAnonymous ?? true)
			.navigationTitle("Reports")
		}
		.scrollDisabled(true)
	}
}
