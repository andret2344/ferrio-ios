//
//  Created by Andrzej Chmiel on 04/09/2023.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

@main
struct FerrioApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var viewModel = AuthenticationViewModel()
	@StateObject var config = ObservableConfig.shared

	var body: some Scene {
		WindowGroup {
			Group {
				switch viewModel.state {
				case .signedIn:
					ContentView()
				case .signedOut:
					LogInView()
				case .unknown:
					ProgressView().progressViewStyle(.circular)
						.animation(.easeIn, value: viewModel.state)
				}
			}
			.environmentObject(viewModel)
			.environmentObject(config)
			.onOpenURL { url in
				_ = GIDSignIn.sharedInstance.handle(url)
				_ = Auth.auth().canHandle(url)
			}
		}
	}
}
