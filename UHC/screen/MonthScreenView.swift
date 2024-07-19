//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct MonthScreenView: View {
	@State private var selection = Calendar.current.component(.month, from: Date()) - 1
	@State private var selectedDay: HolidayDay? = nil
	@State private var searchText = ""
	let holidayDays: [HolidayDay]
	let loading: Bool

	var body: some View {
		if loading == false {
			LazyHStack {
				NavigationStack {
					TabView(selection: $selection) {
						ForEach(1..<13) { i in
							MonthAdapter(selectedDay: $selectedDay, month: i, days: holidayDays)
						}
					}
					.overlay {
						SearchView(selectedDay: $selectedDay, searchText: searchText, holidayDays: holidayDays)
					}
					.navigationBarTitleDisplayMode(.large)
					.toolbar {
						ToolbarItem(placement: .primaryAction) {
							Button {
								withAnimation {
									selection = Calendar.current.component(.month, from: Date()) - 1
								}
							} label: {
								Image(systemName: "calendar.badge.clock")
									.accessibilityLabel("Today")
							}
						}
						ToolbarItem(placement: .primaryAction) {
							Button {
								selectedDay = getRandomHolidayDay()
							} label: {
								Image(systemName: "shuffle")
									.accessibilityLabel("Random")
							}
						}
					}
					.searchable(text: $searchText,
								placement: .navigationBarDrawer(displayMode: .always),
								prompt: "Search across \(getHolidaysCount()) holidays...")
					.ignoresSafeArea(.keyboard)
				}
				.sheet(item: $selectedDay) { item in
					SheetView(holidayDay: item)
						.presentationDetents([.fraction(0.5), .fraction(0.9)])
				}
				.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
				.tabViewStyle(.page(indexDisplayMode: .never))
			}
			.ignoresSafeArea(.keyboard)
		}
	}

	func getRandomHolidayDay() -> HolidayDay {
		holidayDays[Int.random(in: 0..<holidayDays.count)];
	}

	func getHolidaysCount() -> Int {
		holidayDays.flatMap { day in
			day.holidays
		}.count
	}
}
