//
// Created by Andrzej Chmiel on 02/09/2023.
//

import StoreKit
import SwiftUI
import UIKit

struct SheetView: View {
	@State private var isShareSheetPresented = false
	@Environment(\.requestReview) var requestReview
	@StateObject var observableConfig = ObservableConfig()
	@Environment(\.dismiss) var dismiss
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
							Text(holiday.name)
						}
					}
				}
			}
			.navigationBarTitle(date!.formatted(.dateTime.day().month(.wide)))
			.navigationBarTitleDisplayMode(.large)
			.navigationBarItems(leading: Button {
				dismiss()
			} label: {
				Image(systemName: "chevron.backward")
				Text("Back")
			}, trailing: Button {
				isShareSheetPresented = true
			} label: {
				Image(systemName: "square.and.arrow.up")
			})
		}
		.sheet(isPresented: $isShareSheetPresented) {
			let holidays = holidayDay.getHolidays(includeUsualHolidays: observableConfig.includeUsualHolidays)
			if holidays.count != 0 {
				let holidaysList = holidays.map { holiday in
					"- \(holiday.name)"
				}
					.joined(separator: "\n")
				let text = "\(holidayDay.day).\(holidayDay.month):\n\(holidaysList)\n\n\(NSLocalizedString("Check it yourself!", comment: ""))"
				ShareSheet(activityItems: [text], completion: {
					requestReview()
				})
			}
		}
	}
}

struct ShareSheet: UIViewControllerRepresentable {
	var activityItems: [Any]
	var applicationActivities: [UIActivity]? = nil
	var completion: (() -> Void)?

	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
		controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
			if completed {
				completion?()
			}
		}
		return controller
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
		// No update required
	}

	class Coordinator: NSObject {
		var parent: ShareSheet

		init(parent: ShareSheet) {
			self.parent = parent
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}
}
