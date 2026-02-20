//
//  Created by Andrzej Chmiel on 11/08/2024.
//

import SwiftUI

struct MyReportsScreenView: View {
	@StateObject private var viewModel = ReportsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var expanded: Int? = nil

	var body: some View {
		Picker("select-reported-holidays-type", selection: $reportedHolidaysType) {
			Text("holidays-fixed").tag("fixed")
			Text("holidays-floating").tag("floating")
		}
		.pickerStyle(.segmented)
		.padding(.horizontal)
		List {
			if reportedHolidaysType == "fixed" {
				ForEach(viewModel.reportsFixed, id: \.id) { report in
					renderReport(report: report)
				}
			} else {
				ForEach(viewModel.reportsFloating, id: \.id) { report in
					renderReport(report: report)
				}
			}
		}
		.refreshable {
			await viewModel.fetchData()
		}
		.navigationTitle("my-reports")
		.task {
			await viewModel.fetchData()
		}
	}

	func renderReport(report: HolidayReport) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(report.reportType.localized())
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Spacer()
				StatusBadge(state: report.reportState)
			}
			Text(report.description)
				.lineLimit(report.id == expanded ? nil : 2)
			Text(formatDatetime(report.datetime))
				.font(.caption)
				.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			expanded = expanded == report.id ? nil : report.id
		}
	}
}

struct StatusBadge: View {
	let state: ReportState

	var body: some View {
		Text(state.rawValue.localized())
			.font(.caption)
			.fontWeight(.medium)
			.foregroundStyle(state.color)
			.padding(.horizontal, 10)
			.padding(.vertical, 4)
			.background(
				RoundedRectangle(cornerRadius: 6)
					.fill(state.color.opacity(0.12))
			)
	}
}

func formatDatetime(_ datetime: String) -> String {
	let isoFormatter = ISO8601DateFormatter()
	isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
	let displayFormatter = DateFormatter()
	displayFormatter.dateStyle = .medium
	displayFormatter.timeStyle = .short

	if let date = isoFormatter.date(from: datetime) {
		return displayFormatter.string(from: date)
	}

	// Fallback without fractional seconds
	isoFormatter.formatOptions = [.withInternetDateTime]
	if let date = isoFormatter.date(from: datetime) {
		return displayFormatter.string(from: date)
	}

	return datetime
}
