//
//  Created by Claude on 20/02/2026.
//

import FirebaseAuth
import Foundation

extension URLSession {
	func authenticatedDecode<T: Decodable>(
		_ type: T.Type = T.self,
		from url: URL,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
	) async throws -> T {
		var request = URLRequest(url: url)
		try await request.addFirebaseAuth()

		let (data, responseRaw) = try await data(for: request)
		let statusCode = (responseRaw as? HTTPURLResponse)?.statusCode ?? -1

		guard (200...299).contains(statusCode) else {
			throw APIError.unsuccessfulRequest(statusCode: statusCode)
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			throw error
		}
	}

	func authenticatedPost(jsonData: Data, url: URL) async throws {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		try await request.addFirebaseAuth()

		let (_, response) = try await data(for: request)

		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
			throw APIError.unsuccessfulRequest(statusCode: statusCode)
		}
	}
}

private extension URLRequest {
	mutating func addFirebaseAuth() async throws {
		guard let user = Auth.auth().currentUser else {
			throw APIError.notAuthenticated
		}
		let token = try await user.getIDToken()
		setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
