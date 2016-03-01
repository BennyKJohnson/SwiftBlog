//
//  DBManagedObject.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 16/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import MongoDB
import PerfectLib

protocol DBManagedObject {
    
    static var collectionName: String { get }
    
    func keyValues() -> [String: Any]
    
    func document() throws -> BSON
    
    init(bson: BSON)
    
}

typealias ObjectID = Dictionary<JSONKey, JSONValue>?

extension DBManagedObject {
    
    var identifierDictionary: ObjectID? {
        
        if let object = self as? Object, objectID = object._objectID {
            return ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
        } else {
            return nil
        }
    }
    
    
    func document() throws -> BSON {
        
        var documentData = self.keyValues()
    
        if let object = self as? Object, objectID = object._objectID {
            
            let identifierDict = ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
            documentData["_id"] = identifierDict
        }
        
        let json = try JSONEncoder().encode(documentData)
        let bson = try BSON(json: json)
        
        return bson
    }
    
    func keyValues() -> [String: Any] {
        
        var properties: [String: Any] = [:]
        
        for child in Mirror(reflecting: self).children {
            
            if let key = child.label where key.characters[key.startIndex] != "_" {
                properties[key] = child.value as Any
            }
        }
        
        return properties
        
    }
    
}