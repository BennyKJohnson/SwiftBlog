//
//  LoginHandler.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 24/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib



class LogoutHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        // Logout current user
        let currentSession = response.getSession("user")
        currentSession["user_id"] = nil
        
        response.redirectTo("/")
        response.requestCompletedCallback()
    }
    
}

class LoginHandler: RequestHandler {
    
    var authenticatedUser: Author?
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        if request.requestMethod() == "GET" {
            let templateURL = request.documentRoot + "/templates/template.mustache"
            let indexURL = request.documentRoot + "/templates/login.mustache"
            let values = [:] as [String: Any]
            let content = parseMustacheFromURL(indexURL, withValues: values)
            let templateContent = ["content": content] as [String: Any]
            
            response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
            response.requestCompletedCallback()
            
        } else {
            print(request.urlVariables)
            
            if let email = request.param("email"), password = request.param("password") {
                // Get User with Email
                guard let user = Author(email: email) else {
                    
                    response.redirectTo(request.requestURI())
                    return response.requestCompletedCallback()
                }
                
                // Encrpyt provided password
                let authKey = Author.encodeRawPassword(email, password: password)
                if user.authKey == authKey {
                    // Successful
                    
                    // Setup Session
                    let session = response.getSession("user")
                    session["user_id"] = user._objectID
                    //∂session.commit()
                    
                    
                    response.redirectTo("/")
                }
                
                
                
            }
            
            response.requestCompletedCallback()

        }
        
        
      
    }
    
}