//
// Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI

struct MonthAdapterView: View {
	@Environment(\.calendar) var calendar
	@EnvironmentObject var observableConfig: ObservableConfig
	@Binding var selectedDay: HolidayDay?
	let month: Int
	let days: [HolidayDay]

	private let calendarService = CalendarService()

	private static let monthFormatter: DateFormatter = {
		let formatter = DateFormatter()
		return formatter
	}()

	private var holidayDays: [HolidayDay] {
		calendarService.getHolidayDaysForMonth(month, from: days)
	}

	var body: some View {
		let holidayDays = self.holidayDays
		let rowsData = holidayDays.chunked(into: 7)
		let todayComponents = Calendar.current.dateComponents([.day, .month], from: Date())

		GeometryReader { geo in
			let cols = 7
			let rows = 6
			let spacing: CGFloat = 6
			let headerH: CGFloat = 18

			let availW = geo.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing - 16
			let availH = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom - 16 - headerH - spacing

			let cellW = floor((availW - spacing * CGFloat(cols - 1)) / CGFloat(cols))
			let cellH = floor((availH - spacing * CGFloat(rows - 1)) / CGFloat(rows))

			let gridW = cellW * CGFloat(cols) + spacing * CGFloat(cols - 1)
			let gridH = cellH * CGFloat(rows) + spacing * CGFloat(rows - 1)

			VStack(alignment: .leading, spacing: spacing) {
				HStack(spacing: spacing) {
					ForEach(0..<cols, id: \.self) { column in
						Text(weekdaySymbol(for: column))
							.font(.caption)
							.fontWeight(.semibold)
							.foregroundStyle(.secondary)
							.frame(width: max(0, cellW), height: headerH)
					}
				}
				ForEach(0..<rowsData.endIndex, id: \.self) { weekIndex in
					HStack(spacing: spacing) {
						ForEach(0..<rowsData[weekIndex].endIndex, id: \.self) { dayIndex in
							let day: Int = weekIndex * 7 + dayIndex
							let holidayDay: HolidayDay = holidayDays[day]

							renderButton(holidayDay: holidayDay, width: cellW, height: cellH)
								.overlay(
									todayComponents.day == holidayDay.day && todayComponents.month == holidayDay.month
											? RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 3)
											: nil
								)
						}
					}
				}
				Spacer(minLength: 0)
			}
			.frame(width: gridW, height: gridH + headerH + spacing, alignment: .topLeading)
			.padding(.vertical, 8)
			.padding(.horizontal, 8)
			.navigationTitle(Text(Self.monthFormatter.standaloneMonthSymbols[month - 1].capitalized))
		}
	}

	// Column 0 maps to the locale's first weekday (matching CalendarService's grid alignment),
	// so shift the Sunday-based symbol list by firstWeekday.
	private func weekdaySymbol(for column: Int) -> String {
		let calendar = Calendar.current
		let symbols = calendar.shortWeekdaySymbols
		let index = (calendar.firstWeekday - 1 + column) % symbols.count
		return symbols[index].capitalized
	}

	private func renderButton(holidayDay: HolidayDay, width: CGFloat, height: CGFloat) -> some View {
		Button { selectedDay = holidayDay } label: {
			ZStack {
				if holidayDay.getHolidays(includeUsual: observableConfig.includeUsual, showAdult: observableConfig.showAdultContent).isEmpty {
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
		.clipShape(RoundedRectangle(cornerRadius: 5))
	}

	func getColor(currentMonth: Bool, holidayDay: HolidayDay) -> UIColor {
		if !currentMonth {
			return .systemGray6
		}
		if observableConfig.colorizedDays {
			return UIColor.random(seed: Int(holidayDay.id) ?? 0)
		}
		return .systemFill
	}
}
