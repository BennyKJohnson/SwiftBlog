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

    let mongo: MongoClient
    
    static let databaseName = "swiftblog"
    static let mongoURI = "mongodb://localhost"

    var database: MongoDatabase {
        return mongo.getDatabase(DatabaseManager.databaseName)
    }
    
    func objects(type: DBManagedObject.Type) -> MongoCollection {
        return database.getCollection(type)
    }
    
    init() throws {
        
        mongo = MongoClient(uri: DatabaseManager.mongoURI)
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

    }
    
   }

class Object {
    var _objectID: String? = nil
}



