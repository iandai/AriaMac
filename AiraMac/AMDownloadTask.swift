//
//  AMDownloadTask.swift
//  AiraMac
//
//  Created by Ian on 7/19/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Foundation

class AMDownloadTask {

    var gid:String
    var name:String
    var completedLength:Double
    var totalLength:Double
    var status:String
    var progress: Double

    init(responseItem: NSDictionary) {
        
        self.gid = responseItem["gid"] as! String
        self.name = "" // call func here is illegal
        self.completedLength = (responseItem["completedLength"] as! NSString).doubleValue
        self.totalLength = (responseItem["totalLength"] as! NSString).doubleValue
        self.status = responseItem["status"] as! String
        self.progress = 0
        setupName(responseItem)
        setupProgress(responseItem)
    }
    
    func setupName(responseItem: NSDictionary) {
        let files = responseItem["files"] as! [NSDictionary]
        let file = files[0] as NSDictionary
        let path = file["path"] as! NSString
        self.name = path.lastPathComponent
        if self.name ==  "" {
            self.name = "----"
        }
    }
    
    func setupProgress(responseItem: NSDictionary) {
        var completedLength: Double
        var totalLength: Double
        completedLength = (responseItem["completedLength"] as! NSString).doubleValue
        totalLength = (responseItem["totalLength"] as! NSString).doubleValue
        
        if totalLength == 0 {
            self.progress = 0
        } else {
            self.progress = (completedLength / totalLength) * 100
        }
    }
}





