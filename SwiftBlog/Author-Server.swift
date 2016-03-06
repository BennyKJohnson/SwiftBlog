//
//  Author-Server.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 24/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

extension Author: DBManagedObject {
    
    static var collectionName = "author"
    
    convenience init(bson: BSON) {
        
        let jsonString = bson.asString
        
        let jsonDictionary = try! (JSONDecoder().decode(jsonString) as! JSONDictionaryType)
        
        let dictionary = jsonDictionary.dictionary
        
        let email = dictionary["email"] as! String
        
        let name = dictionary["name"] as! String
        
        let username = dictionary["username"] as! String
        
        let authKey = dictionary["authKey"] as! String
        
        let pictureURL = dictionary["pictureURL"] as? String ?? ""
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(email: email, name: name,username: username, authKey: authKey)
        
        self.pictureURL = pictureURL
        
        self._objectID = id
    }
    
    convenience init?(email: String) {
        let database = DatabaseManager().database
        
        // Find Author with email
        
        let results = database.getCollection(Author).find(["username": email])
        
        defer {
            results?.close()
        }
        
        guard let authorBSON = results?.next() else {
            return nil
        }
        
       self.init(bson: authorBSON)
    }
    
    convenience init?(username: String) {
        let database = DatabaseManager().database
        
        // Find Author with email
        print(username)
        let results = database.getCollection(Author).find(["username": username])
        
        defer {
            results?.close()
        }
        
        guard let authorBSON = results?.next() else {
            return nil
        }
        
        self.init(bson: authorBSON)
    }
    
    convenience init?(userID: String) {
        let database = DatabaseManager().database
        
        // Find Author with email
        guard let authorBSON = database.getCollection(Author).get(userID) else {
            return nil
        }
        
        self.init(bson: authorBSON)
        
    }
    
}

extension Author {
    
    static func create(name: String, email: String, password: String, username: String, pictureURL: String = "") -> Author? {
        
        do {
            let authKey = encodeRawPassword(email, password: password)
            let author = Author(email: email, name: name, username: username, authKey: authKey)
            author.pictureURL = pictureURL
            
            try DatabaseManager().database.insert(author)
            
            return author
            
        } catch {
            print(error)
            return nil
        }
    }
    
    static func encodeRawPassword(email: String, password: String, realm: String = AUTH_REALM) -> String {
        let bytes = "\(email):\(realm):\(password)".md5
        return toHex(bytes)
    }
    
}
