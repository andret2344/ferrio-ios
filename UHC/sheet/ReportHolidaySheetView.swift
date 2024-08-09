//
//  Created by Andrzej Chmiel on 30/07/2024.
//

import FirebaseAuth
import SwiftUI

struct ReportHolidaySheetView: View {
	@Environment(\.dismiss) var dismiss
	let holiday: Holiday
	@State private var reportType: String = "WRONG_NAME"
	@State private var description: String = ""
	@State private var showAlert = false
	@State private var alertMessage = ""
	@State private var success = false;

	var body: some View {
		NavigationStack {
			VStack {
				Form {
					Text(holiday.name)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...1)

					renderDescriptionText()
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...2)

					Picker("Reason", selection: $reportType) {
						Text("Wrong name").tag("WRONG_NAME")
						Text("Wrong description").tag("WRONG_DESCRIPTION")
						Text("Wrong date").tag("WRONG_DATE")
						Text("Other").tag("OTHER")
					}
					.pickerStyle(.automatic)
					.buttonStyle(BorderedButtonStyle())
					.labelStyle(TitleOnlyLabelStyle())

					TextField(
						"Description",
						text: $description,
						axis: .vertical
					)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.lineLimit(6...6)
					Text("Reports with the description are more likely to be verified on the first place.")
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.lineLimit(1...3)
						.font(.footnote)
						.foregroundStyle(.orange)
				}
			}
			.navigationTitle("Report holiday")
			.navigationBarTitleDisplayMode(.large)
			.navigationViewStyle(.stack)
			.toolbar {
				if let uid = Auth.auth().currentUser?.uid {
					ToolbarItem(placement: .primaryAction) {
						Button("Send") {
							if holiday.id < 0 {
								sendReport(
									reportPayload: HolidayReportPayload(
										userId: uid,
										metadata: -holiday.id,
										language: "en",
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
										language: "en",
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
				Text("Back")
			})
			.alert(isPresented: $showAlert) {
				Alert(title: Text("Report"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
					if success {
						dismiss()
					}
				})
			}
		}
	}

	func renderDescriptionText() -> Text {
		if holiday.description == "" {
			return Text("- No deescription -")
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
}
