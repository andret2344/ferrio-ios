//
//  LogInController.swift
//  UHC
//
//  Created by Andrzej Chmiel on 18/04/2024.
//

import GoogleSignIn

class LogInController: UIViewController {
	private let signInWithGoogleButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: "googleIcon"), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		signInWithGoogleButton.addTarget(self, action: #selector(handleSignInWithGoogle), for: .touchUpInside)
	}
}

// MARK: - Sign in with Google section
extension LogInController {
	@objc fileprivate func handleSignInWithGoogle() {
		GIDSignIn.sharedInstance.signIn(withPresenting: self) { googleUser, error in
			if let error = error {
				return
			}
			
			// After Google returns a successful sign in, we get the users id and idToken
			guard let googleUser = googleUser,
				  let userId = googleUser.user.userID,
				  let idToken = googleUser.user.idToken
			else { fatalError("This should never happen!?") }
			
			print("logged in: \(googleUser.user)")
		}
	}
}
