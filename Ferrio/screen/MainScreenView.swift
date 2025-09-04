//
//  Created by Andrzej Chmiel on 21/06/2024.
//

import SwiftUI

struct MainScreenView: View {
	let holidayDays: [HolidayDay]
	@Binding var loading: Bool

	var body: some View {
		if loading {
			ProgressView().progressViewStyle(.circular)
				.animation(.easeIn, value: holidayDays)
		} else {
			TabView {
				MonthScreenView(holidayDays: holidayDays)
					.tabItem {
						Label("calendar", systemImage: "calendar")
					}
				MoreScreenView()
					.navigationBarTitleDisplayMode(.large)
					.tabItem {
						Label("more", systemImage: "ellipsis")
					}
			}
		}
	}
}
