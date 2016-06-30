//
//  AMTableCell.swift
//  AiraMac
//
//  Created by Ian on 6/28/16.
//  Copyright © 2016 FirstRisingTide. All rights reserved.
//

import Foundation
import Cocoa

class AMTableCell : NSTableCellView {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var pauseBtn: NSButton!
    @IBOutlet weak var nameLbl: NSTextField!
    @IBOutlet weak var progressLbl: NSTextField!
    @IBOutlet weak var completedLengthLbl: NSTextField!
}