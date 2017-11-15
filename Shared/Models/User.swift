//
//  User.swift
//  GitHub User Profile
//
//  Created by Eduardo Irías on 8/16/15.
//  Copyright (c) 2015 Estamp. All rights reserved.
//

import Foundation

enum Type : String {
    case organization
    case user
}

class User: NSObject, NSCoding {
    
    static var current : User? {
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: "CurrentUser")
                return
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: "CurrentUser")
        }
        get {
            
            guard let data = UserDefaults.standard.data(forKey: "CurrentUser") else { return nil }
            
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? User
        }
    }
    
    var id: Int!
    var username : String!
    var email : String?
    var name : String?
    var company : String?
    var location : String?
    var url : String?
    var avatarURL : URL?
    
    var type : Type?
    
    var repos = [Repo]()
    
    var imageData : Data?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try? container.decode(String.self, forKey: .email)
        name = try? container.decode(String.self, forKey: .name)
        company = try? container.decode(String.self, forKey: .company)
        location = try? container.decode(String.self, forKey: .location)
        url = try? container.decode(String.self, forKey: .url)
        avatarURL = try? container.decode(URL.self, forKey: .avatarURL)
        if let type = try? container.decode(String.self, forKey: .type) {
            self.type = Type(rawValue: type.lowercased())
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        id = aDecoder.decodeObject(forKey: CodingKeys.id.rawValue) as! Int
        username = aDecoder.decodeObject(forKey: CodingKeys.username.rawValue) as? String
        email = aDecoder.decodeObject(forKey: CodingKeys.email.rawValue) as? String
        name = aDecoder.decodeObject(forKey: CodingKeys.name.rawValue) as? String
        company = aDecoder.decodeObject(forKey: CodingKeys.company.rawValue) as? String
        location = aDecoder.decodeObject(forKey: CodingKeys.location.rawValue) as? String
        url = aDecoder.decodeObject(forKey: CodingKeys.url.rawValue) as? String
        
        if let avatarUrlString = aDecoder.decodeObject(forKey: CodingKeys.avatarURL.rawValue) as? String {
            avatarURL = URL(string: avatarUrlString)
        }
        
        if let data = aDecoder.decodeObject(forKey: "avatar") as? Data {
            imageData = data
        }
        
        if let type = aDecoder.decodeObject(forKey: CodingKeys.type.rawValue) as? String {
            self.type = Type(rawValue: type.lowercased())
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: CodingKeys.id.rawValue )
        aCoder.encode(username, forKey: CodingKeys.username.rawValue)
        aCoder.encode(email, forKey: CodingKeys.email.rawValue)
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(company, forKey: CodingKeys.company.rawValue)
        aCoder.encode(location, forKey: CodingKeys.location.rawValue)
        aCoder.encode(url, forKey: CodingKeys.url.rawValue)
        aCoder.encode(avatarURL?.absoluteString, forKey: CodingKeys.avatarURL.rawValue)
        aCoder.encode(imageData, forKey: "avatar")
        aCoder.encode(type?.rawValue, forKey: CodingKeys.type.rawValue)
    }
    
    func fetch() {
        DataManager.shared.getCurrentUser { (user, error) in
        }
    }
    
    func fetchImageIfNeeded(_ block : @escaping (_ data : Data?, _ error : Error?) -> Void) {
        if imageData != nil {
            block( imageData , nil )
            return
        } else {
            if let avatarURL = self.avatarURL {
                let request = URLRequest(url: avatarURL)
                HTTPManager.make(request: request, completeBlock: { (data, error) in
                    self.imageData = data
                    DispatchQueue.main.async(execute: { () -> Void in
                        block( data, nil )
                    })
                    
                })
            }
        }
    }
   
}

extension User: Codable {
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case username = "login"
        case email = "email"
        case name = "name"
        case company = "company"
        case location = "location"
        case url = "blog"
        case avatarURL = "avatar_url"
        case type = "type"
    }
    
    func decode(decoder: Decoder) throws {
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(company, forKey: .company)
        try container.encode(location, forKey: .location)
        try container.encode(url, forKey: .url)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(type, forKey: .type)
    }
}

struct LoginRequest : Encodable {
    
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case scopes
        case note
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(DataManager.shared.clientSecretId, forKey: .clientSecret)
        try container.encode(["repo", "user"], forKey: .scopes)
        try container.encode(["note"], forKey: .note)
    }
    
}


struct LoginResponse : Codable {
    
    var id : Int?
    var token : String?

}
