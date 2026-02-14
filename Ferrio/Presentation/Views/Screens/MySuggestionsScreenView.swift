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
					HStack {
						VStack {
							Text("\(String(format: "%02d", suggestion.month)).\(String(format: "%02d", suggestion.day))")
								.italic()
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.name)
								.bold()
								.lineLimit(suggestion.id == expanded ? nil : 1)
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.description)
								.lineLimit(suggestion.id == expanded ? nil : 2)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						Spacer()
						Text(suggestion.reportState.rawValue.localized())
							.foregroundStyle(Color(UIColor.systemBackground))
							.frame(width: 108, height: 32)
							.background(RoundedRectangle(cornerRadius: 8).fill(suggestion.reportState.color))
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
					}
					.contentShape(Rectangle())
					.onTapGesture {
						if expanded == suggestion.id {
							expanded = nil
						} else {
							expanded = suggestion.id
						}
					}
				}
			} else {
				ForEach(viewModel.suggestionsFloating, id: \.id) { suggestion in
					HStack {
						VStack {
							Text(suggestion.date)
								.italic()
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.name)
								.bold()
								.lineLimit(suggestion.id == expanded ? nil : 1)
								.frame(maxWidth: .infinity, alignment: .leading)
							Text(suggestion.description)
								.lineLimit(suggestion.id == expanded ? nil : 2)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						Spacer()
						Text(suggestion.reportState.rawValue.localized())
							.foregroundStyle(Color(UIColor.systemBackground))
							.frame(width: 108, height: 32)
							.background(RoundedRectangle(cornerRadius: 8).fill(suggestion.reportState.color))
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
					}
					.contentShape(Rectangle())
					.onTapGesture {
						if expanded == suggestion.id {
							expanded = nil
						} else {
							expanded = suggestion.id
						}
					}
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
}
