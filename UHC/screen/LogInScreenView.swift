//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct LogInScreenView: View {
	@EnvironmentObject var viewModel: AuthenticationViewModel

	var body: some View {
		NavigationView {
			VStack {
				Spacer()
				Image("Logo")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 256, height: 256, alignment: .center)
					.cornerRadius(48)
				Spacer()
				Button {
					viewModel.signInWithGoogle()
				} label: {
					HStack {
						Image("GoogleIcon")
							.renderingMode(.template)
							.resizable()
							.frame(maxWidth: 16, maxHeight: 16)
							.foregroundStyle(Color(.blue))
						Text("Sign in with Google")
					}
					.frame(width: 200)
				}
				.buttonStyle(BorderedButtonStyle())
				Button {
					viewModel.signInAnonymously()
				} label: {
					HStack {
						Image(systemName: "person")
						Text("Anonymous login")
					}
					.frame(width: 200)
				}
				.buttonStyle(BorderedButtonStyle())
				Spacer()
			}
			.padding()
		}
	}
}
