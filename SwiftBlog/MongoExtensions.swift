//
//  MongoExtensions.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import MongoDB
import libmongoc
import PerfectLib


extension MongoDatabase {
    
    func getCollection(type: DBManagedObject.Type) -> MongoCollection {
        return self.getCollection(type.collectionName)
    }
    
    func insert(object: DBManagedObject) throws {
        let objectCollection = self.getCollection(object.dynamicType)
        objectCollection.insert(try object.document())
    }
}

extension BSON {
    convenience init(dictionary: [String: Any]) throws {
        let json = try JSONEncoder().encode(dictionary)
        try self.init(json: json)
    }
    
    
}

extension MongoCollection {
    
    public func find(query: [String: Any]) -> MongoCursor? {
        
        let jsonQuery = try! JSONEncoder().encode(query)
        let BSONQuery = try! BSON(json: jsonQuery)
        
        return find(BSONQuery)
    }
    
    public func find(identifier: Int) -> BSON? {
        
        let cursor = find(BSON(), fields: nil, flags: MongoQueryFlag(rawValue: 0), skip: identifier, limit: 1, batchSize: 0)
        let bson = cursor?.next()
        cursor?.close()
        
        return bson
    }
    
    public func get(objectID: String) -> BSON? {
        let identifierDictionary = ["$oid": objectID] as Dictionary<JSONKey, JSONValue>
        
        let query: [String: JSONValue] = ["_id": identifierDictionary]
        let jsonEncode = try! JSONEncoder().encode(query)
        
        let cursor = find(try! BSON(json: jsonEncode))
        
        let bson = cursor?.next()
        cursor?.close()
        
        return bson
    }
    
    public func find() -> MongoCursor? {
        return find(BSON())
    }
    
}

extension MongoDatabase {
    
    func generateObjectID() -> String {
        
        var rawPointer = bson_oid_t()
        bson_oid_init(&rawPointer, nil)
        let objectIDStringRaw = UnsafeMutablePointer<Int8>.alloc(100)
        bson_oid_to_string(&rawPointer, objectIDStringRaw)
        
        let objectIDString = String.fromCString(objectIDStringRaw)
        objectIDStringRaw.destroy()
        
        return objectIDString!
        
    }
    
    
}
