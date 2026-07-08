//
//  Created by Andrzej Chmiel on 11/08/2024.
//

import SwiftUI

struct MyReportsScreenView: View {
	@StateObject private var viewModel = ReportsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var selectedReport: HolidayReport?

	var body: some View {
		VStack(spacing: 0) {
			Picker("select-reported-holidays-type", selection: $reportedHolidaysType) {
				Text("holidays-fixed").tag("fixed")
				Text("holidays-floating").tag("floating")
			}
			.pickerStyle(.segmented)
			.padding(.horizontal)
			if viewModel.isLoading {
				Spacer()
				ProgressView()
					.frame(maxWidth: .infinity)
				Spacer()
			} else if let error = viewModel.error {
				Spacer()
				ContentUnavailableView(
					"error-loading",
					systemImage: "exclamationmark.triangle",
					description: Text(error.localizedDescription)
				)
				Spacer()
			} else {
				List {
					if reportedHolidaysType == "fixed" {
						if viewModel.reportsFixed.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.reportsFixed) { report in
								renderReport(report: report)
							}
						}
					} else {
						if viewModel.reportsFloating.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.reportsFloating) { report in
								renderReport(report: report)
							}
						}
					}
				}
				.refreshable {
					await viewModel.fetchData()
				}
			}
		}
		.navigationTitle("my-reports")
		.task {
			await viewModel.fetchData()
		}
		.sheet(item: $selectedReport) { report in
			ReportDetailsSheetView(
				title: report.reportType.localized(),
				state: report.reportState,
				description: report.description,
				comment: report.comment,
				dateInfo: nil,
				datetime: report.datetime
			)
		}
	}

	private var emptyState: some View {
		ContentUnavailableView("no-reports", systemImage: "checkmark.circle")
			.listRowBackground(Color.clear)
	}

	private func hasComment(_ comment: String?) -> Bool {
		guard let comment else { return false }
		return !comment.isEmpty
	}

	func renderReport(report: HolidayReport) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top, spacing: 6) {
				Text(report.reportType.localized())
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Spacer()
				if hasComment(report.comment) {
					Image(systemName: "text.bubble")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				StatusBadge(state: report.reportState)
			}
			if let desc = report.description, !desc.isEmpty {
				Text(desc)
					.lineLimit(2)
			}
			Text(formatDatetime(report.datetime))
				.font(.caption)
				.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			selectedReport = report
		}
	}
}
