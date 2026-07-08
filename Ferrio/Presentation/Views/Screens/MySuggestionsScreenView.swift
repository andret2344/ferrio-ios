//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import SwiftUI

struct MySuggestionsScreenView: View {
	let holidayDays: [HolidayDay]
	@StateObject private var viewModel = SuggestionsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var selectedFixed: MissingFixedHoliday?
	@State private var selectedFloating: MissingFloatingHoliday?

	var body: some View {
		VStack(spacing: 0) {
			Picker("select-missing-holidays-type", selection: $reportedHolidaysType) {
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
						if viewModel.suggestionsFixed.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.suggestionsFixed) { suggestion in
								renderFixedSuggestion(suggestion: suggestion)
							}
						}
					} else {
						if viewModel.suggestionsFloating.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.suggestionsFloating) { suggestion in
								renderFloatingSuggestion(suggestion: suggestion)
							}
						}
					}
				}
				.refreshable {
					await viewModel.fetchData()
				}
			}
		}
		.navigationTitle("my-suggestions")
		.task {
			await viewModel.fetchData()
		}
		.sheet(item: $selectedFixed) { suggestion in
			ReportDetailsSheetView(
				title: suggestion.name,
				state: suggestion.reportState,
				description: suggestion.description,
				comment: suggestion.comment,
				dateInfo: formatFixedDate(day: suggestion.day, month: suggestion.month),
				countryCode: suggestion.country,
				datetime: suggestion.datetime,
				linkedHoliday: findHoliday(holidayId: suggestion.holidayId, isFloating: false)
			)
		}
		.sheet(item: $selectedFloating) { suggestion in
			ReportDetailsSheetView(
				title: suggestion.name,
				state: suggestion.reportState,
				description: suggestion.description,
				comment: suggestion.comment,
				dateInfo: suggestion.date,
				countryCode: suggestion.country,
				datetime: suggestion.datetime,
				linkedHoliday: findHoliday(holidayId: suggestion.holidayId, isFloating: true)
			)
		}
	}

	private var emptyState: some View {
		ContentUnavailableView("no-suggestions", systemImage: "checkmark.circle")
			.listRowBackground(Color.clear)
	}

	private func hasComment(_ comment: String?) -> Bool {
		guard let comment else { return false }
		return !comment.isEmpty
	}

	private func findHoliday(holidayId: Int?, isFloating: Bool) -> Holiday? {
		guard let holidayId else { return nil }
		for day in holidayDays {
			for holiday in day.holidays where holiday.isFloating == isFloating && holiday.numericId == holidayId {
				return holiday
			}
		}
		return nil
	}

	func renderFixedSuggestion(suggestion: MissingFixedHoliday) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top, spacing: 6) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				if hasComment(suggestion.comment) {
					Image(systemName: "text.bubble")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(2)
				.foregroundStyle(.secondary)
			HStack {
				Text(formatFixedDate(day: suggestion.day, month: suggestion.month))
				Text("·")
				Text(formatDatetime(suggestion.datetime))
			}
			.font(.caption)
			.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			selectedFixed = suggestion
		}
	}

	func renderFloatingSuggestion(suggestion: MissingFloatingHoliday) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top, spacing: 6) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				if hasComment(suggestion.comment) {
					Image(systemName: "text.bubble")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(2)
				.foregroundStyle(.secondary)
			HStack {
				Text(suggestion.date)
				Text("·")
				Text(formatDatetime(suggestion.datetime))
			}
			.font(.caption)
			.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
		.onTapGesture {
			selectedFloating = suggestion
		}
	}
}

