//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct MonthScreenView: View {
	let holidayDays: [HolidayDay]
	@State
	private var selection = Calendar.current.component(.month, from: Date()) - 1
	var body: some View {
		LazyHStack {
			NavigationView {
				TabView(selection: $selection) {
					ForEach(1..<13) { i in
						ZStack {
							MonthAdapter(month: i, days: holidayDays)
						}
					}
				}
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
						}
			}
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
					.tabViewStyle(.page(indexDisplayMode: .never))
		}
	}
}
