//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI
import FirebaseAuth

struct MonthScreenView: View {
	@State private var selection = Calendar.current.component(.month, from: Date()) - 1
	@Binding var selectedDay: HolidayDay?
	let holidayDays: [HolidayDay]

	var body: some View {
		TabView(selection: $selection) {
			ForEach(1..<13) { i in
				MonthAdapter(selectedDay: $selectedDay, month: i, days: holidayDays)
					.tag(i)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					withAnimation {
						selection = Calendar.current.component(.month, from: Date())
					}
				} label: {
					Image(systemName: "calendar.badge.clock")
						.accessibilityLabel("today")
				}
			}
			ToolbarItem(placement: .primaryAction) {
				Button {
					selectedDay = getRandomHolidayDay()
				} label: {
					Image(systemName: "shuffle")
						.accessibilityLabel("random")
				}
			}
		}
		.ignoresSafeArea(.keyboard)
		.sheet(item: $selectedDay) { item in
			HolidayDaySheetView(holidayDay: item)
				.presentationDetents([.fraction(0.5), .fraction(0.9)])
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
