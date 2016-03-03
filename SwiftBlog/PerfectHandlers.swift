//
//  PerfectHandlers.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib
import MongoDB



// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
let AUTH_REALM = "SwiftBlog"

public func PerfectServerModuleInit() {
    
    // Register our handler class with the PageHandlerRegistry.
    // The name "TTHandler", which we supply here, is used within a mustache template to associate the template with the handler.
    
    // Do routing
    Routing.Handler.registerGlobally()
    
    Routing.addRoutesForRESTController(PostController())
    Routing.addRoutesForRESTController(AuthorController())

    Routing.Routes["GET", "/"] = { _ in return PostController() }
    
    Routing.Routes["/login"] = { _ in LoginHandler() }
    Routing.Routes["/logout"] = { _ in LogoutHandler() }
    
    Routing.Routes["GET", "/resources/pictures/*"] = {_  in StaticFileHandler() }
    Routing.Routes["GET", "/stylesheets/*"] = {_  in StaticFileHandler() }

    print("\(Routing.Routes.description)")
    
    let databaseManager = DatabaseManager()
    databaseManager.prepareDatabase()
    
}
