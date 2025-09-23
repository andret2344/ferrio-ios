//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthenticationViewModel: ObservableObject {
	@Published var state: SignInState = .unknown
	private var authListenerHandle: AuthStateDidChangeListenerHandle?

	init() {
		authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
			self?.state = (user != nil) ? .signedIn : .signedOut
		}
	}

	deinit {
		if let handle = authListenerHandle {
			Auth.auth().removeStateDidChangeListener(handle)
		}
	}

	func signInWithGoogle() {
		guard let clientID = FirebaseApp.app()?.options.clientID else { return }

		let configuration = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.configuration = configuration

		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
		guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

		GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
			Task { @MainActor in
				self.authenticateUser(result?.user, error: error)
			}
		}
	}

	func signInWithGitHub() {
		let provider = OAuthProvider(providerID: "github.com")
		provider.scopes = ["read:user", "user:email"]
		print("1")

		provider.getCredentialWith(nil) { [weak self] (credential: AuthCredential?, error: Error?) in
			print("1.5")
			guard let self = self else { return }

			if let error = error {
				print("GitHub credential error:", error)
				return
			}
			guard let credential = credential else {
				print("No credential returned")
				return
			}
			print("3")

			Auth.auth().signIn(with: credential) { [weak self] _, error in
				guard let self = self else { return }
				print("4")
				if let error = error {
					print("GitHub sign-in error:", error)
					return
				}
				print("5")
				self.state = .signedIn
			}
		}
	}

	func signInAnonymously() {
		Auth.auth().signInAnonymously()
	}

	private func authenticateUser(_ user: GIDGoogleUser?, error: Error?) {
		if let error = error {
			print(error)
			return
		}

		guard let user = user else {
			return
		}

		guard let idToken = user.idToken?.tokenString else {
			return
		}

		let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken,
																	   accessToken: user.accessToken.tokenString)

		Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
			if let error = error {
				print(error.localizedDescription)
			} else {
				self.state = .signedIn
			}
		}
	}

	func signOut() {
		GIDSignIn.sharedInstance.signOut()

		do {
			try Auth.auth().signOut()
			state = .signedOut
		} catch {
			print(error.localizedDescription)
		}
	}

	enum SignInState {
		case signedIn, signedOut, unknown
	}
}
