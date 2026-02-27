//
// Created by Andrzej Chmiel on 19/02/2026.
//

import SwiftUI

struct HolidayDetailView: View {
	@State private var showReportSheet = false
	let holiday: Holiday
	let dateText: String

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				if let countryName = holiday.countryName, let flag = holiday.flagEmoji {
					Text("\(flag) \(countryName)")
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
			holidayDescription: holiday.description.isEmpty ? nil : holiday.description
		)
		let renderer = ImageRenderer(content: card)
		renderer.scale = 3.0
		guard let image = renderer.uiImage else { return }
		let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let rootVC = windowScene.keyWindow?.rootViewController else { return }
		var topVC = rootVC
		while let presented = topVC.presentedViewController {
			topVC = presented
		}
		activityVC.popoverPresentationController?.sourceView = topVC.view
		topVC.present(activityVC, animated: true)
	}
}
