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
        
        let authKey = dictionary["authKey"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(email: email, name: name, authKey: authKey)
        
        self._objectID = id
    }
    
    convenience init?(email: String) {
        let database = DatabaseManager().database
        
        // Find Author with email
        
        let results = database.getCollection(Author).find(["email": email])
        
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
    
    static func create(name: String, email: String, password: String) -> Author? {
        
        do {
            DatabaseManager().database
            let authKey = encodeRawPassword(email, password: password)
            let author = Author(email: email, name: name, authKey: authKey)
            
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
