//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct DayScreenView: View {
	@StateObject
	var observableConfig = ObservableConfig()
	let holidayDay: HolidayDay
	var body: some View {
		NavigationView {
			let holidays: [Holiday] = holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays);
			if holidays.count == 0 {
				VStack {
					Image("SadIcon")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 128, height: 128)
					Text("No unusual holidays.")
				}
			} else {
				List {
					ForEach(holidays, id: \.id) { holiday in
						Text(holiday.name)
					}
				}
			}
		}
				.navigationBarTitle(holidayDay.getDate())
				.toolbar {
					ToolbarItem(placement: .primaryAction) {
						let holidays = holidayDay.holidays.map { holiday in
									"- \(holiday.name)"
								}
								.joined(separator: "\n")
						let text = "\(holidayDay.day).\(holidayDay.month):\n\n\(holidays)\n\n\(NSLocalizedString("Check it yourself!", comment: ""))"
						ShareLink(item: text, preview: SharePreview(text))
								.labelStyle(.iconOnly)
					}
				}
	}
}
