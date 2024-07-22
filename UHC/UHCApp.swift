//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

@main
struct UHCApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var viewModel = AuthenticationViewModel()

	var body: some Scene {
		WindowGroup {
			if viewModel.state == .signedIn {
				ContentView()
					.environmentObject(viewModel)
			} else  {
				LogInScreenView()
					.environmentObject(viewModel)

			}
		}
	}
}
