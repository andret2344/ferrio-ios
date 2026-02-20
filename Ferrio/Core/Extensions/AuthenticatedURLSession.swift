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

		let (data, response) = try await data(for: request)

		if let httpResponse = response as? HTTPURLResponse,
		   !(200...299).contains(httpResponse.statusCode) {
			throw APIError.unsuccessfulRequest(statusCode: httpResponse.statusCode)
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy
		return try decoder.decode(T.self, from: data)
	}

	func authenticatedPost(jsonData: Data, url: URL) async throws {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		try await request.addFirebaseAuth()

		print("[API POST] \(url)")
		print("[API POST] Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")

		let (responseData, response) = try await data(for: request)

		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
			print("[API POST] Error \(statusCode): \(String(data: responseData, encoding: .utf8) ?? "nil")")
			throw APIError.unsuccessfulRequest(statusCode: statusCode)
		}
		print("[API POST] Success \(httpResponse.statusCode)")
	}
}

private extension URLRequest {
	mutating func addFirebaseAuth() async throws {
		guard let user = Auth.auth().currentUser else {
			throw APIError.notAuthenticated
		}
		let token = try await user.getIDToken()
		addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
	}
}
