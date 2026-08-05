//
// Created by Andrzej Chmiel on 03/08/2026.
//

import Testing
import Foundation
@testable import Ferrio

/// `groupIntoHolidayDays` is the only transformation between the API payload and what both the app
/// and the widget render, so it is worth pinning independently of the network.
struct HolidayRepositoryTests {
	private func decode(_ json: String) throws -> [HolidayDTO] {
		try JSONDecoder().decode([HolidayDTO].self, from: Data(json.utf8))
	}

	@Test("holidays sharing a date end up in one day")
	func groupsByDate() throws {
		let dtos = try decode("""
		[
		 {"id":"fixed-1","day":9,"month":2,"name":"Pizza","usual":false,"description":"","country":null,"url":"","mature_content":false},
		 {"id":"fixed-2","day":9,"month":2,"name":"Bagel","usual":false,"description":"","country":null,"url":"","mature_content":false},
		 {"id":"fixed-3","day":10,"month":2,"name":"Other","usual":false,"description":"","country":null,"url":"","mature_content":false}
		]
		""")

		let days = HolidayRepository.groupIntoHolidayDays(dtos)

		#expect(days.count == 2)
		let ninth = days.first { $0.day == 9 && $0.month == 2 }
		#expect(ninth?.holidays.count == 2)
	}

	@Test("the same day number in different months stays separate")
	func doesNotCollideAcrossMonths() throws {
		let dtos = try decode("""
		[
		 {"id":"fixed-1","day":1,"month":1,"name":"A","usual":false,"description":"","country":null,"url":"","mature_content":false},
		 {"id":"fixed-2","day":1,"month":11,"name":"B","usual":false,"description":"","country":null,"url":"","mature_content":false}
		]
		""")

		#expect(HolidayRepository.groupIntoHolidayDays(dtos).count == 2)
	}

	@Test("a response predating the ai_generated flag still decodes")
	func aiGeneratedDefaultsToFalse() throws {
		let dtos = try decode("""
		[{"id":"fixed-1","day":1,"month":1,"name":"A","usual":false,"description":"","country":null,"url":"","mature_content":false}]
		""")

		#expect(dtos.first?.toHoliday.aiGenerated == false)
	}

	@Test("ai_generated survives the DTO conversion")
	func aiGeneratedIsCarriedOver() throws {
		let dtos = try decode("""
		[{"id":"fixed-1","day":1,"month":1,"name":"A","usual":false,"description":"","country":null,"url":"","mature_content":false,"ai_generated":true}]
		""")

		#expect(dtos.first?.toHoliday.aiGenerated == true)
	}

	@Test("an empty payload produces no days rather than an empty placeholder")
	func emptyPayload() throws {
		#expect(HolidayRepository.groupIntoHolidayDays(try decode("[]")).isEmpty)
	}
}

struct HolidayFilteringTests {
	private func holiday(id: String, usual: Bool = false, mature: Bool = false) -> Holiday {
		Holiday(id: id, usual: usual, name: id, description: "", url: "",
				countryCode: nil, matureContent: mature, aiGenerated: false)
	}

	@Test("usual and mature holidays are hidden unless asked for")
	func filtersByConfiguration() {
		let day = HolidayDay(day: 1, month: 1, holidays: [
			holiday(id: "plain"),
			holiday(id: "usual", usual: true),
			holiday(id: "mature", mature: true)
		])

		#expect(day.getHolidays(includeUsual: false, showAdult: false).map(\.id) == ["plain"])
		#expect(day.getHolidays(includeUsual: true, showAdult: false).map(\.id) == ["plain", "usual"])
		#expect(day.getHolidays(includeUsual: false, showAdult: true).map(\.id) == ["plain", "mature"])
		#expect(day.getHolidays(includeUsual: true, showAdult: true).count == 3)
	}

	@Test("ids prefixed floating- are recognised as floating")
	func floatingDetection() {
		#expect(holiday(id: "floating-12").isFloating)
		#expect(!holiday(id: "fixed-12").isFloating)
	}
}
