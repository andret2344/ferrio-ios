//
//  Created by Andrzej Chmiel on 11/08/2024.
//

import SwiftUI

struct MyReportsScreenView: View {
	@StateObject private var viewModel = ReportsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var expandedFixed: Int? = nil
	@State private var expandedFloating: Int? = nil

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
							ForEach(viewModel.reportsFixed, id: \.id) { report in
								renderReport(report: report, expanded: $expandedFixed)
							}
						}
					} else {
						if viewModel.reportsFloating.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.reportsFloating, id: \.id) { report in
								renderReport(report: report, expanded: $expandedFloating)
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
	}

	private var emptyState: some View {
		ContentUnavailableView("no-reports", systemImage: "checkmark.circle")
			.listRowBackground(Color.clear)
	}

	func renderReport(report: HolidayReport, expanded: Binding<Int?>) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(report.reportType.localized())
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Spacer()
				StatusBadge(state: report.reportState)
			}
			if let desc = report.description, !desc.isEmpty {
				Text(desc)
					.lineLimit(report.id == expanded.wrappedValue ? nil : 2)
			}
			Text(formatDatetime(report.datetime))
				.font(.caption)
				.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			expanded.wrappedValue = expanded.wrappedValue == report.id ? nil : report.id
		}
	}
}
