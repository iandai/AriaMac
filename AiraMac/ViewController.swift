//
//  ViewController.swift
//  AiraMac
//
//  Created by Ian on 6/23/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var sideView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var startBtn: NSButton!
    @IBOutlet weak var pauseBtn: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    
    @IBOutlet weak var startMenuItem: NSMenuItem!
    @IBOutlet weak var pauseMenuItem: NSMenuItem!
    @IBOutlet weak var removeMenuItem: NSMenuItem!
    
    var allDownloadTasks = [NSDictionary]()
    var ariaApi = AMAriaRpcApi()

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
        
        self.sideView.layer?.backgroundColor = NSColor.init(patternImage: NSImage.init(named:"side-img")!).CGColor
        updateButtonState("init")

        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateStatus), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSEventTrackingRunLoopMode)
    }

    func updateStatus() {
        ariaApi.downloadTasks({(result: AnyObject?, error: NSError?) in
            self.allDownloadTasks = result as! [NSDictionary]
        })
        reloadDataWithSelection()
    }
    
    func reloadDataWithSelection() {
        let selectedIndexPaths = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selectedIndexPaths, byExtendingSelection: false)
    }
    
    // START STATE: active, waiting, error
    // PAUSED STATE: paused
    // Complete STATE: complete
    // INIT STATE: init, removed
    func updateButtonState(taskStatus: String) {
        switch (taskStatus) {
        case ("active"),("waiting"),("error"):
            self.startBtn.enabled = false
            self.pauseBtn.enabled = true
            self.deleteBtn.enabled = true
            self.startMenuItem.enabled = false
            self.pauseMenuItem.enabled = true
            self.removeMenuItem.enabled = true
        case ("paused"):
            self.startBtn.enabled = true
            self.pauseBtn.enabled = false
            self.deleteBtn.enabled = true
            self.startMenuItem.enabled = true
            self.pauseMenuItem.enabled = false
            self.removeMenuItem.enabled = true
        case ("complete"):
            self.startBtn.enabled = false
            self.pauseBtn.enabled = false
            self.deleteBtn.enabled = true
            self.startMenuItem.enabled = false
            self.pauseMenuItem.enabled = false
            self.removeMenuItem.enabled = true
        default: // init, remove status, unselected
            self.startBtn.enabled = false
            self.pauseBtn.enabled = false
            self.deleteBtn.enabled = false
            self.startMenuItem.enabled = false
            self.pauseMenuItem.enabled = false
            self.removeMenuItem.enabled = false
        }
    }
    
    @IBAction func tableRowSelected(sender: AnyObject) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            updateButtonState(task["status"] as! String)
        } else {
            updateButtonState("unselected")
        }
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
                self.ariaApi.addUrl(enteredString)
            }
        })
    }
    
    
    @IBAction func startTaskBtn(sender: NSButton) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.unpause(gid)
        }
    }
    
    @IBAction func stopTaskBtn(sender: NSButton) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.pause(gid)
        }
    }
    
    @IBAction func removeTaskBtn(sender: NSButton) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.remove(gid)
        }
    }
    
    @IBAction func showInFinder(sender: NSMenuItem) {
        NSWorkspace.sharedWorkspace().selectFile("~/Downloads/", inFileViewerRootedAtPath: "")
    }
    
    @IBAction func startTask(sender: NSMenuItem) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.unpause(gid)
        }
    }
    
    @IBAction func stopTask(sender: NSMenuItem) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.pause(gid)
        }
    }
    
    @IBAction func removeTask(sender: NSMenuItem) {
        let index = self.tableView.selectedRow
        if index > -1 {
            let task = self.allDownloadTasks[index]
            let gid = task["gid"] as! String
            self.ariaApi.remove(gid)
        }
    }
    
    @IBAction func startAll(sender: NSMenuItem) {
        self.ariaApi.unpauseAll()
    }
    
    @IBAction func pauseAll(sender: NSMenuItem) {
        self.ariaApi.pauseAll()
    }
}

extension ViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return allDownloadTasks.count ?? 0
    }
}

extension ViewController : NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var name:String=""
        var completedLength:Double=0
        var progress:Double=0.0
        var status:String=""
        var cellIdentifier:String=""
        
        let item = allDownloadTasks[row]
        let task = AMDownloadTask(responseItem: item)
        
        if tableColumn == tableView.tableColumns[0] {
            name = task.name
            completedLength = task.completedLength
            progress = task.progress
            status = task.status
            cellIdentifier = "InfoCell"
        }
        
        if let cell : AMTableCell = tableView.makeViewWithIdentifier(cellIdentifier, owner: self) as? AMTableCell {
            cell.nameLbl.stringValue = name
            cell.progressIndicator.doubleValue = progress
            cell.progressLbl.stringValue = String(round(progress*100)/100) + "%"
            cell.completedLengthLbl.stringValue = "\(String(round(completedLength/(1024*1024)*100)/100)) MB"
            cell.status = status
            return cell
        }
        return nil
    }
}



//    func pauseBtnTapped(sender:NSButton) {
//
//        let row = sender.tag
//        let item = allDownloadTasks[row]
//        let task = AMDownloadTask(responseItem: item)
//        let gid = task.gid
//
//        if sender.image?.name() == "pause" {
//            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.pause", "params":[gid] ]
//            AMAriaRpcApi().sendRpcJsonRequest(json)
//        } else if sender.image?.name() == "start" {
//            let json = [ "jsonrpc": "2.0","id":1, "method": "aria2.unpause", "params":[gid] ]
//            AMAriaRpcApi().sendRpcJsonRequest(json)
//        }
//    }

//    func tableViewSelectionDidChange(notification: NSNotification) {
//        print("here")
//    }


//extension NSTableView {
//    public override func rightMouseDown(event: NSEvent) {
//
//        let cellIdentifier = "InfoCell"
//        let cell = self.makeViewWithIdentifier(cellIdentifier, owner: self) as? AMTableCell
//        event.updateButtonState((cell?.status)!)
//    }
//}

//            cell.pauseBtn.tag = row
//            cell.pauseBtn.target = self
//            cell.pauseBtn.action = #selector(pauseBtnTapped(_:))
//            cell.pauseBtn.hidden = true

//            if status == "paused" {
//                cell.pauseBtn.hidden = false
//                cell.pauseBtn.image = NSImage(named: "start")
//            } else if status == "active" {
//                cell.pauseBtn.hidden = false
//                cell.pauseBtn.image = NSImage(named: "pause")
//            }