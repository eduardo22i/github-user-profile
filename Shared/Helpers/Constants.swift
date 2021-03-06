//
//  Constants.swift
//  GitHub
//
//  Created by Eduardo Irias on 11/2/17.
//  Copyright © 2017 Estamp. All rights reserved.
//

import Foundation

enum Config {
    static let clientId = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String ?? ""
    static let clientSecretId = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_SECRET_ID") as? String ?? ""
}

enum APIError: Error {
    case unauthorized
    case otpRequired
    case notFound
    case limitExceeded
    case serverError
    case noNetwork
    
    var description: String {
        switch self {
        case .unauthorized:
            return ""
        case .otpRequired:
            return "OTP Required."
        case .notFound:
            return "Not found."
        case .limitExceeded:
            return "API rate limit exceeded. (But here's the good news: Authenticated requests get a higher rate limit.)"
        case .serverError:
            return "Looks like something went wrong!"
        case .noNetwork:
            return "Looks like we are unable to communicate with the servers"
        }
    }
    
    var code : Int {
        switch self {
        case .unauthorized, .otpRequired:
            return 401
        case .notFound:
            return 404
        case .limitExceeded:
            return 403
        case .serverError:
            return 505
        case .noNetwork:
            return 0
        }
    }
}

enum HTTPMethod : String {
    case get
    case post
    case put
    case delete
}


enum Endpoint : String {
    case authorization = "authorizations"
    case client = "clients"
    case user = "user"
    case users = "users"
    case organizations = "orgs"
    case repos = "repos"
    case branches = "branches"
    case commits = "commits"
    case readme = "readme"
    case events = "received_events"
}
