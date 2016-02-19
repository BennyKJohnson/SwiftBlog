//
//  PerfectExtensions.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 19/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

enum RequestMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

extension WebRequest {
    var format: String {
        return requestURI().componentsSeparatedByString(".").last ?? "html"
    }
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
