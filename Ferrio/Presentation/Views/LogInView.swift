//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import SwiftUI

struct LogInView: View {
	@State private var anonymousLoginAlert = false
	@EnvironmentObject var viewModel: AuthenticationViewModel

	var body: some View {
		NavigationStack {
			VStack {
				Spacer()
				Image("Logo")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 256, height: 256, alignment: .center)
					.clipShape(RoundedRectangle(cornerRadius: 48))
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
					viewModel.signInWithGitHub()
				} label: {
					HStack {
						Image("GithubIcon")
							.renderingMode(.template)
							.resizable()
							.frame(maxWidth: 16, maxHeight: 16)
							.foregroundStyle(Color(.blue))
						Text("signin-github")
					}
					.frame(width: 200)
				}
				.buttonStyle(BorderedButtonStyle())
				Button {
					anonymousLoginAlert = true
				} label: {
					HStack {
						Image(systemName: "person")
						Text("signin-anonymous")
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
			.alert("account-linking-required", isPresented: Binding(
				get: { viewModel.linkingError != nil },
				set: { if !$0 { viewModel.dismissLinkingError() } }
			)) {
				Button("ok") { viewModel.dismissLinkingError() }
				Button("cancel", role: .cancel) { viewModel.dismissLinkingError() }
			} message: {
				if let error = viewModel.linkingError {
					Text(error.message)
				}
			}
		}
	}
}
