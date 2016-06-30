//
//  AppDelegate.swift
//  AiraMac
//
//  Created by Ian on 6/23/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        createAriaFolder()
        initAria2c()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func createAriaFolder() {
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "touch /tmp/aria2.session"]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(output!)
    }
    
    func initAria2c() {
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "\(NSBundle.mainBundle().resourcePath!)/aria2c/aria2c --conf-path=\(NSBundle.mainBundle().resourcePath!)/aria2c/aria2c.conf --dir=${HOME}/Downloads/"]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(output!)
    }
}

