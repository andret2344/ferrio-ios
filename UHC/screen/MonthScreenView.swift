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
	var body: some View {
		LazyHStack {
			NavigationStack {
				TabView(selection: $selection) {
					ForEach(1..<13) { i in
						ZStack {
							MonthAdapter(selectedDay: $selectedDay, month: i, days: holidayDays)
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
			}
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
					.tabViewStyle(.page(indexDisplayMode: .never))
		}
	}

	func getRandomHolidayDay() -> HolidayDay {
		holidayDays[Int.random(in: 0..<holidayDays.count)];
	}
}
