//
//  ShowDetailsTableViewCell.swift
//  TVShows
//
//  Created by Vedran Moškov on 23.07.2023..
//

import UIKit

final class ShowDetailsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var showCoverImage: UIImageView!
    @IBOutlet private weak var showDescription: UILabel!
    @IBOutlet private weak var ratingsLabel: UILabel!
    @IBOutlet private weak var ratingView: RatingView!
    
    // MARK: - Utility methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.configure(withStyle: .small)
        ratingView.isEnabled = false
    }
    
    func configure(with show: Show, numberOfReviews: Int) {
        showCoverImage.kf.setImage(
            with: URL(string: show.imageUrl),
            placeholder: UIImage(named: "ic-show-placeholder-rectangle")
        )
        showDescription.text = show.description
        guard let averageRating = show.averageRating else {
            ratingsLabel.text = "No reviews yet"
            ratingsLabel.font = ratingsLabel.font.withSize(17)
            ratingsLabel.textAlignment = .center
            ratingView?.removeFromSuperview()
            return
        }
        ratingView.setRoundedRating(Double(averageRating))
        ratingsLabel.text = "\(numberOfReviews) REVIEWS, \(averageRating) AVERAGE"
    }
    
}
