//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct SheetView: View {
	@StateObject
	var observableConfig = ObservableConfig()
	@Environment(\.dismiss)
	var dismiss
	let holidayDay: HolidayDay
	var body: some View {
		NavigationView {
			VStack {
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
					.navigationBarTitle(getDateString(month: holidayDay.month, day: holidayDay.day), displayMode: .large)
					.navigationBarItems(leading: Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
						Text("Back")
					}, trailing: Button {
					} label: {
						let holidays: [Holiday] = holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays)
						if (holidays.count != 0) {
							let holidays = holidays.map { holiday in
										"- \(holiday.name)"
									}
									.joined(separator: "\n")
							let text = "\(holidayDay.day).\(holidayDay.month):\n\n\(holidays)\n\n\(NSLocalizedString("Check it yourself!", comment: ""))"
							ShareLink(item: text, preview: SharePreview(text))
									.labelStyle(.iconOnly)
						}
					})
		}
	}

	func getDateString(month: Int, day: Int) -> String {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("dd MMM")
		var components = DateComponents()
		components.day = day
		components.month = month
		return df.string(from: Calendar.current.date(from: components)!)
	}
}
