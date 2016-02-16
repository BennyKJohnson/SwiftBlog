//
//  MongoExtensions.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
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

extension MustacheTemplate {
    class func FromURL(filepath: String) -> MustacheTemplate? {
    do {
        let file = File(filepath)
        try file.openRead()
        defer { file.close() }
        let bytes = try file.readSomeBytes(file.size())
        
        let parser = MustacheParser()
        let str = UTF8Encoding.encode(bytes)
        let template = try parser.parse(str)
        return template
        
    } catch {
        return nil
    } 
    }
}

extension MongoDatabase {
    func getCollection(type: DBManagedObject.Type) -> MongoCollection {
        
        return self.getCollection(type.collectionName)
    }
}

extension DBManagedObject {
    
    var identifierDictionary: Dictionary<JSONKey, JSONValue>? {
        
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
            
            if let key = child.label,value = child.value as? Any where key.characters[key.startIndex] != "_" {
                properties[key] = value
            }
        }
        
        return properties
        
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
    
    public func find() -> MongoCursor? {
        return find(BSON())
    }
    
}

