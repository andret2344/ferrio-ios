//
//  Created by Andrzej Chmiel on 30/07/2024.
//

import FirebaseAuth
import SwiftUI

struct ReportHolidaySheetView: View {
	@Environment(\.dismiss) var dismiss
	@StateObject private var viewModel = ReportHolidayViewModel()
	let holiday: Holiday
	let languageCode: String = String((Locale.preferredLanguages.first ?? "en").prefix(2))
	@State private var reportType: ReportType = .WRONG_NAME
	@State private var description: String = ""

	private var availableTypes: [ReportType] {
		if holiday.description.isEmpty {
			return ReportType.allCases.filter { $0 != .WRONG_DESCRIPTION }
		}
		return ReportType.allCases
	}

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

					Picker("reason", selection: $reportType) {
						ForEach(availableTypes, id: \.self) { type in
							Text(type.rawValue.localized()).tag(type)
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
			.toolbar {
				if let uid = Auth.auth().currentUser?.uid {
					ToolbarItem(placement: .primaryAction) {
						Button("send") {
							Task {
								let payload = HolidayReportPayload(
									userId: uid,
									metadata: abs(holiday.id),
									language: languageCode,
									reportType: reportType,
									description: description
								)
								let path = holiday.id < 0 ? "report/floating" : "report/fixed"
								await viewModel.sendReport(reportPayload: payload, path: path)
							}
						}
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.backward")
						Text("back")
					}
				}
			}
			.alert("report", isPresented: $viewModel.showAlert) {
				Button("ok") {
					if viewModel.success {
						dismiss()
					}
				}
			} message: {
				Text(viewModel.alertMessage)
			}
		}
	}

	func renderDescriptionText() -> Text {
		if holiday.description.isEmpty {
			return Text("- \("no-description".localized()) -")
				.italic()
				.foregroundStyle(.gray)
		}
		return Text(holiday.description)
	}
}
