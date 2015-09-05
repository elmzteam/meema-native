//
//  MasterViewController.swift
//  Meema
//
//  Created by Ellis Tsung on 9/4/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa
import ORSSerial

class MasterViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension MasterViewController {
	@IBAction func connect(sender: AnyObject) {
		println("yo!")
		serial.locateDevice()
	}
}