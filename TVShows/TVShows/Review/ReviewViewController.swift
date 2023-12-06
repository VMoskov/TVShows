//
//  ReviewViewController.swift
//  TVShows
//
//  Created by Vedran Moškov on 26.07.2023..
//

import UIKit
import MBProgressHUD

protocol ReviewDelegate: AnyObject {
    func didSubmitReview()
}

final class ReviewViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var commentText: UITextView!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var ratingView: RatingView!
    
    // MARK: - Properties
    
    var show: Show?
    weak var delegate: ReviewDelegate?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Actions
    
    @IBAction private func submitButtonActionHandler() {
        guard
            let comment = commentText.text,
            !comment.isEmpty
        else {
            showAlert("Submission", error: APIError(errors: ["Comment can not be empty!"]))
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        guard let show else { return }
        
        APIManager.instance.performAPICall(
            router: .review(
                comment: comment,
                rating: ratingView.rating,
                showId: show.id
                ),
            responseType: SubmittedReview.self
        ) { [weak self] serverResponse in
            guard let self else { return }
            MBProgressHUD.hide(for: view, animated: true)
            
            switch serverResponse {
            case .success(_):
                dismissScreen()
                delegate?.didSubmitReview()
            case .failure(let apiError):
                showAlert("Submission", error: apiError as? APIError ?? APIError(errors: [""]))
            }
            
        }
    }
    
    // MARK: - Utility methods
    
    private func setUpUI() {
        setUpCommentTextView(selected: false)
        setUpSubmitButton(enabled: false)
        setUpNavigationBar()
        setUpRatingView()
        commentText.delegate = self
        ratingView.delegate = self
    }
    
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
    
    private func setUpCommentTextView(selected: Bool) {
        commentText.text = selected ? nil : "Enter your comment here..."
        commentText.textColor = selected ? .black : .lightGray
    }
    
    private func setUpSubmitButton(enabled: Bool) {
        submitButton.isEnabled = enabled
        submitButton.setTitleColor(.white, for: .disabled)
        submitButton.alpha = enabled ? 1 : 0.25
    }
    
    private func setUpRatingView() {
        ratingView.isEnabled = true
        ratingView.configure(withStyle: .large)
    }
    
    @objc private func ratingViewTapped() {
        setUpSubmitButton(enabled: ratingView.rating != 0)
    }
    
}

extension ReviewViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .lightGray else { return }
        setUpCommentTextView(selected: true)
        setUpSubmitButton(enabled: ratingView.rating != 0)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.isEmpty else { return }
        setUpCommentTextView(selected: false)
        setUpSubmitButton(enabled: ratingView.rating != 0)
    }
    
}

extension ReviewViewController: RatingViewDelegate {
    
    func didChangeRating(_ rating: Int) {
        ratingView.rating = rating
        setUpSubmitButton(enabled: true)
    }
    
}
