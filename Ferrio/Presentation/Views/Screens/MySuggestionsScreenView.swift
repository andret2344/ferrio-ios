//
//  Created by Andrzej Chmiel on 25/07/2024.
//

import SwiftUI

struct MySuggestionsScreenView: View {
	@StateObject private var viewModel = SuggestionsViewModel()
	@State private var reportedHolidaysType: String = "fixed"
	@State private var expandedFixed: Int? = nil
	@State private var expandedFloating: Int? = nil

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
							ForEach(viewModel.suggestionsFixed, id: \.id) { suggestion in
								renderFixedSuggestion(suggestion: suggestion, expanded: $expandedFixed)
							}
						}
					} else {
						if viewModel.suggestionsFloating.isEmpty {
							emptyState
						} else {
							ForEach(viewModel.suggestionsFloating, id: \.id) { suggestion in
								renderFloatingSuggestion(suggestion: suggestion, expanded: $expandedFloating)
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
	}

	private var emptyState: some View {
		ContentUnavailableView("no-suggestions", systemImage: "checkmark.circle")
			.listRowBackground(Color.clear)
	}

	func renderFixedSuggestion(suggestion: MissingFixedHoliday, expanded: Binding<Int?>) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(suggestion.id == expanded.wrappedValue ? nil : 2)
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
			expanded.wrappedValue = expanded.wrappedValue == suggestion.id ? nil : suggestion.id
		}
	}

	func renderFloatingSuggestion(suggestion: MissingFloatingHoliday, expanded: Binding<Int?>) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top) {
				Text(suggestion.name)
					.fontWeight(.semibold)
				Spacer()
				StatusBadge(state: suggestion.reportState)
			}
			Text(suggestion.description)
				.lineLimit(suggestion.id == expanded.wrappedValue ? nil : 2)
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
			expanded.wrappedValue = expanded.wrappedValue == suggestion.id ? nil : suggestion.id
		}
	}
}
