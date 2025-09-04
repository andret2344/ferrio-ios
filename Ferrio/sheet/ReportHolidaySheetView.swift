//
//  Created by Andrzej Chmiel on 30/07/2024.
//

import FirebaseAuth
import SwiftUI

struct ReportHolidaySheetView: View {
	@Environment(\.dismiss) var dismiss
	let holiday: Holiday
	let languageCode: String = String(Locale.preferredLanguages[0].prefix(2))
	private let types: [String] = ["WRONG_NAME", "WRONG_DESCRIPTION", "WRONG_DATE", "OTHER"]
	@State private var reportType: String = "WRONG_NAME"
	@State private var description: String = ""
	@State private var showAlert: Bool = false
	@State private var alertMessage: String = ""
	@State private var success: Bool = false;

	var body: some View {
		let _ = print()
		NavigationStack {
			VStack {
				Form {
					Text(holiday.name)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...1)

					renderDescriptionText()
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...2)

					Picker("reason", selection: $reportType) {
						ForEach(types, id: \.self) { type in
							if (type != "WRONG_DESCRIPTION" || holiday.description != "") {
								Text(type.localized()).tag(type)
							}
						}
					}
					.pickerStyle(.automatic)
					.buttonStyle(BorderedButtonStyle())
					.labelStyle(TitleOnlyLabelStyle())

					TextField(
						"description",
						text: $description,
						axis: .vertical
					)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.lineLimit(6...6)
					Text("report-notice")
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...3)
						.font(.footnote)
						.foregroundStyle(.orange)
				}
			}
			.navigationTitle("report-holiday")
			.navigationBarTitleDisplayMode(.large)
			.navigationViewStyle(.stack)
			.toolbar {
				if let uid = Auth.auth().currentUser?.uid {
					ToolbarItem(placement: .primaryAction) {
						Button("send") {
							if holiday.id < 0 {
								sendReport(
									reportPayload: HolidayReportPayload(
										userId: uid,
										metadata: -holiday.id,
										language: languageCode,
										reportType: reportType,
										description: description
									),
									path: "report/floating"
								)
							} else {
								sendReport(
									reportPayload: HolidayReportPayload(
										userId: uid,
										metadata: holiday.id,
										language: languageCode,
										reportType: reportType,
										description: description
									),
									path: "report/fixed"
								)
							}
						}
					}
				}
			}
			.navigationBarItems(leading: Button {
				dismiss()
			} label: {
				Image(systemName: "chevron.backward")
				Text("back")
			})
			.alert(isPresented: $showAlert) {
				Alert(title: Text("report"), message: Text(alertMessage), dismissButton: .default(Text("ok")) {
					if success {
						dismiss()
					}
				})
			}
		}
	}

	func renderDescriptionText() -> Text {
		if holiday.description == "" {
			return Text("- \("no-description".localized()) -")
				.italic()
				.foregroundStyle(.gray)
		}
		return Text(holiday.description)
	}

	func sendReport(reportPayload: HolidayReportPayload, path: String) {
		let encoder: JSONEncoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		do {
			let jsonData: Data = try encoder.encode(reportPayload)
			URLSession.shared.sendRequest(jsonData: jsonData, path: path) { message, success in
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
}
