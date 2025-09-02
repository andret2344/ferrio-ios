//
//  Created by Andrzej Chmiel on 01/09/2023.
//

import Foundation

public extension URLSession {
	func decode<T: Decodable>(
		_ type: T.Type = T.self,
		from url: URL,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
		dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
	) async throws -> T {
		let (data, _) = try await data(from: url)

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		decoder.dataDecodingStrategy = dataDecodingStrategy
		decoder.dateDecodingStrategy = dateDecodingStrategy

		let decoded = try decoder.decode(T.self, from: data)
		return decoded
	}

	func sendRequest(jsonData: Data, path: String, callback: @escaping (String?, Bool) -> Void) {
		guard let url = URL(string: "https://api.unusualcalendar.net/v2/\(path)") else { return }
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData

		dataTask(with: request) { data, response, error in
			if error != nil {
				callback("Could not connect to server. Please try again later.", false)
				return;
			}

			let httpResponse = response as? HTTPURLResponse
			guard let response = httpResponse, response.statusCode / 100 == 2 else {
				callback("The request was unsuccessfull. Please try again later. Response code: \(httpResponse?.statusCode ?? -1).", false)
				return;
			}

			callback(nil, true)
		}.resume()
	}
}
