//
//  HomeViewController.swift
//  TVShows
//
//  Created by Vedran Moškov on 15.07.2023..
//

import UIKit
import MBProgressHUD
import Kingfisher

final class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var shows = [Show]()
    private var currentPage = 1
    private var itemsPerPage = 25
    private var numberOfShows = 0
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getShows()
        setUpNavigationBar()
        setUpTableView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveLogoutNotification(_:)),
            name: Notification.Name("DidLogoutNotification"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func profileDetailsActionHandler() {
        presentProfileDetailsController()
    }
    
    // MARK: - Utility methods
    
    private func getShows() {
        MBProgressHUD.showAdded(to: view, animated: true)
                
        APIManager.instance.performAPICall(
            router: .getShows(pageNumber: currentPage, itemsPerPage: itemsPerPage),
            responseType: ShowsDecodable.self
        ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
                    
            switch serverResponse {
            case .success(let showsResponse):
                numberOfShows = showsResponse.meta.pagination.count
                shows.append(contentsOf: showsResponse.shows)
                tableView.reloadData()
            case .failure(let error):
                print("API call failed with error: \(error)")
            }
        }
    }
    
    func pushShowDetailsViewController(forShowAtIndex index: Int) {
        let showDetailsStoryboard = UIStoryboard(name: "ShowDetails", bundle: nil)
        let showDetailsViewController = showDetailsStoryboard.instantiateViewController(withIdentifier: String(describing: ShowDetailsViewController.self)) as! ShowDetailsViewController
        showDetailsViewController.show = shows[index]
        navigationController?.pushViewController(showDetailsViewController, animated: true)
    }
    
    private func setUpTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        configureRefreshControl()
    }
    
    func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
        currentPage = 1
        shows.removeAll()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        getShows()
    }
    
    private func setUpNavigationBar() {
            let profileDetailsIcon = UIBarButtonItem(
            image: UIImage(named: "ic-profile"),
            style: .plain,
            target: self,
            action: #selector(profileDetailsActionHandler)
            )
            profileDetailsIcon.tintColor = UIColor(
                red: 82/255,
                green: 54/255,
                blue: 140/255,
                alpha: 1
            )
            navigationItem.rightBarButtonItem = profileDetailsIcon
        }
    
    private func presentProfileDetailsController() {
        let profileDetailsStoryboard = UIStoryboard(name: "ProfileDetails", bundle: nil)
        let profileDetailsViewController = profileDetailsStoryboard.instantiateViewController(withIdentifier: String(describing: ProfileDetailsViewController.self)) as! ProfileDetailsViewController
            
        let navigationController = UINavigationController(rootViewController: profileDetailsViewController)
        navigationController.navigationBar.backgroundColor = UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )

        present(navigationController, animated: true)
    }
        
    @objc private func didReceiveLogoutNotification(_ notification: Notification) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: LoginViewController.self)
        ) as! LoginViewController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("DidLogoutNotification"),
            object: nil
        )
    }
    
}

// MARK: - Table View data source

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShowsTableViewCell.self), for: indexPath) as! ShowsTableViewCell
        
        let show = shows[indexPath.row]
        cell.configure(with: show)
        return cell
    }
    
}

// MARK: - Table View delegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushShowDetailsViewController(forShowAtIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == shows.count - 1 && indexPath.row != numberOfShows - 1 else { return }
        currentPage += 1
        getShows()
    }

}
