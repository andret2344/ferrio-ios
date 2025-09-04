//
// Created by Andrzej Chmiel on 02/09/2023.
//

import StoreKit
import SwiftData
import SwiftUI
import UIKit

struct HolidayDaySheetView: View {
	@State private var isShareSheetPresented: Bool = false
	@State private var reportedHoliday: Holiday? = nil
	@StateObject var observableConfig = ObservableConfig()
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	let holidayDay: HolidayDay
	@Query private var favorite: [Favorite]

	var body: some View {
		let date: Date? = Date.from(month: holidayDay.month, day: holidayDay.day)
		NavigationStack {
			VStack {
				let holidays: [Holiday] = holidayDay.getHolidays(includeUsual: observableConfig.includeUsual);
				if holidays.count == 0 {
					Image("SadIcon")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 128, height: 128)
					Text("no-unusual-holidays")
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
				Text("back")
			}, trailing: Button {
			} label: {
				let holidays: [Holiday] = holidayDay.getHolidays(includeUsual: observableConfig.includeUsual)
				if (holidays.count != 0) {
					let holidays = holidays.map { holiday in
						"- \(holiday.name)"
					}
						.joined(separator: "\n")
					let text = "\(holidayDay.day).\(holidayDay.month):\n\(holidays)\n\n\("check-it-yourself".localized())"
					ShareLink(item: text, preview: SharePreview(text))
						.labelStyle(.iconOnly)
				}
			})
		}
		.sheet(isPresented: nullBinding($reportedHoliday)) {
			ReportHolidaySheetView(holiday: reportedHoliday!)
		}
	}

	func renderText(holiday: Holiday) -> some View {
		let fav: Favorite? = findFavorite(id: holiday.id)
		return HStack {
			Text(holiday.name)
				.contextMenu {
					Button {
						self.reportedHoliday = holiday
					} label: {
						Label("Report", systemImage: "exclamationmark.triangle")
					}
				}
			Spacer()
			Button {
				let id: String = "HolidayDay-\(holidayDay.month)-\(holidayDay.day)"
				if fav == nil {
					modelContext.insert(Favorite(holidayId: holiday.id))
					runNotification(id: id, holiday: holiday)
				} else {
					modelContext.delete(fav!)
					UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
				}
			} label: {
				Image(systemName: fav == nil ? "star" : "star.fill")
			}
		}
	}

	func findFavorite(id: Int) -> Favorite? {
		favorite.first(where: { $0.holidayId == id })
	}

	func runNotification(id: String, holiday: Holiday) -> Void {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
			if success {
				let notificationContent = UNMutableNotificationContent()
				notificationContent.title = "Ferrio"
				notificationContent.body = holiday.name
				notificationContent.sound = .defaultRingtone

				var components = DateComponents()
				components.day = holidayDay.day
				components.month = holidayDay.month
				components.hour = 9
				components.minute = 30

				let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
				let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
				UNUserNotificationCenter.current().add(request);
			} else if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	func nullBinding<T>(_ element: Binding<T?>) -> Binding<Bool> {
		return Binding(
			get: {
				element.wrappedValue != nil
			},
			set: {
				if !$0 {
					element.wrappedValue = nil
				}
			})
	}
}
