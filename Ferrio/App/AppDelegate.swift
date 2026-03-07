//
// Created by Andrzej Chmiel on 03/09/2023.
//

import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()

		let info = Bundle.main.infoDictionary
		let defaults = UserDefaults.standard
		defaults.set(info?["CFBundleShortVersionString"] as? String ?? "—", forKey: "app_version")
		defaults.set(info?["CFBundleVersion"] as? String ?? "—", forKey: "app_build")

		return true
	}
}
