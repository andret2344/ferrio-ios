//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import SwiftUI

struct MySuggestionsScreenView: View {
	@StateObject private var viewModel = SuggestionsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var expanded: Int? = nil

	var body: some View {
		Picker("select-missing-holidays-type", selection: $reportedHolidaysType) {
			Text("holidays-fixed").tag("fixed")
			Text("holidays-floating").tag("floating")
		}
		.pickerStyle(.segmented)
		.padding(.horizontal)
		List {
			if reportedHolidaysType == "fixed" {
				ForEach(viewModel.suggestionsFixed, id: \.id) { suggestion in
					renderFixedSuggestion(suggestion: suggestion)
				}
			} else {
				ForEach(viewModel.suggestionsFloating, id: \.id) { suggestion in
					renderFloatingSuggestion(suggestion: suggestion)
				}
			}
		}
		.refreshable {
			await viewModel.fetchData()
		}
		.navigationTitle("my-suggestions")
		.task {
			await viewModel.fetchData()
		}
	}

	func renderFixedSuggestion(suggestion: MissingFixedHoliday) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(suggestion.id == expanded ? nil : 2)
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
			expanded = expanded == suggestion.id ? nil : suggestion.id
		}
	}

	func renderFloatingSuggestion(suggestion: MissingFloatingHoliday) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(suggestion.id == expanded ? nil : 2)
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
			expanded = expanded == suggestion.id ? nil : suggestion.id
		}
	}
}

private func formatFixedDate(day: Int, month: Int) -> String {
	var components = DateComponents()
	components.day = day
	components.month = month
	components.year = Calendar.current.component(.year, from: Date())

	guard let date = Calendar.current.date(from: components) else {
		return "\(day).\(month)"
	}

	let formatter = DateFormatter()
	formatter.setLocalizedDateFormatFromTemplate("d MMMM")
	return formatter.string(from: date)
}
