//
//  SceneDelegate.swift
//  TVShows
//
//  Created by Vedran Moškov on 10.07.2023..
//

import UIKit
import KeychainAccess

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigationController = UINavigationController()
        setUpNavigationController(with: navigationController)
        
        let keychain = Keychain()
        setUpControllers(with: navigationController)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
            
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func setUpControllers(with navigationController: UINavigationController) {
        let keychain = Keychain()
        
        if let userData = try? keychain.getData("userAuthInfo"),
           let authInfo = try? JSONDecoder().decode(AuthInfo.self, from: userData) {
            APIManager.instance.authInfo = authInfo
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(
                withIdentifier: String(describing: HomeViewController.self)
            ) as! HomeViewController
            navigationController.viewControllers = [homeViewController]
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self)
            ) as! LoginViewController
            navigationController.viewControllers = [loginViewController]
        }

    }

    private func setUpNavigationController(with navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )
        navigationController.navigationBar.tintColor = UIColor(
            red: 82/255,
            green: 54/255,
            blue: 140/255,
            alpha: 1
        )
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.largeTitleDisplayMode = .always
    }

}
