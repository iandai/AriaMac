//
//  AMAriaRpcApi.swift
//  AiraMac
//
//  Created by Ian on 7/14/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Foundation


class AMAriaRpcApi {
    
    func sendRpcJsonRequest(json: AnyObject) {

        let request = constructRequest(json)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                print("Result -> \(result)")
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
    }
    
    func constructRequest(json: AnyObject) ->  NSURLRequest {
        
        let url = NSURL(string: "http://rpc:123456@127.0.0.1:6800/jsonrpc")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            request.HTTPBody = jsonData
        } catch {
            print(error)
        }
        
        return request
    }

    
}