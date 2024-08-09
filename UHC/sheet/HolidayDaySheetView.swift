//
// Created by Andrzej Chmiel on 02/09/2023.
//

import StoreKit
import SwiftUI
import UIKit

struct HolidayDaySheetView: View {
	@State private var isShareSheetPresented: Bool = false
	@State private var reportedHoliday: Holiday? = nil
	@Environment(\.requestReview) var requestReview
	@StateObject var observableConfig = ObservableConfig()
	@Environment(\.dismiss) var dismiss
	let holidayDay: HolidayDay

	var body: some View {
		let date: Date? = Date.from(month: holidayDay.month, day: holidayDay.day)
		NavigationStack {
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
									renderText(holiday: holiday)
								}
							} else {
								renderText(holiday: holiday)
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
		.sheet(
			isPresented: Binding(
				get: {
					reportedHoliday != nil
				},
				set: {
					if !$0 {
						reportedHoliday = nil
					}
				})
		) {
			ReportHolidaySheetView(holiday: self.reportedHoliday!)
		}
	}

	func renderText(holiday: Holiday) -> some View {
		Text(holiday.name)
			.contextMenu {
				Button {
					self.reportedHoliday = holiday
				} label: {
					Label("Report", systemImage: "exclamationmark.triangle")
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
