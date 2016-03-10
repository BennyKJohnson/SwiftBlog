//
//  AuthorController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib
import MongoDB

class AuthorController: RESTController {
    
    let modelName = "author"
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        var values = MustacheEvaluationContext.MapType()
        
        // Get Articles
        let db = try! DatabaseManager().database
        let postsBSON = db.getCollection(Author).find()
        var posts: [[String: Any]] = []
        
        while let postBSON = postsBSON?.next() {
            let post = Author(bson: postBSON)
            posts.append(post.keyValues())
        }
        
        postsBSON?.close()
        values["author"] = posts
        
        return values
        
    }
    
    func getUserWithIdentifier(identifier: Int) -> Author? {
        let db = try! DatabaseManager().database
        
        let postsBSON = db.getCollection(Author).find(BSON(), fields: nil, flags: MongoQueryFlag(rawValue: 0), skip: identifier, limit: 1, batchSize: 0)
        guard let postBSON = postsBSON?.next() else {
            // response.setStatus(404, message: "Article not found")
            // response.requestCompletedCallback()
            return nil
        }
        
        let post = Author(bson: postBSON)
        return post
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Query Article
        let author: Author?
        
        if let id = Int(identifier)  {
            author = getUserWithIdentifier(id)
        } else {
            author = Author(username: identifier)
        }
        
        // Query Article
        // Get Articles
        guard let requestedAuthor = author else {
            return MustacheEvaluationContext.MapType()
        }
        
        
        let values: [String:Any] = ["author": requestedAuthor.keyValues()]
        
        return values
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
        /*
        // Handle new post request
        if let title = request.param("title"), body = request.param("body"), existingArticle = getUserWithIdentifier(identifier) {
            
            // Update post properties
            existingArticle.title = title
            existingArticle.body = body
            
            // Save Article
            do {
                DatabaseManager().database.getCollection(Article).save(try existingArticle.document())
                response.redirectTo("/\(modelName)s/\(identifier)")
            } catch {
                print(error)
            }
        }
        */
        response.requestCompletedCallback()
    }
    
    func getModelWithIdentifier(identifier: String) -> Author? {

        if let id = Int(identifier)  {
            return getUserWithIdentifier(id)
        } else {
           return Author(username: identifier)
        }
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        guard let post = getModelWithIdentifier(identifier) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values: [String:Any] = ["author": post.keyValues()]
        
        return values
    }
    
    
    func new(request: WebRequest, response: WebResponse) {
        
        if let error = request.param("error") {
            print(error)
        }
        
        // Handle new post request
        if let email = request.param("email"),
            name = request.param("name"),
            username = request.param("username"),
            password = request.param("password"),
            password2 = request.param("password2")
        {
            
            // Valid Article
            guard password == password2 else {
                response.setStatus(500, message: "The passwords did not match.")
                return
            }
            var pictureURL: String = ""
            // Get Profile Picture
            if let uploadedFile = request.fileUploads.first {
                
                let fileName = uploadedFile.fileName
                print("Profile Pic uploaded: \(fileName)")
                
                // Save profile picture to disk
                if let file = uploadedFile.file {
                    // Copy file 
                    do {
                        let saveLocation = request.documentRoot + "/resources/pictures/" + uploadedFile.fileName
                        pictureURL = uploadedFile.fileName
                        print(saveLocation)
                        
                        try file.copyTo(saveLocation, overWrite: true)
                    } catch {
                        print(error)
                    }
                }
                
            }
            
            do {
                guard let author = try Author.create(name, email: email, password: password, username: username, pictureURL: pictureURL) else {
                    response.setStatus(500, message: "The user was not able to be created.")
                    return
                }
                
                // Create Session
                let session = response.getSession("user")
                session["user_id"] = author._objectID
                
            } catch {
                print(error)
                response.redirectTo(request.requestURI() + "?error=bad")
                response.requestCompletedCallback()
                return
            }
          
            
            response.redirectTo("/")
        }
        
        response.requestCompletedCallback()
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
        
        if let postBSON = try! DatabaseManager().database.getCollection(Article).find(identifier) {
            
            do {
                
                let post = Article(bson: postBSON)
                let query: [String: JSONValue] = ["_id": post.identifierDictionary!]
                let jsonEncode = try JSONEncoder().encode(query)
                
                try! DatabaseManager().database.getCollection(Article).remove(try! BSON(json: jsonEncode))
                
            } catch {
                print(error)
            }
            
            
        }
        response.requestCompletedCallback()
    }
    
    
}