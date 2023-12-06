//
//  MetaModel.swift
//  TVShows
//
//  Created by Vedran Moškov on 25.07.2023..
//

import Foundation

struct Meta: Decodable {
    let pagination: Pagination
    
    struct Pagination: Decodable {
        let count: Int
        let page: Int
        let items: Int
        let pages: Int
    }
}
