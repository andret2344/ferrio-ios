//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI
import GoogleSignIn

@main
struct FerrioApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var viewModel = AuthenticationViewModel()

	var body: some Scene {
		WindowGroup {
			Group {
				if viewModel.state == .signedIn {
					ContentView()
				} else {
					LogInScreenView()
				}
			}
			.environmentObject(viewModel)
			.onOpenURL { url in
				_ = GIDSignIn.sharedInstance.handle(url)
			}
		}
	}
}
