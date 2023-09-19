//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct MonthScreenView: View {
	let holidayDays: [HolidayDay]
	@State
	private var selection = Calendar.current.component(.month, from: Date()) - 1
	@State
	private var selectedDay: HolidayDay? = nil
	@Binding
	var loading: Bool
	@State
	private var searchText = ""
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
								if searchText != "" {
									List {
										ForEach(holidayDays, id: \.id) { holidayDay in
											let holidays = holidayDay.holidays.filter { holiday in
												holiday.name.contains(searchText)
											}
											if holidays.count > 0 {
												HStack {
													Text("\(holidayDay.getDate()):")
													Divider()
													VStack(alignment: .leading) {
														ForEach(holidays, id: \.id) { holiday in
															Text("- \(holiday.name)")
														}
													}
												}
														.onTapGesture {
															selectedDay = holidayDay
														}
											}
										}
									}
											.sheet(item: $selectedDay) { item in
												SheetView(holidayDay: item)
														.presentationDetents([.fraction(0.5), .fraction(0.9)])
											}
								}
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
									prompt: "Type name of a holiday")
				}
						.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
						.tabViewStyle(.page(indexDisplayMode: .never))
			}
		}
	}

	func getRandomHolidayDay() -> HolidayDay {
		holidayDays[Int.random(in: 0..<holidayDays.count)];
	}
}
