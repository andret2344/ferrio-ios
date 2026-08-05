//
// Created by Andrzej Chmiel on 02/08/2026.
//

import Foundation

/// Single source of the FAQ content. The list is bundled with the app rather than fetched from
/// api.ferrio.app on purpose: the entries change far less often than the app ships, and the AI
/// disclosure in particular must never depend on a successful network call. Everything that reads
/// the FAQ goes through `entries`, so swapping the backing source later is a change in this type
/// only.
///
/// Order follows the user's path: what is displayed, where the content comes from, how to change
/// it, account, then technical questions.
enum FaqCatalog {
	static let entries: [FaqEntry] = [
		FaqEntry(id: "hidden-holidays"),
		FaqEntry(id: "colorized-days"),
		FaqEntry(id: "missing-holiday"),
		FaqEntry(id: "who-writes"),
		FaqEntry(id: "report-error"),
		FaqEntry(id: "suggest"),
		FaqEntry(id: "statuses"),
		FaqEntry(id: "rejected"),
		FaqEntry(id: "account-types"),
		FaqEntry(id: "delete-account"),
		FaqEntry(id: "data-freshness"),
		FaqEntry(id: "widget")
	]
}
