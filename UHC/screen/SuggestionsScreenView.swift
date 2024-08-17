//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import FirebaseAuth
import SwiftUI

struct SuggestionsScreenView: View {
	@State private var suggestionsFixed: [MissingFixedHoliday] = []
	@State private var suggestionsFloating: [MissingFloatingHoliday] = []
	@State private var reportedHolidaysType: String = "fixed"

	var body: some View {
		Picker("Select missing holidays type", selection: $reportedHolidaysType) {
			Text("Fixed holidays").tag("fixed")
			Text("Floating holidays").tag("floating")
		}
		.pickerStyle(.segmented)
		List {
			if reportedHolidaysType == "fixed" {
				ForEach(suggestionsFixed, id: \.id) { suggestion in
					HStack {
						VStack {
							Text("\(String(format: "%02d", suggestion.month)).\(String(format: "%02d", suggestion.day))")
								.italic()
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.name)
								.bold()
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.description)
								.lineLimit(2)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						Spacer()
						Text(suggestion.reportState.rawValue.localized())
							.foregroundStyle(Color(UIColor.systemBackground))
							.frame(width: 108, height: 32)
							.background(RoundedRectangle(cornerRadius: 8).fill(getColor(reportState: suggestion.reportState)))
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
					}
				}
			} else {
				ForEach(suggestionsFloating, id: \.id) { suggestion in
					HStack {
						VStack {
							Text(suggestion.date)
								.italic()
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.name)
								.bold()
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.description)
								.lineLimit(2)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						Spacer()
						Text(suggestion.reportState.rawValue.localized())
							.foregroundStyle(Color(UIColor.systemBackground))
							.frame(width: 108, height: 32)
							.background(RoundedRectangle(cornerRadius: 8).fill(getColor(reportState: suggestion.reportState)))
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
					}
				}
			}
		}
		.navigationTitle("My suggestions")
		.task {
			do {
				suggestionsFixed = try await URLSession.shared
					.decode(
						[MissingFixedHoliday].self,
						from: getUrlForFixed(),
						keyDecodingStrategy: .convertFromSnakeCase
					)
				suggestionsFloating = try await URLSession.shared
					.decode(
						[MissingFloatingHoliday].self,
						from: getUrlForFloating(),
						keyDecodingStrategy: .convertFromSnakeCase
					)
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

	func getUrlForFixed() -> URL {
		let uuid: String = Auth.auth().currentUser?.uid ?? ""
		return URL(string: "https://api.unusualcalendar.net/v2/missing/\(uuid)/fixed")!
	}

	func getUrlForFloating() -> URL {
		let uuid: String = Auth.auth().currentUser?.uid ?? ""
		return URL(string: "https://api.unusualcalendar.net/v2/missing/\(uuid)/floating")!
	}

	func getColor(reportState: ReportState) -> Color {
		switch reportState {
		case .REPORTED:
			return Color(UIColor.systemBlue)
		case .APPLIED:
			return Color(UIColor.systemGreen)
		case .DECLINED:
			return Color(UIColor.systemRed)
		case .ON_HOLD:
			fallthrough
		default:
			return Color(UIColor.systemYellow)
		}
	}
}
