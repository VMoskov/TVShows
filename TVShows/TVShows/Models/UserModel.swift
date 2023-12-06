//  UserModel.swift
//  TVShows
//
//  Created by Vedran MoÅ¡kov on 22.07.2023..
//

import Foundation

// MARK: - Structure used for decoding of http requests

struct UserDecodable: Decodable {
    let user: User
}

struct User: Decodable {
    let id: String
    let email: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, imageUrl = "image_url"
    }
    
}

// MARK: - Structure used for parsing Authorization Info headers

struct AuthInfo: Codable {
    let accessToken: String
    let tokenType: String
    let expiry: String
    let uid: String
    let client: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access-token"
        case tokenType = "token-type"
        case expiry, uid, client
    }
    
    init(headers: [String: String]) throws {
        let data = try JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
    
    var headers: [String: String] {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            return jsonObject as? [String: String] ?? [:]
        } catch {
            return [:]
        }
    }
}

// MARK: - structure used for router parameters

struct UserCredentials {
    var email: String
    var password: String
}
