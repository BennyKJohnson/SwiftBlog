//
//  Post-Server.swift
//  SwiftBlog
//
//  Created by Ben Johnson on 3/03/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

extension Post: DBManagedObject {
    
    static var collectionName = "post"
    
    convenience init?(urlTitle: String) {
        
        let database = DatabaseManager().database
        
        // Find Author with email
        
        let results = database.getCollection(Post).find(["urlTitle": urlTitle])
        
        defer {
            results?.close()
        }
        
        guard let postBSON = results?.next() else {
            return nil
        }
        
        self.init(bson: postBSON)
    }
    
    convenience init(bson: BSON) {
        
        let jsonString = bson.asString
        
        let jsonDictionary = try! (JSONDecoder().decode(jsonString) as! JSONDictionaryType)
        
        let dictionary = jsonDictionary.dictionary
        
        let title = dictionary["title"] as! String
        
        let body = dictionary["body"] as! String
        
        let tags = dictionary["tags"] as? [String] ?? []
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        // Get Author
        let authorID = (dictionary["author_id"] as? JSONDictionaryType)?["$oid"] as? String
        let author = Author(userID: authorID!)
        
        self.init(title: title, body: body, author: author)
        
        self.tags = tags
        
        self._objectID = id
    }
    
    func document() throws -> BSON {
        
        var documentData = ["title": title, "body": body, "urlTitle": urlTitle] as [String: Any]
        
        if let authorID = author.identifierDictionary {
            documentData["author_id"] = authorID
        }
        
        if let object = self as? Object, objectID = object._objectID {
            
            let identifierDict = ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
            documentData["_id"] = identifierDict
            
        }
        
        let json = try JSONEncoder().encode(documentData)
        let bson = try BSON(json: json)
        
        return bson
    }
    
    func keyValues() -> [String: Any] {
        return ["title": title, "body": body,"urlTitle": urlTitle, "author": ["name": author.name, "pictureURL": "/../resources/pictures/\(author.pictureURL)"] as [String: Any]]
        //return ["title": title, "body": body, "author": ["name": author.name, "pictureURL": "/resources/pictures/\(author.pictureURL)"]]
    }
    
}