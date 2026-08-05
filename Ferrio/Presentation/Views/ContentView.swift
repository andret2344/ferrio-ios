//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@State private var searchText = ""
	@State private var selectedDay: HolidayDay?

	var body: some View {
		renderView()
			.task(id: Locale.current.identifier) { await viewModel.loadData() }
			.alert("error", isPresented: $viewModel.hasError) {
				Button("retry") { Task { await viewModel.loadData() } }
				Button("ok", role: .cancel) {}
			} message: {
				Text(loadErrorMessage)
			}
	}

	/// Alerts render a single message view, so the concrete reason is appended to the generic line
	/// — a 503 no longer looks the same as being offline. Assembled as a plain `String`: the parts
	/// are already localized, and interpolating them into a `LocalizedStringKey` would send the
	/// whole sentence back through the catalog as a new key.
	private var loadErrorMessage: String {
		let generic = "load-error".localized()
		guard let reason = viewModel.errorMessage else { return generic }
		return "\(generic)\n\n\(reason)"
	}

	@ViewBuilder
	func renderView() -> some View {
		if viewModel.fetching {
			ProgressView().progressViewStyle(.circular)
				.animation(.easeIn, value: viewModel.holidayDays)
		} else {
			TabView {
				Tab("calendar", systemImage: "calendar") {
					NavigationStack {
						CalendarView(
							selectedDay: $selectedDay,
							holidayDays: viewModel.holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("reports", systemImage: "exclamationmark.triangle") {
					NavigationStack {
						ReportsView(holidayDays: viewModel.holidayDays)
							.navigationTitle("reports")
							.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("more", systemImage: "ellipsis") {
					NavigationStack {
						MoreView()
							.navigationTitle("more")
							.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("search", systemImage: "magnifyingglass", role: .search) {
					NavigationStack {
						SearchScreenView(
							selectedDay: $selectedDay,
							searchText: searchText,
							holidayDays: viewModel.holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
					.searchable(
						text: $searchText,
						placement: .navigationBarDrawer(displayMode: .always),
						prompt: Text("search-across-\(viewModel.allHolidaysCount)")
					)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
				}
			}
		}
	}
}
