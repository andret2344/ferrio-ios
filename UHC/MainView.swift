//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI
import JavaScriptCore

struct ContentView: View {
	@State
	var fetching: Bool = true
	@State
	private var days = [HolidayDay]()
	var body: some View {
		MonthScreenView(holidayDays: days, loading: $fetching)
				.overlay {
					if fetching {
						ProgressView().progressViewStyle(.circular)
					}
				}
				.animation(.easeIn, value: days)
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
						days = unusualCalendar.fixed
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
		let code: String? = Locale.current.language.languageCode?.identifier
		let lang: String = ["pl"].contains(code!) ? code! : "en"
		return URL(string: "https://api.unusualcalendar.net/v2/holiday/\(lang)")!
	}
}
