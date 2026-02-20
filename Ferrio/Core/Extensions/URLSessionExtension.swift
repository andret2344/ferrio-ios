//
//  Created by Andrzej Chmiel on 01/09/2023.
//

import Foundation

enum API {
	static let baseURL = "https://api.ferrio.app/v3"

	static var language: String {
		let code = Locale.current.language.languageCode?.identifier ?? ""
		return ["pl"].contains(code) ? code : "en"
	}
}

extension URLSession {
	func decode<T: Decodable>(
		_ type: T.Type = T.self,
		from url: URL,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
		dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
	) async throws -> T {
		let (data, response) = try await data(from: url)

		if let httpResponse = response as? HTTPURLResponse,
		   !(200...299).contains(httpResponse.statusCode) {
			throw APIError.unsuccessfulRequest(statusCode: httpResponse.statusCode)
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		decoder.dataDecodingStrategy = dataDecodingStrategy
		decoder.dateDecodingStrategy = dateDecodingStrategy

		let decoded = try decoder.decode(T.self, from: data)
		return decoded
	}

}

enum APIError: LocalizedError {
	case unsuccessfulRequest(statusCode: Int)
	case invalidURL
	case notAuthenticated

	var errorDescription: String? {
		switch self {
		case .unsuccessfulRequest(let statusCode):
			String(format: "unsuccessful-request-%lld".localized(), statusCode)
		case .invalidURL:
			"invalid-url".localized()
		case .notAuthenticated:
			"not-authenticated".localized()
		}
	}
}
