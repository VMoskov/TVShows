//
//  ShowsTableViewCell.swift
//  TVShows
//
//  Created by Vedran Moškov on 20.07.2023..
//

import UIKit
import Kingfisher

final class ShowsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var coverImage: UIImageView!
    
    // MARK: - Utility methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverImage.kf.cancelDownloadTask()
    }
    
    func configure(with show: Show) {
        titleLabel.text = show.title
        coverImage.kf.setImage(
            with: URL(string: show.imageUrl),
            placeholder: UIImage(named: "ic-show-placeholder-vertical")
        )
    }
}
