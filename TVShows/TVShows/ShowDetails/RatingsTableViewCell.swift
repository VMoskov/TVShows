//
//  RatingsTableViewCell.swift
//  TVShows
//
//  Created by Vedran Moškov on 25.07.2023..
//

import UIKit
import Kingfisher

final class RatingsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var comment: UILabel!
    @IBOutlet private weak var email: UILabel!
    @IBOutlet private weak var profilePicture: UIImageView!
    @IBOutlet private weak var ratingView: RatingView!
    
    // MARK: - Utility methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.configure(withStyle: .small)
        ratingView.isEnabled = false
    }
    
    func configure(with review: Review) {
        ratingView.setRoundedRating(Double(review.rating))
        comment.text = review.comment
        email.text = review.user.email
        profilePicture.kf.setImage(
            with: URL(string: review.user.imageUrl ?? ""),
            placeholder: UIImage(named: "ic-profile-placeholder")
        )
    }
}
