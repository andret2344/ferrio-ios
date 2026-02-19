//
//  MessagesViewController.swift
//  FerrioMessagesExtension
//
//  Created by Andrzej Chmiel on 15/02/2026.
//

import UIKit
import Messages
import SwiftUI

// MARK: - Inline Domain Models

private struct MessagesHoliday: Identifiable, Decodable {
	let id: String
	let day: Int
	let month: Int
	let usual: Bool
	let name: String
	let description: String
	let url: String
	let country: String?
	let matureContent: Bool

	enum CodingKeys: String, CodingKey {
		case id, day, month, usual, name, description, url, country
		case matureContent = "mature_content"
	}

	var nameWithFlag: String {
		guard let code = country, code.count == 2 else { return name }
		let base: UInt32 = 0x1F1E6 - 65
		let flag = code.uppercased().unicodeScalars.compactMap {
			UnicodeScalar(base + $0.value).map(String.init)
		}.joined()
		return "\(name) \(flag)"
	}
}

private struct HolidayDay: Decodable {
	let id: String
	let day: Int
	let month: Int
	let holidays: [MessagesHoliday]

	init(day: Int, month: Int, holidays: [MessagesHoliday]) {
		self.id = String(format: "%02d%02d", month, day)
		self.day = day
		self.month = month
		self.holidays = holidays
	}
}

// MARK: - API Helpers

private enum API {
	static let baseURL = "https://api.ferrio.app/v3"

	static var language: String {
		let code = Locale.current.language.languageCode?.identifier ?? ""
		return ["pl"].contains(code) ? code : "en"
	}
}

private extension URLSession {
	func decode<T: Decodable>(_ type: T.Type = T.self, from url: URL) async throws -> T {
		let (data, response) = try await data(from: url)
		if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
			throw URLError(.badServerResponse)
		}
		return try JSONDecoder().decode(T.self, from: data)
	}
}

// MARK: - Date Formatting

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .long
	formatter.timeStyle = .none
	return formatter
}()

private func formatDate(day: Int, month: Int) -> String {
	var components = DateComponents()
	components.day = day
	components.month = month
	components.year = Calendar.current.component(.year, from: Date())
	guard let date = Calendar.current.date(from: components) else {
		return "\(day).\(month)"
	}
	return dateFormatter.string(from: date)
}

// MARK: - Shared Card Components

private let cardBackground = LinearGradient(
	colors: [Color(red: 0.12, green: 0.12, blue: 0.18), Color(red: 0.08, green: 0.08, blue: 0.14)],
	startPoint: .topLeading,
	endPoint: .bottomTrailing
)

private struct CardFooter: View {
	var body: some View {
		VStack(spacing: 0) {
			Rectangle()
				.fill(.white.opacity(0.15))
				.frame(height: 1)
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
	}
}

// MARK: - Share Card Views

private struct HolidayShareCardView: View {
	let date: String
	let holidayName: String
	let holidayDescription: String

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

			if !holidayDescription.isEmpty {
				Text(holidayDescription)
					.font(.system(size: 15, weight: .regular))
					.foregroundStyle(.white.opacity(0.8))
					.lineLimit(7)
					.padding(.bottom, 8)
			}

			Spacer(minLength: 0)

			CardFooter()
		}
		.padding(24)
		.frame(width: 380, height: 320, alignment: .topLeading)
		.background(cardBackground)
	}
}

private struct HolidayDayShareCardView: View {
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
				ForEach(holidays.prefix(6), id: \.self) { name in
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
				if holidays.count > 6 {
					Text("+\(holidays.count - 6) more...")
						.font(.system(size: 14, weight: .regular))
						.foregroundStyle(.white.opacity(0.5))
						.padding(.leading, 14)
				}
			}

			Spacer(minLength: 0)

			CardFooter()
		}
		.padding(24)
		.frame(width: 380, alignment: .topLeading)
		.frame(minHeight: 280)
		.fixedSize(horizontal: false, vertical: true)
		.background(cardBackground)
	}
}

// MARK: - Card Rendering

@MainActor
private func renderCardToImage<V: View>(_ view: V) -> UIImage? {
	let renderer = ImageRenderer(content: view)
	renderer.scale = 3.0
	return renderer.uiImage
}

// MARK: - Holiday List SwiftUI View

private struct HolidayListView: View {
	@State private var holidayDay: HolidayDay?
	@State private var isLoading = true
	@State private var errorMessage: String?

	let onSelectHoliday: (MessagesHoliday) -> Void
	let onSelectAll: (HolidayDay) -> Void

	var body: some View {
		Group {
			if isLoading {
				ProgressView()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if let error = errorMessage {
				VStack(spacing: 12) {
					Image(systemName: "exclamationmark.triangle")
						.font(.title)
						.foregroundStyle(.secondary)
					Text(error)
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
					Button("Retry") {
						Task { await fetchHolidays() }
					}
					.buttonStyle(.borderedProminent)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.padding()
			} else if let day = holidayDay, !day.holidays.isEmpty {
				ScrollView {
					VStack(spacing: 0) {
						Button {
							onSelectAll(day)
						} label: {
							HStack {
								Image(systemName: "square.grid.2x2")
								Text(formatDate(day: day.day, month: day.month))
								Spacer()
								Image(systemName: "arrow.up.circle.fill")
									.foregroundStyle(.blue)
							}
							.padding(.horizontal, 16)
							.padding(.vertical, 14)
							.background(Color(.secondarySystemBackground))
							.clipShape(RoundedRectangle(cornerRadius: 12))
						}
						.buttonStyle(.plain)
						.padding(.horizontal, 16)
						.padding(.top, 12)
						.padding(.bottom, 8)

						ForEach(Array(day.holidays.enumerated()), id: \.element.id) { index, holiday in
							Button {
								onSelectHoliday(holiday)
							} label: {
								HStack {
									Text(holiday.nameWithFlag)
										.font(.subheadline.weight(.medium))
										.foregroundStyle(.primary)
										.lineLimit(2)
										.multilineTextAlignment(.leading)
									Spacer()
									Image(systemName: "arrow.up.circle")
										.foregroundStyle(.blue)
								}
								.padding(.horizontal, 16)
								.padding(.vertical, 10)
							}
							.buttonStyle(.plain)

							if index < day.holidays.count - 1 {
								Divider()
									.padding(.leading, 16)
							}
						}
					}
				}
			} else {
				VStack(spacing: 12) {
					Image(systemName: "calendar.badge.exclamationmark")
						.font(.title)
						.foregroundStyle(.secondary)
					Text("No holidays today")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.task {
			await fetchHolidays()
		}
	}

	private func fetchHolidays() async {
		isLoading = true
		errorMessage = nil

		let now = Date()
		let calendar = Calendar.current
		let day = calendar.component(.day, from: now)
		let month = calendar.component(.month, from: now)

		guard let url = URL(string: "\(API.baseURL)/holidays?lang=\(API.language)&month=\(month)&day=\(day)") else {
			errorMessage = "Invalid URL"
			isLoading = false
			return
		}

		do {
			let holidays = try await URLSession.shared.decode([MessagesHoliday].self, from: url)
			holidayDay = HolidayDay(day: day, month: month, holidays: holidays)
		} catch {
			errorMessage = "Could not load holidays"
		}
		isLoading = false
	}
}

// MARK: - Messages View Controller

class MessagesViewController: MSMessagesAppViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		let listView = HolidayListView(
			onSelectHoliday: { [weak self] (holiday: MessagesHoliday) in
				self?.insertHolidayCard(holiday)
			},
			onSelectAll: { [weak self] (day: HolidayDay) in
				self?.insertDayCard(day)
			}
		)

		let hosting = UIHostingController(rootView: listView)
		hosting.view.translatesAutoresizingMaskIntoConstraints = false
		addChild(hosting)
		view.addSubview(hosting.view)
		NSLayoutConstraint.activate([
			hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
			hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		hosting.didMove(toParent: self)
	}

	@MainActor
	private func insertHolidayCard(_ holiday: MessagesHoliday) {
		guard let conversation = activeConversation else { return }

		let now = Date()
		let calendar = Calendar.current
		let dateStr = formatDate(
			day: calendar.component(.day, from: now),
			month: calendar.component(.month, from: now)
		)

		let cardView = HolidayShareCardView(
			date: dateStr,
			holidayName: holiday.nameWithFlag,
			holidayDescription: holiday.description
		)

		guard let image = renderCardToImage(cardView) else { return }
		insertImageMessage(image: image, caption: holiday.nameWithFlag, conversation: conversation)
	}

	@MainActor
	private func insertDayCard(_ holidayDay: HolidayDay) {
		guard let conversation = activeConversation else { return }

		let dateStr = formatDate(day: holidayDay.day, month: holidayDay.month)
		let names = holidayDay.holidays.map(\.nameWithFlag)

		let cardView = HolidayDayShareCardView(date: dateStr, holidays: names)

		guard let image = renderCardToImage(cardView) else { return }
		insertImageMessage(image: image, caption: dateStr, conversation: conversation)
	}

	private func insertImageMessage(image: UIImage, caption: String, conversation: MSConversation) {
		let message = MSMessage()
		let layout = MSMessageTemplateLayout()
		layout.image = image
		layout.caption = caption
		message.layout = layout

		conversation.insert(message) { [weak self] error in
			if error == nil {
				self?.dismiss()
			}
		}
	}
}
