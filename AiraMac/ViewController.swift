//
//  ViewController.swift
//  AiraMac
//
//  Created by Ian on 6/23/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    
//    private let ariaApi: AMAriaRpcApi

    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var sideView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var startBtn: NSButton!
    @IBOutlet weak var pauseBtn: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    
    var allDownload = [NSDictionary]()
    var activeDownload = [NSDictionary]()
    var waitingDownload = [NSDictionary]()
    var stoppedDownload = [NSDictionary]()
//    var ariaApi = AMAriaRpcApi()

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
        
        //        self.sideView.layer?.contents = NSImage.init(named:"side-img")
        self.sideView.layer?.backgroundColor = NSColor.init(patternImage: NSImage.init(named:"side-img")!).CGColor
        self.startBtn.enabled = false;

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
                AMAriaRpcApi().sendRpcJsonRequest(json)
            }
        })
        
    }
    
    func updateStatus() {
        AMAriaRpcApi().downloadTasks({(result: AnyObject?, error: NSError?) -> Int in
            // callback here
            self.allDownload = result as! [NSDictionary]
        })
        reloadDataWithSelection()
    }
    
    func reloadDataWithSelection() {
        let selectedIndexPaths = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selectedIndexPaths, byExtendingSelection: false)
    }
    
    
    func pauseBtnTapped(sender:NSButton) {
        
        let row = sender.tag
        let item = allDownload[row]
        let gid = item["gid"] as! String
        
        if sender.image?.name() == "pause" {
            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pause", "params":[gid] ]
            AMAriaRpcApi().sendRpcJsonRequest(json)
        } else if sender.image?.name() == "start" {
            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpause", "params":[gid] ]
            AMAriaRpcApi().sendRpcJsonRequest(json)
        }
    }
    
    
    @IBAction func stopTask(sender: NSMenuItem) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpauseAll", "params":[] ]
        AMAriaRpcApi().sendRpcJsonRequest(json)
    }
    
    
    @IBAction func removeTask(sender: NSMenuItem) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.remove", "params":[] ]
        AMAriaRpcApi().sendRpcJsonRequest(json)
    }
    
    
    @IBAction func startAll(sender: NSMenuItem) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpauseAll", "params":[] ]
        AMAriaRpcApi().sendRpcJsonRequest(json)
    }
    
    @IBAction func pauseAll(sender: NSMenuItem) {
        let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pauseAll", "params":[] ]
        AMAriaRpcApi().sendRpcJsonRequest(json)
    }
    
    @IBAction func removeAll(sender: NSMenuItem) {
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
