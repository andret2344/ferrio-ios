//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct HolidayDaySheetView: View {
	@EnvironmentObject var observableConfig: ObservableConfig
	@Environment(\.dismiss) var dismiss
	let holidayDay: HolidayDay

	var body: some View {
		let date: Date? = Date.from(month: holidayDay.month, day: holidayDay.day)
		let dateText = date?.formatted(.dateTime.day().month(.wide)) ?? holidayDay.getDate()
		let holidays: [Holiday] = holidayDay.getHolidays(includeUsual: observableConfig.includeUsual)
		NavigationStack {
			VStack {
				if holidays.isEmpty {
					Image("SadIcon")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 128, height: 128)
					Text("no-unusual-holidays")
				} else {
					List {
						ForEach(holidays, id: \.id) { holiday in
							NavigationLink {
								HolidayDetailView(holiday: holiday, dateText: dateText)
							} label: {
								Text(holiday.nameWithFlag)
							}
						}
					}
				}
			}
			.navigationTitle(dateText)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
						Text("back")
					}
				}
				ToolbarItem(placement: .primaryAction) {
					if !holidays.isEmpty {
						ShareHolidayDayButton(
							date: dateText,
							holidays: holidays.map { $0.nameWithFlag }
						)
					}
				}
			}
		}
	}
}
