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
		HStack {
			VStack {
				Text(report.description)
					.lineLimit(report.id == expanded ? nil : 2)
					.frame(maxWidth: .infinity, alignment: .leading)
				Text(report.reportType.localized())
					.italic()
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.system(size: 12))
					.foregroundStyle(Color(UIColor.systemGray))
			}
			Spacer()
			Text("#\(String(report.metadataId))")
				.italic()
				.frame(maxWidth: 48, alignment: .trailing)
			Text(report.reportState.rawValue.localized())
				.foregroundStyle(Color(UIColor.systemBackground))
				.frame(width: 108, height: 32)
				.background(RoundedRectangle(cornerRadius: 8).fill(report.reportState.color))
				.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
		}
		.onTapGesture {
			if expanded == report.id {
				expanded = nil
			} else {
				expanded = report.id
			}
		}
	}
}
