//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
	@Published var state: SignInState = .signedOut

	func initialLogin() {
		guard let clientID = FirebaseApp.app()?.options.clientID else { return }

		let configuration = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.configuration = configuration

		if GIDSignIn.sharedInstance.hasPreviousSignIn() {
			GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
				self.authenticateUser(user!, error: error)
			}
		}
	}

	func signIn() {
		if GIDSignIn.sharedInstance.hasPreviousSignIn() {
			GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
				self.authenticateUser(user!, error: error)
			}
		} else {
			guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
			guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

			GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
				self.authenticateUser(result!.user, error: error)
			}
		}
	}

	private func authenticateUser(_ user: GIDGoogleUser, error: Error?) {
		if let error = error {
			print(error)
			return
		}

		guard let idToken = user.idToken?.tokenString
		else {
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
		case signedIn, signedOut
	}
}
