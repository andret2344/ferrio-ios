//
//  Created by Andrzej Chmiel on 22/07/2024.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import WidgetKit

@MainActor
class AuthenticationViewModel: ObservableObject {
	@Published var state: SignInState = .unknown
	@Published var linkingError: LinkingError?
	private var authListenerHandle: AuthStateDidChangeListenerHandle?
	private var pendingCredential: AuthCredential?

	init() {
		authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
			self?.state = (user != nil) ? .signedIn : .signedOut
			ObservableConfig.isRealUserLoggedIn = user != nil && !(user?.isAnonymous ?? true)
			WidgetCenter.shared.reloadAllTimelines()
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

		GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
			Task { @MainActor in
				await self?.authenticateWithGoogle(result?.user, error: error)
			}
		}
	}

	func signInWithGitHub() {
		let provider = OAuthProvider(providerID: "github.com")
		provider.scopes = ["user:email"]

		Task { @MainActor in
			do {
				let result = try await provider.credential(with: nil)

				try await Auth.auth().signIn(with: result)

				if self.pendingCredential != nil {
					await self.linkPendingCredential()
				} else {
					self.state = .signedIn
				}
			} catch let error as NSError {
				if error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
					if let updatedCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
						self.pendingCredential = updatedCredential
					}

					if let email = error.userInfo[AuthErrorUserInfoEmailKey] as? String {
						self.linkingError = LinkingError(
							message: String(format: "account-exists-with-email-%@".localized(), email),
							email: email
						)
					} else {
						self.linkingError = LinkingError(message: "account-exists-generic".localized())
					}
				}
			}
		}
	}

	func signInAnonymously() {
		Auth.auth().signInAnonymously()
	}

	func linkPendingCredential() async {
		guard let credential = pendingCredential else { return }

		do {
			if let currentUser = Auth.auth().currentUser {
				try await currentUser.link(with: credential)
				pendingCredential = nil
				linkingError = nil
				state = .signedIn
			}
		} catch {
				linkingError = LinkingError(message: String(format: "link-accounts-failed-%@".localized(), error.localizedDescription))
		}
	}

	func dismissLinkingError() {
		linkingError = nil
		pendingCredential = nil
	}

	private func authenticateWithGoogle(_ user: GIDGoogleUser?, error: Error?) async {
		if error != nil {
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

		await signIn(with: credential, providerName: "Google")
	}

	private func signIn(with credential: AuthCredential, providerName: String) async {
		do {
			try await Auth.auth().signIn(with: credential)

			// If there's a pending credential, link it now
			if pendingCredential != nil {
				await linkPendingCredential()
			} else {
				state = .signedIn
			}
		} catch let error as NSError {
			if error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
				// Store the credential for later linking
				pendingCredential = credential

				// Get the email from the error
				if let email = error.userInfo[AuthErrorUserInfoEmailKey] as? String {
					linkingError = LinkingError(
						message: String(format: "account-exists-with-email-%@".localized(), email),
						email: email
					)
				} else {
					linkingError = LinkingError(message: "account-exists-generic".localized())
				}
			}
		}
	}

	func signOut() {
		GIDSignIn.sharedInstance.signOut()

		do {
			try Auth.auth().signOut()
			state = .signedOut
		} catch {
			state = .signedOut
		}
	}

	var isAnonymous: Bool {
		Auth.auth().currentUser?.isAnonymous ?? true
	}

	enum SignInState {
		case signedIn, signedOut, unknown
	}

	struct LinkingError: Identifiable {
		let id = UUID()
		let message: String
		var email: String?
	}
}
