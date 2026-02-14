//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI
import JavaScriptCore

struct ContentView: View {
	@State private var fetching: Bool = true
	@State private var holidayDays = [HolidayDay]()
	@State private var searchText = ""
	@State private var selectedDay: HolidayDay?
	@State private var error: Bool = false
	var allHolidaysCount: Int {
		holidayDays.reduce(0) { $0 + $1.holidays.count }
	}

	var body: some View {
		renderView()
			.task(id: Locale.current.identifier) { await loadData() }
			.alert("Error", isPresented: $error) {
				Button("Retry") { Task { await loadData() } }
				Button("OK", role: .cancel) {}
			} message: {
				Text("Unable to load holidays. We're working on fixing the issue. Sorry for the inconvenience.")
			}
	}

	@MainActor
	func loadData() async -> Void {
		defer { fetching = false }
		do {
			fetching = true
			error = false
			guard let url = getUrl(), let context = JSContext() else {
				error = true
				return
			}
			var unusualCalendar: UnusualCalendar = try await URLSession.shared.decode(UnusualCalendar.self, from: url)
			for holiday in unusualCalendar.floating {
				guard let result = context.evaluateScript(holiday.script),
					  !result.isUndefined,
					  !result.isNull,
					  let (day, month) = parseDayMonth(from: result)
				else {
					continue
				}

				unusualCalendar.add(
					day: day,
					month: month,
					holiday: Holiday(floatingHoliday: holiday)
				)
			}
			holidayDays = unusualCalendar.fixed
		} catch {
			print("error: ", error)
			self.error = true
			holidayDays = []
		}
	}

	func getUrl() -> URL? {
		let code: String = Locale.current.language.languageCode?.identifier ?? ""
		let lang: String = ["pl"].contains(code) ? code : "en"
		return URL(string: "https://api.ferrio.app/v2/holiday/\(lang)")
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
						prompt: Text("search-across-\(allHolidaysCount)")
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

	private func parseDayMonth(from value: JSValue) -> (day: Int, month: Int)? {
		// Object: { day: 3, month: 8 }
		if value.isObject,
		   let day: Int = value.forProperty("day")?.toNumber()?.intValue,
		   let month: Int = value.forProperty("month")?.toNumber()?.intValue,
		   valid(day: day, month: month) {
			return (day, month)
		}

		// Array: [3, 8]
		if value.isArray,
		   let arr: [Any] = value.toArray(),
		   arr.count >= 2,
		   let day = (arr[0] as? NSNumber).map({ $0.intValue }),
		   let month = (arr[1] as? NSNumber).map({ $0.intValue }),
		   valid(day: day, month: month) {
			return (day, month)
		}

		// String: "3.8" / "03.08"
		let parts = value.toString().split(separator: ".", omittingEmptySubsequences: true)
		if parts.count == 2,
		   let day = Int(parts[0]),
		   let month = Int(parts[1]),
		   valid(day: day, month: month) {
			return (day, month)
		}

		return nil
	}


	@inline(__always)
	private func valid(day: Int, month: Int) -> Bool {
		(1...31).contains(day) && (1...12).contains(month)
	}
}
