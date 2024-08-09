//
//  Created by Andrzej Chmiel on 06/07/2024.
//

import FirebaseAuth
import SwiftUI

struct MissingHolidayScreenView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var floating: Bool = false
	@State private var name: String = ""
	@State private var description: String = ""
	@State private var day: Int = 1
	@State private var month: Int = 0
	@State private var date: String = ""
	@State private var showAlert = false
	@State private var alertMessage = ""
	@State private var success = false;

	var body: some View {
		Form {
			TextField("Holiday name", text: $name, axis: .vertical)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.lineLimit(2...2)
			TextField("Holiday description", text: $description, axis: .vertical)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.lineLimit(5...5)
			Toggle("Floating holiday", isOn: $floating)
				.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			if floating {
				TextField("Date", text: $date, axis: .vertical)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.lineLimit(3...3)
			} else {
				HStack {
					Picker("Month", selection: $month) {
						ForEach(0..<12) { id in
							Text(DateFormatter().standaloneMonthSymbols[id].capitalized).tag(id)
						}
					}
					.onChange(of: month, initial: false) {
						adjustDayForMonth()
					}
					.pickerStyle(.automatic)
					.buttonStyle(BorderedButtonStyle())
					.labelStyle(TitleOnlyLabelStyle())
					Picker("Day", selection: $day) {
						ForEach(0..<getDaysInMonth(month: month + 1), id: \.self) { id in
							Text("\(id + 1)").tag(id + 1)
						}
					}
					.pickerStyle(.automatic)
					.buttonStyle(BorderedButtonStyle())
					.labelStyle(TitleOnlyLabelStyle())
				}
			}
		}
		.padding(12)
		.navigationBarTitle("Missing holiday?")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			if let uid = Auth.auth().currentUser?.uid {
				ToolbarItem(placement: .primaryAction) {
					Button("Send") {
						if floating {
							sendMissingHolidayPayload(missingHolidayPayload: MissingFloatingHolidayPayload(name: name, description: description, userId: uid, date: date), path: "missing/floating")
						} else {
							sendMissingHolidayPayload(missingHolidayPayload: MissingFixedHolidayPayload(name: name, description: description, userId: uid, day: day, month: month + 1), path: "missing/fixed")
						}
					}
					.disabled(disabledSend())
				}
			}
		}
		.alert(isPresented: $showAlert) {
			Alert(title: Text("Report"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
				if success {
					dismiss()
				}
			})
		}
	}

	func sendMissingHolidayPayload(missingHolidayPayload: MissingHolidayPayload, path: String) {
		let encoder: JSONEncoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		do {
			let jsonData: Data = try encoder.encode(missingHolidayPayload)
			URLSession.shared.sendRequest(jsonData: jsonData, path: path) { message, success in
				DispatchQueue.main.async {
					self.alertMessage = message
					self.showAlert = true
					self.success = success
				}
			}
		} catch {
			DispatchQueue.main.async {
				self.alertMessage = "Invalid data format"
				self.showAlert = true
			}
		}
	}

	func disabledSend() -> Bool {
		let holiday: Bool = name.isEmpty || description.isEmpty
		if floating {
			return holiday || date.isEmpty
		}
		return holiday
	}

	func adjustDayForMonth() {
		let maxDay = getDaysInMonth(month: month + 1)
		if day > maxDay {
			day = maxDay
		}
	}

	func getDaysInMonth(month: Int) -> Int {
		let calendar = Calendar.current
		var dateComponents = DateComponents(year: calendar.component(.year, from: Date()), month: month)
		dateComponents.month = month

		if let date = calendar.date(from: dateComponents),
		   let range = calendar.range(of: .day, in: .month, for: date) {
			return range.count
		}

		return 0
	}
}
