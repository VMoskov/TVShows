//
//  ReviewModel.swift
//  TVShows
//
//  Created by Vedran Moškov on 25.07.2023..
//

import Foundation

struct ReviewDecodable: Decodable {
    let reviews: [Review]
    let meta: Meta
}

struct Review: Decodable {
    let id: String
    let comment: String
    let rating: Int
    let showId: Int
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id, comment, rating
        case showId = "show_id"
        case user
    }
}

struct SubmittedReview: Decodable {
    let review: Review
}
