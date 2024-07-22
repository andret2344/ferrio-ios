//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct LogInScreenView: View {
	@EnvironmentObject var viewModel: AuthenticationViewModel

	var body: some View {
		NavigationView {
			VStack {
				Button {
					viewModel.signIn()
				} label: {
					Text("GoogleButton")
				}
			}
			.padding()
		}
	}

	func getRootViewController() -> UIViewController {
		guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
			return .init()
		}

		guard let root = screen.windows.first?.rootViewController else {
			return .init()
		}

		return root
	}
}
