//
// Created by Andrzej Chmiel on 02/08/2026.
//

import Foundation

/// A single question/answer pair of the in-app FAQ. Only the identifier is stored: both sides live
/// in `Localizable.xcstrings` under `faq-question-<id>` and `faq-answer-<id>`, so the content
/// follows the existing translation pipeline and stays available without a network call.
struct FaqEntry: Identifiable, Equatable {
	let id: String

	var question: String {
		"faq-question-\(id)".localized()
	}

	/// Answers carry inline markup (emphasis, the privacy policy link) and blank lines, so they are
	/// authored as Markdown in the catalog. `Text(LocalizedStringKey)` parses Markdown inline only
	/// and would swallow the line breaks, hence the explicit parsing with whitespace preserved.
	var answer: AttributedString {
		let raw = "faq-answer-\(id)".localized()
		let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
		return (try? AttributedString(markdown: raw, options: options)) ?? AttributedString(raw)
	}
}
