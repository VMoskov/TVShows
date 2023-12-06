//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Vedran Moškov on 23.07.2023..
//

import UIKit
import MBProgressHUD
import Kingfisher

final class ShowDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var reviewButton: UIButton!
    
    // MARK: - Properties
    
    var show: Show?
    private var reviews = [Review]()
    private var currentPage = 1
    private var itemsPerPage = 5
    private var numberOfReviews = 0

    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviews()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = show?.title
    }
    
    // MARK: - Actions
    
    @IBAction private func reviewButtonHandler() {
        let reviewStoryboard = UIStoryboard(name: "Review", bundle: nil)
        let reviewViewController = reviewStoryboard.instantiateViewController(withIdentifier: String(describing: ReviewViewController.self)) as! ReviewViewController
        guard let show else { return }
        reviewViewController.delegate = self
        reviewViewController.show = show
        let navigationController = UINavigationController(rootViewController: reviewViewController)
        navigationController.navigationBar.backgroundColor = UIColor(
            red: 245/255,
            green: 245/255,
            blue: 245/255,
            alpha: 1
        )

        present(navigationController, animated: true)
    }
    
    // MARK: - Utility methods
    
    private func getReviews() {
        MBProgressHUD.showAdded(to: view, animated: true)
        guard let show else { return }
        
        APIManager.instance.performAPICall(
            router: .getReviews(
                showId: show.id,
                pageNumber: currentPage,
                itemsPerPage: itemsPerPage
                ),
            responseType: ReviewDecodable.self
            ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
                
            switch serverResponse {
            case .success(let reviewsResponse):
                numberOfReviews = reviewsResponse.meta.pagination.count
                reviews.append(contentsOf: reviewsResponse.reviews)
                tableView.reloadData()
            case .failure(let error):
                print("API call failed with error: \(error)")
            }
        }
    }
    
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        configureRefreshControl()
    }
    
}

extension ShowDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShowDetailsTableViewCell.self), for: indexPath) as! ShowDetailsTableViewCell
            
            guard let show else { return cell }
            cell.configure(with: show, numberOfReviews: numberOfReviews)

            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RatingsTableViewCell.self), for: indexPath) as! RatingsTableViewCell

            let review = reviews[indexPath.row - 1]
            cell.configure(with: review)
            
            return cell
        }
    }
    
    func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
        currentPage = 1
        reviews.removeAll()
        getReviews()
        tableView.refreshControl?.endRefreshing()
    }
    
}

extension ShowDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == reviews.count - 1 && indexPath.row != numberOfReviews - 1 else { return }
        currentPage += 1
        getReviews()
    }
    
}

extension ShowDetailsViewController: ReviewDelegate {
    
    func didSubmitReview() {
        reviews.removeAll()
        currentPage = 1
        getReviews()
    }
    
}
