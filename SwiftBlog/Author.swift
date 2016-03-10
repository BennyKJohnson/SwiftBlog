//
//  Author.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 24/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

final class Author: Object {
    
    var email: String
    
    var name: String
    
    var twitterHandle: String = ""
    
    var username: String
    
    var bio: String = ""
    
    var pictureURL: String = ""
    
    var authKey: String
    
    var articleIDs: [String] = []
    
    lazy var articles: [Article] = {
    
    var queriedArticles: [Article] = []
    // Query articles via id
    for articleID in self.articleIDs {
        if let article = Article(identifier: articleID) {
                queriedArticles.append(article)
        }
    }
  
        return queriedArticles
    }()
    
    init(email: String, name: String, username: String, authKey: String) {
        
        self.email = email
        
        self.name = name
        
        self.username = username.lowercaseString
        
        self.authKey = authKey
        
    }
    
  
    
}
