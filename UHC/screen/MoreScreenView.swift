//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI
import FirebaseAuth

struct MoreScreenView: View {
	@State private var infoAlert = false
	@State private var logoutAlert = false
	@EnvironmentObject var viewModel: AuthenticationViewModel

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
					Button(action: {
						infoAlert = true
					}) {
						Label("About calendar", systemImage: "info")
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
					}
					.buttonStyle(PlainButtonStyle())
					.alert("About calendar", isPresented: $infoAlert, actions: {}, message: {
						Text("All holidays - even those most unusual - are an opportunity to look in a different way at people, and appreciate phenomena we usually ignore.")
					})
					Button(action: {
						logoutAlert = true
					}) {
						Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							.foregroundStyle(Color(.systemRed))
					}
					.buttonStyle(PlainButtonStyle())
					.alert("Logout", isPresented: $logoutAlert) {
						Button("Cancel", role: .cancel) {
							logoutAlert = false
						}
						Button("Logout", role: .destructive) {
							viewModel.signOut()
						}
					} message: {
						Text("Are you sure you want to log out?")
					}
				}
			}
			.navigationTitle("More")
		}
	}
}
