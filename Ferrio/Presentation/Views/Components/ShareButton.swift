//
// Created by Andrzej Chmiel.
//

import SwiftUI
import UIKit

// MARK: - Share Card Views

struct HolidayShareCardView: View {
	let date: String
	let holidayName: String
	let holidayDescription: String?

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text(date.uppercased())
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.tracking(1.5)
				.foregroundStyle(.white.opacity(0.6))
				.padding(.bottom, 12)

			Text(holidayName)
				.font(.system(size: 28, weight: .bold, design: .rounded))
				.foregroundStyle(.white)
				.padding(.bottom, 8)

			if let desc = holidayDescription, !desc.isEmpty {
				Text(desc)
					.font(.system(size: 15, weight: .regular))
					.foregroundStyle(.white.opacity(0.8))
					.lineLimit(7)
					.padding(.bottom, 8)
			}

			Spacer(minLength: 0)

			Divider()
				.overlay(.white.opacity(0.15))
				.padding(.bottom, 14)

			HStack(spacing: 8) {
				Image("Logo")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 28, height: 28)
					.clipShape(RoundedRectangle(cornerRadius: 6))
				Text("Ferrio")
					.font(.system(size: 15, weight: .semibold, design: .rounded))
					.foregroundStyle(.white.opacity(0.7))
				Spacer()
				Text("ferrio.app")
					.font(.system(size: 13, weight: .medium))
					.foregroundStyle(.white.opacity(0.4))
			}
		}
		.padding(24)
		.frame(width: 380, height: 320, alignment: .topLeading)
		.background(
			LinearGradient(
				colors: [Color(red: 0.12, green: 0.12, blue: 0.18), Color(red: 0.08, green: 0.08, blue: 0.14)],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		)
	}
}

struct HolidayDayShareCardView: View {
	let date: String
	let holidays: [String]

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text(date.uppercased())
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.tracking(1.5)
				.foregroundStyle(.white.opacity(0.6))
				.padding(.bottom, 14)

			VStack(alignment: .leading, spacing: 6) {
				ForEach(holidays.prefix(8), id: \.self) { name in
					HStack(alignment: .top, spacing: 8) {
						Circle()
							.fill(.white.opacity(0.5))
							.frame(width: 6, height: 6)
							.padding(.top, 6)
						Text(name)
							.font(.system(size: 16, weight: .medium))
							.foregroundStyle(.white)
							.lineLimit(1)
					}
				}
				if holidays.count > 8 {
					Text("+\(holidays.count - 8) more...")
						.font(.system(size: 14, weight: .regular))
						.foregroundStyle(.white.opacity(0.5))
						.padding(.leading, 14)
				}
			}

			Spacer(minLength: 0)

			Divider()
				.overlay(.white.opacity(0.15))
				.padding(.bottom, 14)

			HStack(spacing: 8) {
				Image("Logo")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 28, height: 28)
					.clipShape(RoundedRectangle(cornerRadius: 6))
				Text("Ferrio")
					.font(.system(size: 15, weight: .semibold, design: .rounded))
					.foregroundStyle(.white.opacity(0.7))
				Spacer()
				Text("ferrio.app")
					.font(.system(size: 13, weight: .medium))
					.foregroundStyle(.white.opacity(0.4))
			}
		}
		.padding(24)
		.frame(width: 380, alignment: .topLeading)
		.frame(minHeight: 280)
		.fixedSize(horizontal: false, vertical: true)
		.background(
			LinearGradient(
				colors: [Color(red: 0.12, green: 0.12, blue: 0.18), Color(red: 0.08, green: 0.08, blue: 0.14)],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		)
	}
}

// MARK: - Rendering

@MainActor private func renderCardToImage<V: View>(_ view: V) -> UIImage? {
	let renderer = ImageRenderer(content: view)
	renderer.scale = 3.0
	return renderer.uiImage
}

// MARK: - Share Buttons

struct ShareHolidayButton: View {
	let date: String
	let holidayName: String
	let holidayDescription: String?

	var body: some View {
		Button {
			let card = HolidayShareCardView(
				date: date,
				holidayName: holidayName,
				holidayDescription: holidayDescription
			)
			shareImage(renderCardToImage(card))
		} label: {
			Image(systemName: "square.and.arrow.up")
		}
	}
}

struct ShareHolidayDayButton: View {
	let date: String
	let holidays: [String]

	var body: some View {
		Button {
			let card = HolidayDayShareCardView(date: date, holidays: holidays)
			shareImage(renderCardToImage(card))
		} label: {
			Image(systemName: "square.and.arrow.up")
		}
	}
}

// MARK: - Presentation

private func shareImage(_ image: UIImage?) {
	guard let image else { return }
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
