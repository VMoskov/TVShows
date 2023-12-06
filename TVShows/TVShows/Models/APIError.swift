//
//  APIError.swift
//  TVShows
//
//  Created by Vedran MoÅ¡kov on 03.08.2023..
//

import Foundation

struct APIError: Decodable, Error {
    let errors: [String]
}
