//
//  Created by Andrzej Chmiel on 06/07/2024.
//

import FirebaseAuth
import StoreKit
import SwiftUI

struct SuggestHolidayScreenView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.requestReview) private var requestReview
	@State private var floating: Bool = false
	@State private var name: String = ""
	@State private var description: String = ""
	@State private var day: Int = 1
	@State private var month: Int = 0
	@State private var date: String = ""
	@State private var country: Locale.Region? = nil
	@State private var showAlert: Bool = false
	@State private var alertMessage: String = ""
	@State private var success: Bool = false
	@State private var countries: [Locale.Region]? = nil

	var body: some View {
		VStack {
			if countries == nil {
				ProgressView().progressViewStyle(.circular)
					.animation(.easeIn, value: countries)
			} else {
				let sorted = countries!.sorted(by: {translateCountry($0.identifier) < translateCountry($1.identifier)})

				Form {
					TextField("holiday-name", text: $name, axis: .vertical)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(2...2)
					TextField(
						"holiday-description",
						text: $description,
						axis: .vertical
					)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.lineLimit(4...4)
					Picker("country", selection: $country) {
						Text("international").tag(nil as Locale.Region?)
						ForEach(sorted, id: \.self) { c in
							Text(
								"\(c.identifier.asFlagEmoji())  \(translateCountry(c.identifier))"
							)
							.tag(c)
						}
					}
					.buttonStyle(.bordered)
					.labelStyle(.titleAndIcon)
					Toggle("holiday-floating", isOn: $floating)
						.toggleStyle(SwitchToggleStyle(tint: .accentColor))
					if floating {
						TextField("date", text: $date, axis: .vertical)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.lineLimit(3...3)
					} else {
						HStack {
							Picker("month", selection: $month) {
								ForEach(0..<12) { id in
									Text(
										DateFormatter()
											.standaloneMonthSymbols[id].capitalized
									)
									.tag(id)
								}
							}
							.onChange(of: month, initial: false) {
								adjustDayForMonth()
							}
							.pickerStyle(.wheel)
							Picker("day", selection: $day) {
								ForEach(
									0..<getDaysInMonth(month: month + 1),
									id: \.self
								) { id in
									Text("\(id + 1)").tag(id + 1)
								}
							}
							.pickerStyle(.wheel)
						}
					}
					Text("report-notice")
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...3)
						.font(.footnote)
						.foregroundStyle(.orange)
				}
				.navigationBarTitle("suggest-holiday")
				.navigationBarTitleDisplayMode(.large)
				.toolbar {
					if let uid = Auth.auth().currentUser?.uid {
						ToolbarItem(placement: .primaryAction) {
							Button("send") {
								if floating {
									sendMissingHolidayPayload(
										missingHolidayPayload: MissingFloatingHolidayPayload(
											name: name,
											description: description,
											userId: uid,
											country: country?.identifier,
											date: date
										),
										path: "missing/floating"
									)
								} else {
									sendMissingHolidayPayload(
										missingHolidayPayload: MissingFixedHolidayPayload(
											name: name,
											description: description,
											userId: uid,
											country: country?.identifier,
											day: day,
											month: month + 1
										),
										path: "missing/fixed"
									)
								}
							}
							.disabled(disabledSend())
						}
					}
				}
				.alert(isPresented: $showAlert) {
					Alert(
						title: Text("report-sent"),
						message: Text(alertMessage.localized()),
						dismissButton: .default(
							Text("ok")
						) {
							if success {
								dismiss()
								requestReview()
							}
						})
				}
			}
		}
		.task {
			do {
				let fetched = try await URLSession.shared.decode([String].self,from: URL(string: "https://api.ferrio.app/v2/countries?format=code")!)
				countries = fetched.compactMap { Locale.Region.init($0) }
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

	func sendMissingHolidayPayload(
		missingHolidayPayload: MissingHolidayPayload,
		path: String
	) {
		let encoder: JSONEncoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		do {
			let jsonData: Data = try encoder.encode(missingHolidayPayload)
			URLSession.shared
				.sendRequest(
					jsonData: jsonData,
					path: path
				) { message, success in
					DispatchQueue.main.async {
						self.alertMessage = message ?? "sent"
						self.showAlert = true
						self.success = success
					}
				}
		} catch {
			DispatchQueue.main.async {
				self.alertMessage = "invalid-data-format"
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
		var components = DateComponents()
		components.year = 2024
		let calendar = Calendar.current
		var dateComponents = DateComponents(year: 2024, month: month)
		dateComponents.month = month

		if let date = calendar.date(from: dateComponents),
		   let range = calendar.range(of: .day, in: .month, for: date) {
			return range.count
		}

		return 0
	}

	func translateCountry(_ identifier: String) -> String {
		Locale.current.localizedString(forRegionCode: identifier) ?? identifier
	}
}
