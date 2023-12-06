//
//  ShowsModel.swift
//  TVShows
//
//  Created by Vedran Moškov on 22.07.2023..
//

import Foundation

struct ShowsDecodable: Decodable {
    let shows: [Show]
    let meta: Meta
}


struct Show: Decodable {
    let id: String
    let averageRating: Int?
    let description: String
    let imageUrl: String
    let numberOfReviews: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case averageRating = "average_rating"
        case description
        case imageUrl = "image_url"
        case numberOfReviews = "no_of_reviews"
        case title
    }
}
