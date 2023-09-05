//
// Created by Andrzej Chmiel on 03/09/2023.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		if let preferences = Bundle.main.path(forResource: "defaults", ofType: "plist"),
		   let dict = NSDictionary(contentsOfFile: preferences) as? [String: Any] {
			UserDefaults.standard.register(defaults: dict)
		}
		return true
	}
}
