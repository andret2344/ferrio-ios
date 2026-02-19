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
			Form {
				Section {
					VStack(alignment: .leading, spacing: 0) {
						Text(holiday.nameWithFlag)
							.font(.headline)
							.padding(12)
							.frame(maxWidth: .infinity, alignment: .leading)
						if !holiday.description.isEmpty {
							Divider()
							Text(holiday.description)
								.font(.subheadline)
								.foregroundStyle(.secondary)
								.lineLimit(3)
								.padding(12)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
					.background(Color(.secondarySystemBackground))
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.listRowBackground(Color.clear)
					.listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
				} header: {
					Text("report-holiday-subject")
				}

				Section {
					Picker("reason", selection: $reportType) {
						ForEach(availableTypes, id: \.self) { type in
							Text(type.rawValue.localized()).tag(type)
						}
					}

					TextField(
						"report-description-placeholder",
						text: $description,
						axis: .vertical
					)
					.lineLimit(4...6)
				} header: {
					Text("report-details")
				} footer: {
					Text("report-notice")
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
									metadata: holiday.numericId,
									language: languageCode,
									reportType: reportType,
									description: description
								)
								let path = holiday.isFloating ? "report/floating" : "report/fixed"
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
}
