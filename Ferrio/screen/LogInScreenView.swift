//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct LogInScreenView: View {
	@State private var anonymousLoginAlert = false
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
				Text("Ferrio")
					.font(.largeTitle)
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
						Text("signin-google")
					}
					.frame(width: 200)
				}
				.buttonStyle(BorderedButtonStyle())
				Button {
					anonymousLoginAlert = true
				} label: {
					HStack {
						Image(systemName: "person")
						Text("login-anonymous")
					}
					.frame(width: 200)
				}
				.buttonStyle(BorderedButtonStyle())
				.alert("signin-anonymous-alert", isPresented: $anonymousLoginAlert) {
					Button("ok", role: .confirm) {
						viewModel.signInAnonymously()
					}
					Button("cancel", role: .cancel) {
						anonymousLoginAlert = false
					}
				}
				Spacer()
			}
			.padding()
		}
	}
}
