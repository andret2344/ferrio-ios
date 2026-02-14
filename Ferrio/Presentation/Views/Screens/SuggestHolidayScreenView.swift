//
//  Created by Andrzej Chmiel on 06/07/2024.
//

import FirebaseAuth
import StoreKit
import SwiftUI

struct SuggestHolidayScreenView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.requestReview) private var requestReview
	@StateObject private var viewModel = SuggestHolidayViewModel()
	@State private var floating: Bool = false
	@State private var name: String = ""
	@State private var description: String = ""
	@State private var day: Int = 1
	@State private var month: Int = 0
	@State private var date: String = ""
	@State private var country: Locale.Region? = nil

	private static let monthFormatter: DateFormatter = {
		let formatter = DateFormatter()
		return formatter
	}()

	var body: some View {
		Group {
			if viewModel.countries == nil {
				ProgressView().progressViewStyle(.circular)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
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
					ForEach(viewModel.sortedCountries, id: \.self) { c in
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
									Self.monthFormatter
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
			}
		}
		.navigationTitle("suggest-holiday")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			if let uid = Auth.auth().currentUser?.uid {
				ToolbarItem(placement: .primaryAction) {
					Button("send") {
						Task {
							if floating {
								await viewModel.sendMissingSuggestion(
									payload: MissingFloatingHolidayPayload(
										name: name,
										description: description,
										userId: uid,
										country: country?.identifier,
										date: date
									),
									path: "missing/floating"
								)
							} else {
								await viewModel.sendMissingSuggestion(
									payload: MissingFixedHolidayPayload(
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
					}
					.disabled(disabledSend())
				}
			}
		}
		.alert("suggestion-sent", isPresented: $viewModel.showAlert) {
			Button("ok") {
				if viewModel.success {
					dismiss()
					requestReview()
				}
			}
		} message: {
			Text(viewModel.alertMessage)
		}
		.task {
			await viewModel.fetchCountries()
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
		let dateComponents = DateComponents(year: Calendar.current.component(.year, from: Date()), month: month)

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
