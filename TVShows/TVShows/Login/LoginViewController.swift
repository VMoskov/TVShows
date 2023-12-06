//
//  LoginViewController.swift
//  TVShows
//
//  Created by Vedran Moškov on 11.07.2023..
//

import UIKit
import MBProgressHUD
import KeychainAccess

final class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var emailInput: UITextField!
    @IBOutlet private weak var passwordInput: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var eyeButton: UIButton!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var animatingView: UIStackView!
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction private func emailEditingChanged() {
        guard passwordInput.hasText else { return }
        setUpButtons(enabled: true)
        infoLabel.text = ""
    }
     
    @IBAction private func emailEditingEnd() {
        guard
            let email = emailInput.text,
            let password = passwordInput.text,
            !email.isEmpty,
            !password.isEmpty
        else { return }
        setUpButtons(enabled: false)
        infoLabel.text = "In order to continue please log in."
    }
    
    @IBAction private func passwordEditingChanged() {
        guard emailInput.hasText else { return }
        setUpButtons(enabled: true)
        infoLabel.text = ""
    }
    
    @IBAction private func passwordEditingEnd() {
        guard
            let email = emailInput.text,
            let password = passwordInput.text,
            !email.isEmpty,
            !password.isEmpty
        else { return }
        setUpButtons(enabled: false)
        infoLabel.text = "In order to continue please log in."
    }
    
    @IBAction private func rememberMeButtonHandler() {
        rememberMeButton.isSelected.toggle()
    }
    
    @IBAction private func eyeButtonHandler() {
        eyeButton.isSelected.toggle()
        passwordInput.isSecureTextEntry.toggle()
    }
    
    @IBAction func loginButtonHandler() {
        guard
            let email = emailInput.text,
            let password = passwordInput.text,
            !email.isEmpty,
            !password.isEmpty
        else { return }
                        
        let user = UserCredentials(email: email, password: password)
                        
        MBProgressHUD.showAdded(to: view, animated: true)

        APIManager.instance.performAPICall(
            router: .login(user: user),
            responseType: UserDecodable.self
        ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
                            
            switch serverResponse {
            case .success(_):
                if rememberMeButton.isSelected {
                    guard let authInfo = APIManager.instance.authInfo else { return }
                    rememberUser(user: authInfo)
                }
                pushHomeViewController()
            case.failure(let apiError):
                shakeInputFields()
                showAlert("Login", error: apiError as? APIError ?? APIError(errors: [""]))
                print("API call failed with error: \(apiError)")
            }
        }
    }
    
    @IBAction func registerButtonHandler() {
        guard
            let email = emailInput.text,
            let password = passwordInput.text,
            !email.isEmpty,
            !password.isEmpty
        else { return }
                        
        let user = UserCredentials(email: email, password: password)
                        
        MBProgressHUD.showAdded(to: view, animated: true)

        APIManager.instance.performAPICall(
            router: .registration(user: user),
            responseType: UserDecodable.self
        ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
                            
            switch serverResponse {
            case .success(_):
                if rememberMeButton.isSelected {
                    guard let authInfo = APIManager.instance.authInfo else { return }
                    rememberUser(user: authInfo)
                }
                pushHomeViewController()
            case.failure(let apiError):
                shakeInputFields()
                showAlert("Registration", error: apiError as? APIError ?? APIError(errors: [""]))
                print("API call failed with error: \(apiError)")
            }
        }
    }
    
    // MARK: - Utility methods
    
    private func setUpUI() {
        eyeButton.setImage(UIImage(named: "ic-visible.pdf"), for: .normal)
        eyeButton.setImage(UIImage(named: "ic-invisible.pdf"), for: .selected)
        
        rememberMeButton.setImage(UIImage(named: "ic-checkbox-selected.pdf"), for: .selected)
        rememberMeButton.setImage(UIImage(named: "ic-checkbox-unselected.pdf"), for: .normal)
        rememberMeButton.setTitle("", for: .normal)
        
        setUpButtons(enabled: false)
    }
    
    private func setUpButtons(enabled: Bool) {
        setLoginButton(enabled: enabled)
        setRegisterButton(enabled: enabled)
    }
    
    private func setLoginButton(enabled: Bool) {
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1 : 0.5
    }
    
    private func setRegisterButton(enabled: Bool) {
        registerButton.isEnabled = enabled
        registerButton.setTitleColor(.white, for: .disabled)
        registerButton.alpha = enabled ? 1 : 0.5
    }
    
    private func pushHomeViewController() {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = homeStoryboard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as! HomeViewController
        navigationController?.setViewControllers([homeViewController], animated: true)
    }
    
    private func rememberUser(user: AuthInfo) {
        let keychain = Keychain()
        do {
            let userAuthInfo = try JSONEncoder().encode(user)
            try keychain.set(userAuthInfo, key: "userAuthInfo")
        } catch {
            print("Error encoding AuthInfo")
        }
    }
    
    // MARK: - Animations
    
    private func shakeInputFields() {
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.07
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: animatingView.center.x - 10, y: animatingView.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: animatingView.center.x + 10, y: animatingView.center.y))
        
        animatingView.layer.add(shakeAnimation, forKey: "position")
    }
    
}

extension UIViewController {
    func showAlert(_ action: String, error: APIError) {
        let alert = UIAlertController(
            title: "\(action) failed",
            message: error.errors.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
