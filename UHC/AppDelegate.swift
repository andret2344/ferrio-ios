//
// Created by Andrzej Chmiel on 03/09/2023.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "MY_CLIENT_ID")
		GIDSignIn.sharedInstance.restorePreviousSignIn()
		FirebaseApp.configure()
		return true
	}
	
	func application(_ app: UIApplication,
					 open url: URL,
					 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		return GIDSignIn.sharedInstance.handle(url)
	}
}
