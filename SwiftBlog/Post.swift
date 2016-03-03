//
//  Post.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import MongoDB
import PerfectLib

final class Post: Object {
    
    var title: String
    
    var body: String
    
    var author: Author!
    
    var tags: [String] = []
    
    init(title: String, body: String, author: Author?) {
        
        self.title = title
        
        self.body = body
        
        self.author = author
        
    }
    
    var urlTitle: String {
        
        var urlTitle = title.lowercaseString
        urlTitle = urlTitle.stringByReplacingString(" ", withString: "-")
        urlTitle = urlTitle.stringByReplacingString("'", withString: "-")

        return urlTitle
    }
}

extension Post: DBManagedObject {
    
    static var collectionName = "post"
    
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
        
        var documentData = ["title": title, "body": body] as [String: Any]
        
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
        return ["title": title, "body": body, "author": ["name": author.name, "pictureURL": "/../resources/pictures/\(author.pictureURL)"] as [String: Any]]
        //return ["title": title, "body": body, "author": ["name": author.name, "pictureURL": "/resources/pictures/\(author.pictureURL)"]]
    }
    
}