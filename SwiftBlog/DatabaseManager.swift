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
    
   }

class Object {
    var _objectID: String? = nil
}



