//
//  DatabaseManager.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

class DatabaseManager {

    let mongo =  MongoClient(uri: "mongodb://localhost")
    
    static let datebaseName: String = "mydb"

    var database: MongoDatabase {
        return mongo.getDatabase(DatabaseManager.datebaseName)
    }
    
    
    func prepareDatabase() {
        
        // Create our SQLite tracking database.
        
      //  let mongo = MongoClient(uri: "mongodb://localhost")
        
        // Check status
        let status = mongo.serverStatus()
        
        switch status {
            
        case .Error(let domain, let code, let message):
            assert(false, "Error connecting to mongo: \(domain) \(code) \(message)")
            
        case .ReplyDoc(let doc):
            print("Status doc: \(doc)")
            assert(true)
            
        default:
            assert(false, "Strange reply type \(status)")
        }
        
       // populateBlogPosts()
    }
    
    func populateBlogPosts() {
        
        let db = mongo.getDatabase(DatabaseManager.datebaseName)
        let posts = db.getCollection(Post.collectionName)
        
        let post1 = Post(title: "Hello World", body: "Welcome to my new blog",author: "Benjamin Johnson")
        let post2 = Post(title: "Blog Post 2", body: "Had a great day today", author: "Benjamin Johnson")
        
        posts.insert(try! post1.document())
        posts.insert(try! post2.document())
        
    }
}

class Object {
    var _objectID: String? = nil
}



