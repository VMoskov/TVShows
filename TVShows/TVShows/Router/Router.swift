//
//  Router.swift
//  TVShows
//
//  Created by Vedran MoÅ¡kov on 18.07.2023..
//

import Alamofire
import MBProgressHUD

final class APIManager {
    
    // MARK: - Properties
    
    static let instance = APIManager()
    var authInfo: AuthInfo?

    // MARK: - Constructor
    
    private init() {}
        
    // MARK: - API call method
    
    // MARK: - API call method
    
    func performAPICall<T: Decodable>(
            router: APIRouter,
            responseType: T.Type,
            completion: @escaping (Result<T, Error>) -> Void
        ) {
            AF
                .request(router)
                .validate()
                .responseDecodable(of: T.self) { serverResponse in
                    switch serverResponse.result {
                    case .success(let response):
                        if T.self == UserDecodable.self {
                            self.storeAuthInfo(headers: serverResponse.response?.headers.dictionary ?? [:])
                        }
                            completion(.success(response))
                    case .failure(let error):
                        if let data = serverResponse.data {
                            do {
                                let apiError = try JSONDecoder().decode(APIError.self, from: data)
                                completion(.failure(apiError))
                            } catch {
                                completion(.failure(error))
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
        }
    
    func uploadImage(_ imageData: Data, completion: @escaping (Result<UserDecodable, Error>) -> Void) {
        guard let authInfo else { return }
        
        let requestData = MultipartFormData()
        requestData.append(
                imageData,
                withName: "image",
                fileName: "image.jpg",
                mimeType: "image/jpg"
        )
    
        AF
            .upload(
                multipartFormData: requestData,
                to: "https://tv-shows.infinum.academy/users",
                method: .put,
                headers: HTTPHeaders(authInfo.headers)
            )
            .validate()
            .responseDecodable(of: UserDecodable.self) { dataResponse in
                switch dataResponse.result {
                case .success(let userResponse):
                    completion(.success(userResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    private func storeAuthInfo(headers: [String: String]) {
        guard let checkAuthInfo = try? AuthInfo(headers: headers) else { return }
        authInfo = checkAuthInfo
    }
    
}

enum APIRouter {
    
    case login(user: UserCredentials)
    case registration(user: UserCredentials)
    case getShows(pageNumber: Int, itemsPerPage: Int)
    case getReviews(showId: String, pageNumber: Int, itemsPerPage: Int)
    case review(comment: String, rating: Int, showId: String)
    case getUserInfo
    
    var path: String {
        switch self {
        case .login:
            return "/users/sign_in"
        case .registration:
            return "/users"
        case .getShows:
            return "/shows"
        case .getReviews(let showId, _, _):
            return "/shows/\(showId)/reviews"
        case .review:
            return "/reviews"
        case .getUserInfo:
            return "/users/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .registration, .review:
            return .post
        default:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let user):
            return [
                "email": user.email,
                "password": user.password
            ]
        case .registration(let user):
            return [
                "email": user.email,
                "password": user.password,
                "password_confirmation": user.password
            ]
        case .getShows(let pageNumber, let itemsPerPage):
            return [
                "page": pageNumber,
                "items": itemsPerPage
            ]
        case .getReviews(_, let pageNumber, let itemsPerPage):
            return [
                "page": pageNumber,
                "items": itemsPerPage
            ]
        case .review(let comment, let rating, let showId):
            return [
                "comment": comment,
                "rating": rating,
                "show_id": showId
            ]
        case .getUserInfo:
            return [:]
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login, .registration:
            return [:]
        default:
            return HTTPHeaders(APIManager.instance.authInfo?.headers ?? [:])
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login, .registration:
            return [:]
        default:
            return HTTPHeaders(APIManager.instance.authInfo?.headers ?? [:])
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .login, .registration:
            return [:]
        default:
            return HTTPHeaders(APIManager.instance.authInfo?.headers ?? [:])
        }
    }
    
}

extension APIRouter: URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = "https://tv-shows.infinum.academy"
        guard let url = URL(string: baseURL)?
            .appendingPathComponent(path)
            .absoluteURL
        else { fatalError("Invalid URL!") }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers?.dictionary
        
        switch method {
        case .post, .put:
            request = try JSONEncoding.default.encode(request, with: parameters)
        default:
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
    
}
