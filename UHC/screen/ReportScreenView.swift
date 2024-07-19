//
// Created by Andrzej Chmiel on 02/09/2023.
//

import SwiftUI

struct ReportScreenView: View {
	var body: some View {
		NavigationView {
			List {
				NavigationLink("Missing holiday?") {
					MissingHolidayScreenView()
				}
				//	.disabled(true)
			}
			.navigationTitle("Reports")
		}
		.scrollDisabled(true)
	}
}
