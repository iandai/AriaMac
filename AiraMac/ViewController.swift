//
//  ViewController.swift
//  AiraMac
//
//  Created by Ian on 6/23/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var allDownload = [NSDictionary]()
    var activeDownload = [NSDictionary]()
    var waitingDownload = [NSDictionary]()
    var stoppedDownload = [NSDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
   
        // get status every second
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateStatus), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSEventTrackingRunLoopMode)
    }

    @IBAction func addUrl(sender: NSButton) {
    
        let a = NSAlert()
        a.messageText = "Please enter url"
        a.addButtonWithTitle("Start")
        a.addButtonWithTitle("Cancel")
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 100))
        inputTextField.placeholderString = "Enter string"
        a.accessoryView = inputTextField
        
        a.beginSheetModalForWindow(self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                let enteredString = inputTextField.stringValue
                
                // add uri task
                let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.addUri", "params":[[enteredString]] ]
                self.sendRpcJsonRequest(json)
            }
        })
        
    }
    
    @IBAction func stopDownloading(sender: NSButton) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pauseAll", "params":[] ]
        sendRpcJsonRequest(json)
    }
    
    @IBAction func startDownloading(sender: NSButton) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpauseAll", "params":[] ]
        sendRpcJsonRequest(json)
    }
    
    
    func updateStatus() {
        getAllDownload()
        reloadDataWithSelection()
    }
    
    func reloadDataWithSelection() {
        let selectedIndexPaths = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selectedIndexPaths, byExtendingSelection: false)
    }
    
    
    func getAllDownload() {
        
        let downloadGroup = dispatch_group_create()
        
        // getActiveDownload
        let json1 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellActive", "params":[] ]
        let request1 = constructRequest(json1)
        dispatch_group_enter(downloadGroup)
        let getActiveDownload = NSURLSession.sharedSession().dataTaskWithRequest(request1){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    self.activeDownload = downloadInfos
                }
            } catch {
                print("Error -> \(error)")
            }
            dispatch_group_leave(downloadGroup)
        }
        getActiveDownload.resume()
        
       
        // getWaitingDownload
        let json2 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellWaiting", "params":[0,100] ]
        let request2 = constructRequest(json2)
        dispatch_group_enter(downloadGroup)
        let getWaitingDownload = NSURLSession.sharedSession().dataTaskWithRequest(request2){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    self.waitingDownload = downloadInfos
                }
            } catch {
                print("Error -> \(error)")
            }
            dispatch_group_leave(downloadGroup)
        }
        getWaitingDownload.resume()
        
        // getStoppedDownload
        let json3 = [ "jsonrpc": "2.0","id":1, "method": "aria2.tellStopped", "params":[0,100] ]
        let request3 = constructRequest(json3)
        dispatch_group_enter(downloadGroup)
        let getStoppedDownload = NSURLSession.sharedSession().dataTaskWithRequest(request3){ data, response, error in
            if error != nil { print("Error -> \(error)"); return }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if let downloadInfos = result!["result"] as? [NSDictionary] {
                    self.stoppedDownload = downloadInfos
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
            self.allDownload = self.activeDownload + self.waitingDownload + self.stoppedDownload
            // updatetableview
            print("Result -> complete")
        }
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
    
    
    func pauseBtnTapped(sender:NSButton) {
 
        let row = sender.tag
        let item = allDownload[row]
        let gid = item["gid"] as! String

        if sender.image?.name() == "pause" {
            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pause", "params":[gid] ]
            sendRpcJsonRequest(json)
        } else if sender.image?.name() == "start" {
            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpause", "params":[gid] ]
            sendRpcJsonRequest(json)
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}


extension ViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return allDownload.count ?? 0
    }
}

extension ViewController : NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var name:String=""
        var completedLength:Double=0
        var totalLength:Double=0
        var progress:Double=0.0
        var status:String=""
        var cellIdentifier:String=""
        
        let item = allDownload[row]
        if tableColumn == tableView.tableColumns[0] {
            
            
            let files = item["files"] as! [NSDictionary]
            let file = files[0] as NSDictionary
            let path = file["path"] as! NSString
            name = path.lastPathComponent
            if name ==  "" {
                name = "----"
            }
            completedLength = (item["completedLength"] as! NSString).doubleValue
            totalLength = (item["totalLength"] as! NSString).doubleValue
            if totalLength == 0 {
                progress = 0
            } else {
                progress = (completedLength / totalLength) * 100
            }
            status = item["status"] as! String
            
            cellIdentifier = "InfoCell"
        }
        
        if let cell : AMTableCell = tableView.makeViewWithIdentifier(cellIdentifier, owner: self) as? AMTableCell {
            cell.nameLbl.stringValue = name
            cell.progressIndicator.doubleValue = progress
            cell.progressLbl.stringValue = String(round(progress*100)/100) + "%"
            let completedLengthMB = completedLength/(1024*1024)
            cell.completedLengthLbl.stringValue = "\(String(round(completedLengthMB*100)/100)) MB"
            cell.pauseBtn.tag = row
            cell.pauseBtn.target = self
            cell.pauseBtn.action = #selector(pauseBtnTapped(_:))
            cell.pauseBtn.hidden = true

            if status == "paused" {
                cell.pauseBtn.hidden = false
                cell.pauseBtn.image = NSImage(named: "start")
            } else if status == "active" {
                cell.pauseBtn.hidden = false
                cell.pauseBtn.image = NSImage(named: "pause")
            }
            
            return cell
        }
        return nil
    }
}