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
    
    var bio: String = ""
    
    var pictureURL: String = ""
    
    var authKey: String
    
   // var posts: [Post] = []
    
    init(email: String, name: String, authKey: String) {
        
        self.email = email
        
        self.name = name
        
        self.authKey = authKey
        
    }
}
