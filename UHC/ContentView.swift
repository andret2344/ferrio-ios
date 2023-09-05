//
//  ContentView.swift
//  learning
//
//  Created by Andrzej Chmiel on 28/08/2023.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.locale)
	var locale: Locale
	@State
	private var days = [HolidayDay]()
	var body: some View {
		MonthScreenView(holidayDays: days)
				.task {
					do {
						days = try await URLSession.shared.decode([HolidayDay].self, from: getUrl())
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
		let code: String? = locale.language.languageCode?.identifier
		let lang: String = ["pl"].contains(code!) ? code! : "en"
		return URL(string: "https://api.unusualcalendar.net/holiday/\(lang)")!
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
