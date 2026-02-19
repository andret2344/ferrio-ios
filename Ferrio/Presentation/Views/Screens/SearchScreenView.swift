//
// Created by Andrzej Chmiel on 20/09/2023.
//

import SwiftUI

struct SearchScreenView: View {
	@Binding var selectedDay: HolidayDay?
	let searchText: String
	let holidayDays: [HolidayDay]

	private var matches: [(day: HolidayDay, items: [Holiday])] {
		let q = searchText.norm().trimmingCharacters(in: .whitespacesAndNewlines)
		guard !q.isEmpty else { return [] }

		return holidayDays.compactMap { day in
			let items = day.holidays.filter { h in
				h.name.norm().contains(q)
			}
			return items.isEmpty ? nil : (day, items)
		}
	}

	var body: some View {
		Group {
			if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				ContentUnavailableView("start-searching", systemImage: "square.and.pencil")
			} else if matches.isEmpty {
				ContentUnavailableView(
					"no-results",
					systemImage: "magnifyingglass",
					description: Text("no-results-description")
				)
			} else {
				List {
					ForEach(matches, id: \.day.id) { group in
						Button {
							selectedDay = group.day
						} label: {
							HStack(alignment: .top, spacing: 8) {
								Text(group.day.getDate())
									.frame(width: 50, alignment: .leading)
								Divider()
								VStack(alignment: .leading, spacing: 6) {
									ForEach(group.items, id: \.id) { holiday in
										Text("• \(holiday.nameWithFlag)")
											.lineLimit(2)
									}
								}
							}
							.contentShape(Rectangle())
						}
						.buttonStyle(.plain)
					}
				}
			}
		}
		.navigationTitle("search")
	}
}
