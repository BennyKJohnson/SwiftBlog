//
//  Route.swift
//  SwiftBlog
//
//  Created by Ben Johnson on 7/03/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//



protocol RESTRoute {
    
    var path: String { get }
    
    var editPath: String {get }
    
}

extension RESTRoute {
    var editPath: String {
            return "\(path)/edit"
    }
}
