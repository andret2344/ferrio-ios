//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

struct MonthAdapter: View {
	@Environment(\.calendar) var calendar
	@StateObject var observableConfig = ObservableConfig()
	@Binding var selectedDay: HolidayDay?
	let month: Int
	let days: [HolidayDay]

	var body: some View {
		GeometryReader { geo in
			let cols = 7
			let rows = 6
			let spacing: CGFloat = 6

			let availW = geo.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing - 16
			let availH = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom - 16

			let cellW = floor((availW - spacing * CGFloat(cols - 1)) / CGFloat(cols))
			let cellH = floor((availH - spacing * CGFloat(rows - 1)) / CGFloat(rows))

			let gridW = cellW * CGFloat(cols) + spacing * CGFloat(cols - 1)
			let gridH = cellH * CGFloat(rows) + spacing * CGFloat(rows - 1)

			let holidayDays: [HolidayDay] = getHolidayDays()
			let rowsData: [[HolidayDay]] = holidayDays.chunked(into: cols)

			VStack(alignment: .leading, spacing: spacing) {
				ForEach(0..<rowsData.endIndex, id: \.self) { weekIndex in
					HStack(spacing: spacing) {
						ForEach(0..<rowsData[weekIndex].endIndex, id: \.self) { dayIndex in
							let day: Int = weekIndex * 7 + dayIndex
							let holidayDay: HolidayDay = holidayDays[day]
							let components: DateComponents = Calendar.current.dateComponents([.day, .month], from: Date())

							renderButton(holidayDay: holidayDay, width: cellW, height: cellH)
								.overlay(
									components.day == holidayDay.day && components.month == holidayDay.month
											? RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 3)
											: nil
								)
						}
					}
				}
				Spacer(minLength: 0)
			}
			.frame(width: gridW, height: gridH, alignment: .topLeading)
			.padding(.vertical, 8)
			.padding(.horizontal, 8)
			.navigationTitle(Text(DateFormatter().standaloneMonthSymbols[month - 1].capitalized))
		}
	}

	private func renderButton(holidayDay: HolidayDay, width: CGFloat, height: CGFloat) -> some View {
		Button { selectedDay = holidayDay } label: {
			ZStack {
				if holidayDay.getHolidays(includeUsual: observableConfig.includeUsual).isEmpty {
					Image("SadIcon")
						.resizable()
						.scaledToFit()
				} else {
					Text("\(holidayDay.day)")
						.font(.system(size: 25))
				}
			}
			.frame(width: max(0, width), height: max(0, height))
		}
		.background(Color(getColor(currentMonth: holidayDay.month == month, holidayDay: holidayDay)))
		.foregroundColor(Color(.label))
		.cornerRadius(5)
	}

	func getColor(currentMonth: Bool, holidayDay: HolidayDay) -> UIColor {
		if !currentMonth {
			return .systemGray6
		}
		if observableConfig.colorizedDays {
			return UIColor.random(seed: Int(holidayDay.id)!)
		}
		return .systemFill
	}

	func getHolidayDays() -> [HolidayDay] {
		let year: Int = Calendar.current.component(.year, from: Date())
		let date: Date = Date.from(year: year, month: month, day: 1)
		let before: Date = getBefore(date: date)
		let after: Date = Calendar.current.date(byAdding: .day, value: 41, to: before)!
		return getDays(from: before, to: after)
	}

	func getBefore(date: Date) -> Date {
		let startOfMonth: Date = date.startOfMonth()
		let weekday: Int = Calendar.current.component(.weekday, from: startOfMonth)
		let remainingDays: Int = (7 - calendar.firstWeekday + weekday) % 7
		return Calendar.current.date(byAdding: .day, value: -remainingDays, to: date)!
	}

	func getDays(from: Date, to: Date) -> [HolidayDay] {
		var holidayDays: [HolidayDay] = []
		var date = from
		while date <= to {
			let calendarDate = Calendar.current.dateComponents([.day, .month], from: date)
			holidayDays.append(getDay(month: calendarDate.month!, day: calendarDate.day!))
			date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
		}
		return holidayDays
	}

	func getDay(month: Int, day: Int) -> HolidayDay {
		days.first(where: { $0.month == month && $0.day == day }) ?? HolidayDay(day: day, month: month, holidays: [])
	}
}
