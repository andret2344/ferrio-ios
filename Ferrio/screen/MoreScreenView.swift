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
				Section(header: Text("reports")) {
					NavigationLink {
						MissingHolidayScreenView()
					} label: {
						Label("missing-holiday", systemImage: "pencil")
					}
					NavigationLink {
						SuggestionsScreenView()
					} label: {
						Label("my-suggestions", systemImage: "checkmark")
					}
					NavigationLink {
						ReportsScreenView()
					} label: {
						Label("my-reports", systemImage: "calendar.badge.exclamationmark")
					}
				}
				.disabled(Auth.auth().currentUser?.isAnonymous ?? true)
				Section(header: Text("application")) {
					Button(action: {
						infoAlert = true
					}) {
						Label("about-calendar", systemImage: "info")
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
					}
					.buttonStyle(PlainButtonStyle())
					.alert("about-calendar", isPresented: $infoAlert, actions: {}, message: {
						Text("about-holidays")
					})
					Button(action: {
						logoutAlert = true
					}) {
						Label("log-out", systemImage: "rectangle.portrait.and.arrow.right")
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							.foregroundStyle(Color(.systemRed))
					}
					.buttonStyle(PlainButtonStyle())
					.alert("log-out", isPresented: $logoutAlert) {
						Button("cancel", role: .cancel) {
							logoutAlert = false
						}
						Button("log-out", role: .destructive) {
							viewModel.signOut()
						}
					} message: {
						Text("logout-confirm")
					}
				}
			}
			.navigationTitle("more")
		}
	}
}
