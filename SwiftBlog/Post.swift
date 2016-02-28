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
    
    var author: String
    
    var tags: [String] = []
    
    init(title: String, body: String, author: String) {
        
        self.title = title
        
        self.body = body
        
        self.author = author
        
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
        
        let author = dictionary["author"] as! String
        
        let tags = dictionary["tags"] as? [String] ?? []
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(title: title, body: body, author: author)
        
        self.tags = tags
        
        self._objectID = id
    }
    
}