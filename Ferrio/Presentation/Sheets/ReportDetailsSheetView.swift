//
// Created by Andrzej Chmiel on 26/04/2026.
//

import SwiftUI

struct ReportDetailsSheetView: View {
	@Environment(\.dismiss) var dismiss
	let title: String
	let state: ReportState
	let description: String?
	let comment: String?
	let dateInfo: String?
	let countryCode: String?
	let datetime: String
	let linkedHoliday: Holiday?

	init(
		title: String,
		state: ReportState,
		description: String?,
		comment: String?,
		dateInfo: String?,
		countryCode: String? = nil,
		datetime: String,
		linkedHoliday: Holiday? = nil
	) {
		self.title = title
		self.state = state
		self.description = description
		self.comment = comment
		self.dateInfo = dateInfo
		self.countryCode = countryCode
		self.datetime = datetime
		self.linkedHoliday = linkedHoliday
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 16) {
					submissionCard
					reviewCard
				}
				.padding()
			}
			.background(Color(.systemGroupedBackground))
			.navigationTitle("report-details")
			.navigationBarTitleDisplayMode(.inline)
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
		}
	}

	private var submissionCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(spacing: 8) {
				Image(systemName: "person.fill")
				Text("submission")
					.font(.subheadline.weight(.semibold))
				Spacer()
			}
			.foregroundStyle(.secondary)

			Divider()

			Text(title)
				.font(.headline)

			if let description, !description.isEmpty {
				Text(description)
					.font(.body)
					.frame(maxWidth: .infinity, alignment: .leading)
			}

			if let dateInfo {
				Text("\(dateInfo) · \(countryDisplay)")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}

			Label(formatDatetime(datetime), systemImage: "clock")
				.font(.caption)
				.foregroundStyle(.tertiary)
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
	}

	private var reviewCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(spacing: 8) {
				Image(systemName: "checkmark.seal.fill")
				Text("review")
					.font(.subheadline.weight(.semibold))
				Spacer()
				StatusBadge(state: state)
			}
			.foregroundStyle(state.color)

			if let comment, !comment.isEmpty {
				Divider()
				VStack(alignment: .leading, spacing: 6) {
					Label("moderator-comment", systemImage: "text.bubble")
						.font(.caption)
						.foregroundStyle(.secondary)
					Text(comment)
						.font(.body)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}

			if let linkedHoliday {
				Divider()
				NavigationLink {
					HolidayDetailView(
						holiday: linkedHoliday,
						dateText: dateInfo ?? ""
					)
				} label: {
					HStack {
						Label("view-holiday", systemImage: "calendar")
							.foregroundStyle(state.color)
						Spacer()
						Image(systemName: "chevron.right")
							.font(.caption.weight(.semibold))
							.foregroundStyle(.tertiary)
					}
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(state.color.opacity(0.08), in: .rect(cornerRadius: 14))
	}

	private var countryDisplay: String {
		guard let code = countryCode, code.count == 2 else {
			return "international".localized()
		}
		let base: UInt32 = 0x1F1E6 - 65
		let flag = code.uppercased().unicodeScalars.compactMap {
			UnicodeScalar(base + $0.value).map(String.init)
		}.joined()
		let name = Locale.current.localizedString(forRegionCode: code) ?? code
		return "\(flag) \(name)"
	}
}
