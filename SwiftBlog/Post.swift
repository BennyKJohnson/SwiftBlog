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

