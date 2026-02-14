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
			.alert("error", isPresented: $viewModel.error) {
				Button("retry") { Task { await viewModel.loadData() } }
				Button("ok", role: .cancel) {}
			} message: {
				Text("load-error")
			}
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
						ReportsView()
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
