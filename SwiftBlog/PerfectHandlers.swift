//
//  PerfectHandlers.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB

extension Routing {
    class func addRoutesForRESTController(controller: RESTController, supportJSON: Bool = true) {
        
        // Show
        Routing.Routes["GET", "/\(controller.modelName)s/{id}"] = { _ in return controller }
        
        // Edit
        Routing.Routes["GET", "/\(controller.modelName)s/{id}/{action}"] = { _ in return controller }
        
        // Update
        Routing.Routes["POST", "/\(controller.modelName)s/{id}"] = { _ in return controller }
        
        // Delete
        Routing.Routes["DELETE", "/\(controller.modelName)s/{id}"] = { _ in return controller }
        
        // Index
        Routing.Routes["GET", "/\(controller.modelName)s"] = { _ in return controller }
        if supportJSON {
            Routing.Routes["GET", "/\(controller.modelName)s.json"] = { _ in return controller }
            Routing.Routes["GET", "/\(controller.modelName)s/{id}"] = { _ in return controller }

        }

        Routing.Routes["GET", "/\(controller.modelName)s/new"] = { _ in return controller }
        Routing.Routes["POST", "/\(controller.modelName)s"] = { _ in return controller }
    }
}

// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
public func PerfectServerModuleInit() {
    
    // Register our handler class with the PageHandlerRegistry.
    // The name "TTHandler", which we supply here, is used within a mustache template to associate the template with the handler.
    
    // Do routing
    Routing.Handler.registerGlobally()
    
    Routing.addRoutesForRESTController(PostController())
    Routing.Routes["GET", "/"] = { _ in return PostController() }

    print("\(Routing.Routes.description)")
    
    let databaseManager = DatabaseManager()
    databaseManager.prepareDatabase()
    
}
