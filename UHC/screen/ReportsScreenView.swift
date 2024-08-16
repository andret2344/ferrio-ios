//
//  Created by Andrzej Chmiel on 11/08/2024.
//

import FirebaseAuth
import SwiftUI

struct ReportsScreenView: View {
	@State private var reportsFixed: [HolidayReport] = []
	@State private var reportsFloating: [HolidayReport] = []
	@State private var reportedHolidaysType: String = "fixed"

	var body: some View {
		Picker("Select reported holidays type", selection: $reportedHolidaysType) {
			Text("Fixed").tag("fixed")
			Text("Floating").tag("floating")
		}
		.pickerStyle(.segmented)
		List {
			if reportedHolidaysType == "fixed" {
				ForEach(reportsFixed, id: \.id) { report in
					renderReport(report: report)
				}
			} else {
				ForEach(reportsFloating, id: \.id) { report in
					renderReport(report: report)
				}
			}
		}
		.navigationTitle("My suggestions")
		.task {
			do {
				reportsFixed = try await URLSession.shared
					.decode(
						[HolidayReport].self,
						from: getUrlForFixed(),
						keyDecodingStrategy: .convertFromSnakeCase
					)
				reportsFloating = try await URLSession.shared
					.decode(
						[HolidayReport].self,
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

	func renderReport(report: HolidayReport) -> some View {
		HStack {
			VStack {
				Text(report.description)
					.lineLimit(2)
					.frame(maxWidth: .infinity, alignment: .leading)
				Text(report.reportType.localized())
					.italic()
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.system(size: 12))
					.foregroundStyle(Color(UIColor.systemGray))
			}
			Spacer()
			Text("#\(report.metadataId)")
				.italic()
				.frame(maxWidth: 48, alignment: .trailing)
			Text(report.reportState.rawValue.localized())
				.foregroundStyle(Color(UIColor.systemBackground))
				.frame(width: 108, height: 32)
				.background(RoundedRectangle(cornerRadius: 8).fill(getColor(reportState: report.reportState)))
				.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
		}
	}

	func getUrlForFixed() -> URL {
		let uuid: String = Auth.auth().currentUser?.uid ?? ""
		return URL(string: "https://api.unusualcalendar.net/v2/report/\(uuid)/fixed")!
	}

	func getUrlForFloating() -> URL {
		let uuid: String = Auth.auth().currentUser?.uid ?? ""
		return URL(string: "https://api.unusualcalendar.net/v2/report/\(uuid)/floating")!
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
