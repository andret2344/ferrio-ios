//
//  Created by Andrzej Chmiel on 21/06/2024.
//

import SwiftUI

struct MainScreenView: View {
	let holidayDays: [HolidayDay]
	@State private var searchText = ""
	@State private var selectedDay: HolidayDay?
	@Binding var loading: Bool

	var body: some View {
		if loading {
			ProgressView().progressViewStyle(.circular)
				.animation(.easeIn, value: holidayDays)
		} else {
			TabView {
				Tab("calendar", systemImage: "calendar") {
					NavigationStack {
						MonthScreenView(
							selectedDay: $selectedDay,
							holidayDays: holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("more", systemImage: "ellipsis") {
					NavigationStack {
						MoreScreenView()
							.navigationTitle("more")
							.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("search", systemImage: "magnifyingglass", role: .search) {
					NavigationStack {
						SearchScreenView(
							selectedDay: $selectedDay,
							searchText: searchText,
							holidayDays: holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
					.searchable(
						text: $searchText,
						placement: .navigationBarDrawer(displayMode: .always),
						prompt: Text("search-across-\(getAllHolidays().count)")
					)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
				}
			}
		}
	}

	func getAllHolidays() -> [Holiday] {
		holidayDays
			.flatMap { holiday in holiday.holidays }
	}
}
