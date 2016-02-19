//
//  RESTController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

protocol RESTController: RequestHandler {
    
    var modelName: String { get }
    
    func show(identifier: Int, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    
    func new(request: WebRequest, response: WebResponse)
    
    func update(identifier: Int, request: WebRequest, response: WebResponse)
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse)
    
    func edit(identifier: Int, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    
}

extension RESTController {
    
    func parseMustacheFromURL(url: String, withValues values: [String: Any]) -> String {
        
        let template = MustacheTemplate.FromURL(url)!
        let context =  MustacheEvaluationContext(map: values)
        
        let collector = MustacheEvaluationOutputCollector()
        template.evaluate(context, collector: collector)
        
        return collector.asString()
    }
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        print(request.requestURI())
        
        let requestMethod = RequestMethod(rawValue: request.requestMethod())!
 
        
        // Show handle
        if let id = request.urlVariables["id"],identifier = Int(id) {
            
            switch(requestMethod) {
            case .POST, .PATCH, .PUT:
                update(identifier, request: request, response: response)
                
            case .DELETE:
                delete(identifier, request: request, response: response)
                
            case .GET:
                
                if let _ = request.urlVariables["action"]{
                    
                    // Call Show
                    let templateURL = request.documentRoot + "//\(modelName)s/edit.mustache"
                 
                    var values = try! edit(identifier, request: request, response: response)
                    values["url"] = "/\(modelName)s/\(identifier)"
                    
                    response.appendBodyString(parseMustacheFromURL(templateURL, withValues: values))
                    response.requestCompletedCallback()
                    
                } else {
                    
                    let templateURL: String
                    if request.format == "json" {
                        templateURL = request.documentRoot + "//\(modelName)s/show.json.mustache"
                    } else {
                        templateURL = request.documentRoot + "//\(modelName)s/show.mustache"
                    }

                    let values = try! show(identifier, request: request, response: response)
                    
                    response.appendBodyString(parseMustacheFromURL(templateURL, withValues: values))
                    response.requestCompletedCallback()
                }
            }
            
        } else if let action = request.requestURI().componentsSeparatedByString("/").last where action == "new" {
            
                let templateURL = request.documentRoot + "//\(modelName)s/new.mustache"
    
                // Call Show
                let values = try! create(request, response: response)
     
                response.appendBodyString(parseMustacheFromURL(templateURL, withValues: values))
                response.requestCompletedCallback()
            
        } else {
            
            if requestMethod == .POST {
                
                new(request, response: response)
                
            } else {
                
                // Show all posts
                let templateURL: String
                if request.format == "json" {
                    templateURL = request.documentRoot + "//\(modelName)s/index.json.mustache"
                } else {
                    templateURL = request.documentRoot + "//\(modelName)s/index.mustache"
                }
                
                let values = try! list(request, response: response)
                response.appendBodyString(parseMustacheFromURL(templateURL, withValues: values))
                response.requestCompletedCallback()
                
            }
        }
    }
    
    func show(identifier: Int,request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        return MustacheEvaluationContext.MapType()
    }
    
    func edit(identifier: Int, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        return MustacheEvaluationContext.MapType()
    }
    
    func update(identifier: Int,request: WebRequest, response: WebResponse) {
        
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        response.requestCompletedCallback()
        
    }
    
    func delete(identifier: Int,request: WebRequest, response: WebResponse) {
        
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        response.requestCompletedCallback()
        
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        return MustacheEvaluationContext.MapType()
        
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
        return MustacheEvaluationContext.MapType()
    
    }
    
    
}

