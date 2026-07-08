//
//  Created by Andrzej Chmiel on 09/08/2024.
//

import Foundation

enum ReportType: String, Encodable, CaseIterable {
	case WRONG_NAME
	case WRONG_DESCRIPTION
	case WRONG_DATE
	case OTHER
}

struct HolidayReportPayload: Encodable {
	var metadata: Int
	var language: String
	var reportType: ReportType
	var description: String
	var device: DeviceMetadata = .current()
}

/// Non-sensitive device metadata attached to reports and suggestions so the backend can triage
/// them per platform/device/version. Keys match the API's `DeviceDTO` shape and mirror the Android
/// `DeviceMetadata` helper. All values come from the system and locale, so no permissions are needed.
struct DeviceMetadata: Encodable {
	let platform: String
	let model: String
	let osVersion: String
	let appVersion: String
	let appBuild: Int
	let country: String?

	enum CodingKeys: String, CodingKey {
		case platform, model, country
		case osVersion = "os_version"
		case appVersion = "app_version"
		case appBuild = "app_build"
	}

	static func current() -> DeviceMetadata {
		DeviceMetadata(
			platform: "ios",
			model: deviceModel(),
			osVersion: systemVersion(),
			appVersion: appVersion(),
			appBuild: appBuild(),
			country: deviceCountry()
		)
	}

	private static func deviceModel() -> String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let identifier = withUnsafeBytes(of: &systemInfo.machine) { raw -> String in
			let bytes = raw.prefix { $0 != 0 }
			return String(decoding: bytes, as: UTF8.self)
		}
		return identifier.isEmpty ? "unknown" : identifier
	}

	private static func systemVersion() -> String {
		let version = ProcessInfo.processInfo.operatingSystemVersion
		if version.patchVersion == 0 {
			return "\(version.majorVersion).\(version.minorVersion)"
		}
		return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
	}

	private static func appVersion() -> String {
		(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
	}

	private static func appBuild() -> Int {
		guard let value = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
			return 0
		}
		return Int(value) ?? 0
	}

	// API stores device_country as VARCHAR(2), so only ISO 3166-1 alpha-2 region codes qualify.
	private static func deviceCountry() -> String? {
		guard let region = Locale.current.region?.identifier, region.count == 2 else {
			return nil
		}
		return region.uppercased()
	}
}
