//
//  PostController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib
import MongoDB

class PostController: RESTController {
    
    let modelName = "post"
    
    func getCurrentUser(request: WebRequest, response: WebResponse) -> Author? {
        
        // Obtain Session
        let currentSession = response.getSession("user")
        print(currentSession["user_id"])
        
        guard let currentUserID = currentSession["user_id"] as? String, let user = Author(userID: currentUserID) else {
            return  nil
        }

        return user
    }
    
    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType? {
        
        // Authenticate User
        guard let user = getCurrentUser(request, response: response) else {
            response.redirectTo("/login")
            return nil
        }
        
        return ["user":["name": user.name]]
        
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        var values = MustacheEvaluationContext.MapType()
        
        // Get Posts
        let db = DatabaseManager().database
        let postsBSON = db.getCollection(Post).find()
        var posts: [[String: Any]] = []
        
        while let postBSON = postsBSON?.next() {
            let post = Post(bson: postBSON)
            posts.append(post.keyValues())
        }
        
        postsBSON?.close()
        let reversedPosts = Array(posts.reverse())
        
        values["post"] = reversedPosts
        
        return values
 
    }
    
    func getPostWithIdentifier(identifier: Int) -> Post? {
        let db = DatabaseManager().database
        let postsBSON = db.getCollection(Post).find(BSON(), fields: nil, flags: MongoQueryFlag(rawValue: 0), skip: identifier, limit: 1, batchSize: 0)
        guard let postBSON = postsBSON?.next() else {
            // response.setStatus(404, message: "Post not found")
            // response.requestCompletedCallback()
            return nil
        }
        
        let post = Post(bson: postBSON)
        return post
    }

    func show(identifier: Int, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Query Post
        // Get Posts
        guard let post = getPostWithIdentifier(identifier) else {
            return MustacheEvaluationContext.MapType()
        }

        let values: [String:Any] = ["post": post.keyValues()]
        
        return values
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
      
        // Handle new post request
        if let title = request.param("title"), body = request.param("body"), existingPost = getPostWithIdentifier(identifier), currentAuthor = getCurrentUser(request, response: response) where currentAuthor.email == existingPost.author.email {
            
            // Update post properties
            existingPost.title = title
            existingPost.body = body
            
            // Save Post
            do {
                DatabaseManager().database.getCollection(Post).save(try existingPost.document())
                response.redirectTo("/\(modelName)s/\(identifier)")
            } catch {
                print(error)
            }
        }
        
        response.requestCompletedCallback()
    }
    
    func edit(identifier: Int, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        let beforeValues = beforeAction(request, response: response)
        guard var values = beforeValues else {
            return MustacheEvaluationContext.MapType()
        }
  
        guard let post = getPostWithIdentifier(identifier) else {
            return MustacheEvaluationContext.MapType()
        }
        
        values["post"] = post.keyValues()
        
        return values
    }
    
    
    func new(request: WebRequest, response: WebResponse) {
        
        // Handle new post request
        if let author = getCurrentUser(request, response: response), title = request.param("title"), body = request.param("body") {
            
            // Valid Post
            let newPost = Post(title: title, body: body, author: author)
            
            // Save Post
            do {
                DatabaseManager().database.getCollection(Post).insert(try newPost.document())
                response.redirectTo("/")
            } catch {
                
            }
        }
        
        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        let beforeValues = beforeAction(request, response: response)
        guard var values = beforeValues else {
            return MustacheEvaluationContext.MapType()
        }
        return values
        
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
        
        if let postBSON = DatabaseManager().database.getCollection(Post).find(identifier) {
            
            do {
                
                let post = Post(bson: postBSON)
                let query: [String: JSONValue] = ["_id": post.identifierDictionary!]
                let jsonEncode = try JSONEncoder().encode(query)
                
                DatabaseManager().database.getCollection(Post).remove(try! BSON(json: jsonEncode))
                
            } catch {
                print(error)
            }
        
            
        }
        response.requestCompletedCallback()
    }
    
    
}