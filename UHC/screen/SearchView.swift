//
// Created by Andrzej Chmiel on 20/09/2023.
//

import SwiftUI

struct SearchView: View {
	let searchText: String
	let holidayDays: [HolidayDay]
	@Binding
	var selectedDay: HolidayDay?
	var body: some View {
		if searchText != "" {
			List {
				ForEach(holidayDays, id: \.id) { holidayDay in
					let holidays = holidayDay.holidays.filter { holiday in
						holiday.name.localizedCaseInsensitiveContains(searchText)
					}
					if holidays.count > 0 {
						HStack {
							Text("\(holidayDay.getDate())")
								.frame(width: 50, alignment: .leading)
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
		}
	}
}
