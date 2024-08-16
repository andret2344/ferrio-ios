//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI
import FirebaseAuth

struct ReportScreenView: View {
	@State private var showingAlert = false

	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Reports")) {
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
						ReportsScreenView()
					} label: {
						Label("My reports", systemImage: "calendar.badge.exclamationmark")
					}
				}
				.disabled(Auth.auth().currentUser?.isAnonymous ?? true)
				Section(header: Text("Application")) {
					Label("About calendar", systemImage: "info")
						.contentShape(Rectangle())
						.onTapGesture {
							showingAlert = true
						}
						.alert("About calendar", isPresented: $showingAlert, actions: {}, message: {
							Image("SadIcon")
							Text("All holidays - even those most unusual - are an opportunity to look in a different way at people, and appreciate phenomena we usually ignore.")
						})
				}
			}
			.navigationTitle("Reports")
		}
		.scrollDisabled(true)
	}
}
