//
// Created by Andrzej Chmiel on 19/02/2026.
//

import SwiftUI

struct HolidayDetailView: View {
	@State private var showReportSheet = false
	@State private var showAiInfoAlert = false
	let holiday: Holiday
	let dateText: String

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				if let countryName = holiday.countryName, let flag = holiday.flagEmoji {
					Text(verbatim: "\(flag) \(countryName)")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				} else {
					Label("international", systemImage: "globe")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}

				if !holiday.description.isEmpty {
					descriptionView
				} else {
					Text("no-description")
						.italic()
						.foregroundStyle(.secondary)
				}
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.safeAreaInset(edge: .bottom) {
			VStack(spacing: 0) {
				// Pinned above the divider rather than placed after the description: the AI
				// disclosure has to stay visible without scrolling, and it describes the text
				// above it, not the action buttons below.
				if holiday.aiGenerated {
					aiBadge
				}
				Divider()
				HStack(spacing: 0) {
					actionButton(label: "share", systemImage: "square.and.arrow.up") {
						shareHoliday()
					}
					actionButton(label: "report", systemImage: "exclamationmark.triangle") {
						showReportSheet = true
					}
				}
				.padding(.horizontal)
				.padding(.vertical, 8)
			}
			.background(.bar)
		}
		.navigationTitle(holiday.name)
		.navigationBarTitleDisplayMode(.large)
		.sheet(isPresented: $showReportSheet) {
			ReportHolidaySheetView(holiday: holiday)
		}
		.alert("ai-content-title", isPresented: $showAiInfoAlert) {
			Button("ok", role: .cancel) {}
		} message: {
			Text("ai-content-message")
		}
	}

	private var aiBadge: some View {
		HStack(spacing: 6) {
			Image(systemName: "sparkles")
			Text("ai-content")
			Button {
				showAiInfoAlert = true
			} label: {
				Image(systemName: "questionmark.circle")
			}
			.buttonStyle(.plain)
			.accessibilityLabel("ai-content-info")
			Spacer(minLength: 0)
		}
		.font(.caption)
		.foregroundStyle(.tertiary)
		.padding(.horizontal)
		.padding(.vertical, 8)
	}

	private var descriptionView: some View {
		let paragraphs = holiday.description.components(separatedBy: "\n").filter { !$0.isEmpty }
		return VStack(alignment: .leading, spacing: 12) {
			ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
				Text(paragraph)
			}
		}
	}

	private func actionButton(label: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			VStack(spacing: 4) {
				Image(systemName: systemImage)
					.font(.title3)
				Text(label)
					.font(.caption)
			}
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity)
		}
		.buttonStyle(.plain)
	}

	private func shareHoliday() {
		let card = HolidayShareCardView(
			date: dateText,
			holidayName: holiday.nameWithFlag,
			holidayDescription: holiday.description.isEmpty ? nil : holiday.description,
			aiGenerated: holiday.aiGenerated
		)
		shareImage(renderCardToImage(card))
	}
}
