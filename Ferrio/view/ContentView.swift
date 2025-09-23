//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI
import JavaScriptCore

struct ContentView: View {
	@State var fetching: Bool = true
	@State private var holidayDays = [HolidayDay]()
	@State private var searchText = ""
	@State private var selectedDay: HolidayDay?

	var body: some View {
		renderView()
			.task {
				do {
					var unusualCalendar: UnusualCalendar = try await URLSession.shared.decode(UnusualCalendar.self, from: getUrl())
					for holiday in unusualCalendar.floating {
						let context = JSContext()!
						let result: JSValue? = context.evaluateScript(holiday.script)
						let date: [String.SubSequence]? = result?.toString()?.split(separator: ".")
						let data: [String.SubSequence] = date!
						if result != nil {
							unusualCalendar.add(day: Int(data[0])!, month: Int(data[1])!, holiday: Holiday(floatingHoliday: holiday))
						}
					}
					holidayDays = unusualCalendar.fixed
					fetching = false
				} catch let DecodingError.dataCorrupted(context) {
					print(context)
				} catch let DecodingError.keyNotFound(key, context) {
					print("Key '\(key)' not found:", context.debugDescription)
					print("codingPath:", context.codingPath)
				} catch let DecodingError.valueNotFound(value, context) {
					print("Value '\(value)' not found:", context.debugDescription)
					print("codingPath:", context.codingPath)
				} catch let DecodingError.typeMismatch(type, context) {
					print("Type '\(type)' mismatch:", context.debugDescription)
					print("codingPath:", context.codingPath)
				} catch {
					print("error: ", error)
				}
			}
	}

	func getUrl() -> URL {
		let code: String = Locale.current.language.languageCode?.identifier ?? ""
		let lang: String = ["pl"].contains(code) ? code : "en"
		return URL(string: "https://api.ferrio.app/v2/holiday/\(lang)")!
	}

	@ViewBuilder
	func renderView() -> some View {
		if fetching {
			ProgressView().progressViewStyle(.circular)
				.animation(.easeIn, value: holidayDays)
		} else {
			TabView {
				Tab("calendar", systemImage: "calendar") {
					NavigationStack {
						CalendarView(
							selectedDay: $selectedDay,
							holidayDays: holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("reports", systemImage: "exclamationmark.triangle") {
					NavigationStack {
						ReportsView()
							.navigationTitle("reports")
							.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("more", systemImage: "ellipsis") {
					NavigationStack {
						MoreView()
							.navigationTitle("more")
							.navigationBarTitleDisplayMode(.large)
					}
				}
				Tab("search", systemImage: "magnifyingglass", role: .search) {
					NavigationStack {
						SearchScreenView(
							selectedDay: $selectedDay,
							searchText: searchText,
							holidayDays: holidayDays
						)
						.navigationBarTitleDisplayMode(.large)
					}
					.searchable(
						text: $searchText,
						placement: .navigationBarDrawer(displayMode: .always),
						prompt: Text("search-across-\(getAllHolidays().count)")
					)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
				}
			}
		}
	}

	func getAllHolidays() -> [Holiday] {
		holidayDays
			.flatMap { holiday in holiday.holidays }
	}
}
