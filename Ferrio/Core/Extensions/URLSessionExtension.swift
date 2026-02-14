//
//  Created by Andrzej Chmiel on 01/09/2023.
//

import Foundation

enum API {
	static let baseURL = "https://api.ferrio.app/v2"

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

	func sendRequest(jsonData: Data, path: String) async throws {
		guard let url = URL(string: "\(API.baseURL)/\(path)") else { throw APIError.invalidURL }
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData

		let (_, response) = try await data(for: request)

		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
			throw APIError.unsuccessfulRequest(statusCode: statusCode)
		}
	}
}

enum APIError: LocalizedError {
	case unsuccessfulRequest(statusCode: Int)
	case invalidURL

	var errorDescription: String? {
		switch self {
		case .unsuccessfulRequest(let statusCode):
			String(format: "unsuccessful-request-%lld".localized(), statusCode)
		case .invalidURL:
			"invalid-url".localized()
		}
	}
}
