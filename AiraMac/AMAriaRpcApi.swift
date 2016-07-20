//
//  AMAriaRpcApi.swift
//  AiraMac
//
//  Created by Ian on 7/14/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Foundation


//RPC INTERFACE
class AMAriaRpcApi {

    func downloadTasks(completion: (result: NSArray?, error: NSError?) -> Void) {
        
        let downloadGroup = dispatch_group_create()
        var allDownload = [NSDictionary]()
        var activeDownload = [NSDictionary]()
        var waitingDownload = [NSDictionary]()
        var stoppedDownload = [NSDictionary]()
        
        // getActiveDownload
        let json1 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellActive", "params":[] ]
        let request1 = AMAriaRpcApi().constructRequest(json1)
        dispatch_group_enter(downloadGroup)
        let getActiveDownload = NSURLSession.sharedSession().dataTaskWithRequest(request1){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    activeDownload = downloadInfos
                }
            } catch {
                print("Error -> \(error)")
            }
            dispatch_group_leave(downloadGroup)
        }
        getActiveDownload.resume()
        
        
        // getWaitingDownload
        let json2 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellWaiting", "params":[0,100] ]
        let request2 = AMAriaRpcApi().constructRequest(json2)
        dispatch_group_enter(downloadGroup)
        let getWaitingDownload = NSURLSession.sharedSession().dataTaskWithRequest(request2){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    waitingDownload = downloadInfos
                }
            } catch {
                print("Error -> \(error)")
            }
            dispatch_group_leave(downloadGroup)
        }
        getWaitingDownload.resume()
        
        // getStoppedDownload
        let json3 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellStopped", "params":[0,100] ]
        let request3 = AMAriaRpcApi().constructRequest(json3)
        dispatch_group_enter(downloadGroup)
        let getStoppedDownload = NSURLSession.sharedSession().dataTaskWithRequest(request3){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    stoppedDownload = downloadInfos
                }
            } catch {
                print("Error -> \(error)")
            }
            dispatch_group_leave(downloadGroup)
        }
        getStoppedDownload.resume()
        
        // completion
        dispatch_group_notify(downloadGroup, dispatch_get_main_queue()) {
            // This block will be executed when all tasks are complete
            allDownload = activeDownload + waitingDownload + stoppedDownload
            completion(result: allDownload, error: nil)

            // updatetableview
            // print("Result -> complete")
        }
    }

    
    func addUrl(inputUrl: String) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.addUri", "params":[[inputUrl]] ]
        sendRpcJsonRequest(json)
    }
    
    func unpause(gid: String) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpause", "params":[gid] ]
        sendRpcJsonRequest(json)
    }

    func pause(gid: String) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pause", "params":[gid] ]
        sendRpcJsonRequest(json)
    }
    
    func remove(gid: String) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.remove", "params":[gid] ]
        sendRpcJsonRequest(json)
    }
    
    func unpauseAll() {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpauseAll", "params":[] ]
        sendRpcJsonRequest(json)
    }
    
    func pauseAll() {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pauseAll", "params":[] ]
        sendRpcJsonRequest(json)
    }
    
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