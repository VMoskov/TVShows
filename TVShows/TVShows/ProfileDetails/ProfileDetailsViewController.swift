//
//  ProfileDetailsViewController.swift
//  TVShows
//
//  Created by Vedran Moškov on 01.08.2023..
//

import UIKit
import MBProgressHUD
import Kingfisher
import KeychainAccess
import Alamofire

final class ProfileDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var userEmail: UILabel!
    @IBOutlet private weak var profilePicture: UIImageView!
    
    // MARK: - Properties
    
    private var user: User?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        getUserInfo()
    }
    
    // MARK: - Actions
    
    @IBAction func changeProfilePhoto() {
        showImagePicker()
    }
    
    // MARK: - Utility methods
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(dismissScreen)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(
            red: 82/255,
            green: 54/255,
            blue: 140/255,
            alpha: 1
        )
    }
    
    @objc private func dismissScreen() {
        dismiss(animated: true, completion: nil)
    }
    
    private func getUserInfo() {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        APIManager.instance.performAPICall(
            router: .getUserInfo,
            responseType: UserDecodable.self
        ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
            
            switch serverResponse {
            case .success(let userResponse):
                user = userResponse.user
                guard let user else { return }
                loadUser(user)
            case .failure(let error):
                print("API call failed with error: \(error)")
            }
        }
    }
    
    private func loadUser(_ user: User) {
        userEmail.text = user.email
        profilePicture.kf.setImage(
            with: URL(string: user.imageUrl ?? ""),
            placeholder: UIImage(named: "ic-profile-placeholder")
        )
        
    }
    
    @IBAction func logOutButtonHandler() {
        dismiss(animated: true) {
            let keychain = Keychain()
            try? keychain.remove("userAuthInfo")
            APIManager.instance.authInfo = nil
            let logoutNotificationName = Notification.Name("DidLogoutNotification")
            NotificationCenter.default.post(name: logoutNotificationName, object: nil)
        }
    }
    
    private func storeImage(_ image: UIImage) {
        MBProgressHUD.showAdded(to: view, animated: true)
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        APIManager.instance.uploadImage(imageData) { [weak self] response in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
            
            switch response {
            case .success(let userResponse):
                loadUser(userResponse.user)
            case .failure(let apiError):
                showAlert("Image upload", error: apiError as? APIError ?? APIError(errors: [""]))
                print("API call failed with error: \(apiError)")
            }
            
        }
    }
    
}


extension ProfileDetailsViewController: UINavigationControllerDelegate {
    
    private func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ProfileDetailsViewController: UIImagePickerControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            storeImage(selectedImage)
            dismiss(animated: true, completion: nil)
        }
    }
    
}
