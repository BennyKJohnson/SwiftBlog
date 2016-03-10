//
//  ArticleController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib
import MongoDB

class ArticleController: RESTController {
    
    let modelName = "article"
    
    func getCurrentUser(request: WebRequest, response: WebResponse) -> Author? {
        
        // Obtain Session
        let currentSession = response.getSession("user")
        print(currentSession["user_id"])
        
        guard let currentUserID = currentSession["user_id"] as? String, let user = Author(userID: currentUserID) else {
            return  nil
        }

        return user
    }
    
    func getUserInformation(request: WebRequest, response: WebResponse) -> [String: Any] {
        
        if let user = getCurrentUser(request, response: response) {
            return ["user":["name": user.name] as [String: Any]] 
        } else {
            return [:]
        }
        
    }
    
    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType? {
        
        // Authenticate User
        guard let user = getCurrentUser(request, response: response) else {
            response.redirectTo("/login")
            return nil
        }
        
        return ["user":["name": user.name] as [String: Any]]
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        var values = getUserInformation(request, response: response)
        
        // Get Articles
        let db = try! DatabaseManager().database
        let postsBSON = db.getCollection(Article).find()
        var posts: [[String: Any]] = []
        
        while let postBSON = postsBSON?.next() {
            let post = Article(bson: postBSON)
            posts.append(post.keyValues())
        }
        
        postsBSON?.close()
        let reversedArticles = Array(posts.reverse())
        
        values["post"] = reversedArticles
        
        return values
    }
    
    func getArticleWithIdentifier(identifier: Int) -> Article? {
        let db = try! DatabaseManager().database
        let postsBSON = db.getCollection(Article).find(BSON(), fields: nil, flags: MongoQueryFlag(rawValue: 0), skip: identifier, limit: 1, batchSize: 0)
        guard let postBSON = postsBSON?.next() else {
            // response.setStatus(404, message: "Article not found")
            // response.requestCompletedCallback()
            return nil
        }
        
        let post = Article(bson: postBSON)
        return post
    }

    func getModelWithIdentifier(identifier: String) -> Article? {
        
        if let id = Int(identifier)  {
            return getArticleWithIdentifier(id)
        } else {
            return Article(urlTitle: identifier)
        }
        
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        let post: Article? = getModelWithIdentifier(identifier)
        
        var values: [String:Any] = getUserInformation(request, response: response)
    
        // Query Article
        // Get Articles
        guard let requestedArticle = post else {
            return MustacheEvaluationContext.MapType()
        }

        values["post"] = requestedArticle.keyValues()
        
        return values
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
      
        // Handle new post request
        if let title = request.param("title"), body = request.param("body"), existingArticle = getArticleWithIdentifier(identifier), currentAuthor = getCurrentUser(request, response: response) where currentAuthor.email == existingArticle.author.email {
            
            // Update post properties
            existingArticle.title = title
            existingArticle.body = body
            
            // Save Article
            do {
                try! DatabaseManager().database.getCollection(Article).save(try existingArticle.document())
                response.redirectTo("/\(modelName)s/\(identifier)")
            } catch {
                print(error)
            }
        }
        
        response.requestCompletedCallback()
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        let beforeValues = beforeAction(request, response: response)
        guard var values = beforeValues else {
            return MustacheEvaluationContext.MapType()
        }
  
        guard let post = getModelWithIdentifier(identifier) else {
            return MustacheEvaluationContext.MapType()
        }
        
        values["post"] = post.keyValues()
        
        return values
    }
    
    
    func new(request: WebRequest, response: WebResponse) {
        
        // Handle new post request
        if let author = getCurrentUser(request, response: response), title = request.param("title"), body = request.param("body") {
            
            // Valid Article
            let newArticle = Article(title: title, body: body, author: author)
            
            // Save Article
            do {
                let database = try! DatabaseManager().database
                newArticle._objectID = database.generateObjectID()
                
                database.getCollection(Article).insert(try newArticle.document())
                
                // Update Author
                author.articles.append(newArticle)
                try database.insert(author)

                
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