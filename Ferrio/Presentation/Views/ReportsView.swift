//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct ReportsView: View {
	@EnvironmentObject var viewModel: AuthenticationViewModel

	var body: some View {
		List {
			Section(header: Text("suggestions")) {
				NavigationLink {
					SuggestHolidayScreenView()
				} label: {
					Label("suggest-holiday", systemImage: "pencil")
				}
				NavigationLink {
					MySuggestionsScreenView()
				} label: {
					Label("my-suggestions", systemImage: "checkmark")
				}
			}
			.disabled(viewModel.isAnonymous)
			Section(header: Text("errors")) {
				NavigationLink {
					MyReportsScreenView()
				} label: {
					Label("my-reports", systemImage: "calendar.badge.exclamationmark")
				}
			}
			.disabled(viewModel.isAnonymous)
		}
	}
}
