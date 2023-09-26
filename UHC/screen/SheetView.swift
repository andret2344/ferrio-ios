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
		let date: Date? = Date.from(month: holidayDay.month, day: holidayDay.day)
		NavigationView {
			VStack {
				let holidays: [Holiday] = holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays);
				if holidays.count == 0 {
					Image("SadIcon")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 128, height: 128)
					Text("No unusual holidays.")
				} else {
					List {
						ForEach(holidays, id: \.id) { holiday in
							if holiday.description != "" {
								NavigationLink {
									VStack(alignment: .leading) {
										Text(holiday.description)
										Spacer()
									}
											.navigationTitle(holiday.name)
											.navigationBarTitleDisplayMode(.large)
											.navigationViewStyle(.stack)
											.navigationBarItems(trailing: Button {
											} label: {
												let name: String = "[\(holidayDay.getDate())] \(holiday.name)"
												let text: String = "\(name) - \(holiday.description)"
												ShareLink(item: text, preview: SharePreview(name))
														.labelStyle(.iconOnly)
											})
											.padding()
											.frame(maxWidth: .infinity, alignment: .leading)
								} label: {
									Text(holiday.name)
								}
							} else {
								Text(holiday.name)
							}
						}
					}
				}
			}
					.navigationTitle(date!.formatted(.dateTime.day().month(.wide)))
					.navigationBarTitleDisplayMode(.large)
					.navigationViewStyle(.stack)
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
}
