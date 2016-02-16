//
//  Controller.swift
//  Tap Tracker
//
//  Created by Benjamin Johnson on 5/02/2016.
//
//

import PerfectLib
import MongoDB

protocol RESTController: RequestHandler {
    
    var modelName: String { get }
    
    func show(identifier: Int, context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType
    
    func list(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType
    
    func create(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType
    
    func new(request: WebRequest, response: WebResponse)
    
    func update(identifier: Int, request: WebRequest, response: WebResponse)
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse)
    
    func edit(identifier: Int, context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType

    func prepareMustacheFromURL(url: String, values: [String: Any]) -> MustacheTemplate
    
}

extension RESTController {
    
    func prepareMustacheFromURL(url: String, values: [String: Any]) -> MustacheTemplate {
        
        let template = MustacheTemplate.FromURL(url)!
        
        let context = MustacheEvaluationContext(map: MustacheEvaluationContext.MapType())
        
        let collector = MustacheEvaluationOutputCollector()
        
        // Call Show
        let newContext = MustacheEvaluationContext(map: values)
        template.evaluate(newContext, collector: collector)
        
        return template
    }
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        print(request.requestURI())
        
        // Show handle
        if let id = request.urlVariables["id"],identifier = Int(id) {
            print("Request Method: \(request.requestMethod())")
            
            if request.requestMethod() == "POST" {
                
                update(identifier, request: request, response: response)
                
            } else if request.requestMethod() == "DELETE" {
              
                delete(identifier, request: request, response: response)
                
            } else {
                
                if let action = request.urlVariables["action"]{
                    
                    // Call Show
                    let templateURL = request.documentRoot + "//\(modelName)s/edit.mustache"
                    
                    let template = MustacheTemplate.FromURL(templateURL)!
                    
                    let context = MustacheEvaluationContext(map: MustacheEvaluationContext.MapType())
                    
                    let collector = MustacheEvaluationOutputCollector()
                    
                    // Call Show
                    var values = try! edit(identifier, context: context, collector: collector)
                    values["url"] = "/\(modelName)s/\(identifier)"
                    let newContext = MustacheEvaluationContext(map: values)
                    template.evaluate(newContext, collector: collector)

                    response.appendBodyString(collector.asString())
                    response.requestCompletedCallback()
                    
                } else {
                    
                    // Call Show
                    let templateURL = request.documentRoot + "//\(modelName)s/show.mustache"
                    let template = MustacheTemplate.FromURL(templateURL)!
                    
                    let context = MustacheEvaluationContext(map: MustacheEvaluationContext.MapType())
                    let collector = MustacheEvaluationOutputCollector()
                    
                    let values = try! show(identifier, context: context, collector: collector)
                    let newContext = MustacheEvaluationContext(map: values)
                    template.evaluate(newContext, collector: collector)
                    
                    response.appendBodyString(collector.asString())
                    response.requestCompletedCallback()
                }
                
          
            }
            
        } else if let action = request.requestURI().componentsSeparatedByString("/").last where action == "new" {
            
                let templateURL = request.documentRoot + "//\(modelName)s/new.mustache"
                let template = MustacheTemplate.FromURL(templateURL)!
                
                let context = MustacheEvaluationContext(map: MustacheEvaluationContext.MapType())
                
                let collector = MustacheEvaluationOutputCollector()
                
                // Call Show
                let values = try! create(context, collector: collector)
                let newContext = MustacheEvaluationContext(map: values)
                template.evaluate(newContext, collector: collector)
                
                response.appendBodyString(collector.asString())
                response.requestCompletedCallback()
            
        } else {
            
            if request.requestMethod() == "POST" {
                
                new(request, response: response)
                
            } else {
                
                let templateURL = request.documentRoot + "//index.mustache"
                let template = MustacheTemplate.FromURL(templateURL)!
                
                let context = MustacheEvaluationContext(map: MustacheEvaluationContext.MapType())
                
                let collector = MustacheEvaluationOutputCollector()
                
                // Call Show
                let values = try! list(context, collector: collector)
                let newContext = MustacheEvaluationContext(map: values)
                template.evaluate(newContext, collector: collector)
                
                response.appendBodyString(collector.asString())
                response.requestCompletedCallback()
            }
        }
    }
    
    func show(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType {
        
        return MustacheEvaluationContext.MapType()
        
    }
    
    func edit(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType {
        
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
    
    func list(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType {
        
        return MustacheEvaluationContext.MapType()
        
    }
    
    func create(context: MustacheEvaluationContext, collector: MustacheEvaluationOutputCollector) throws ->  MustacheEvaluationContext.MapType {
        
        return MustacheEvaluationContext.MapType()
    
    }
    
    
}

