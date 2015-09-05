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
	@IBOutlet weak var users: NSPopUpButton!
	var accounts: [String] = serial.accounts {
		didSet {
			users.removeAllItems()
			users.addItemsWithTitles(accounts)
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		serial.locateDevice()
    }
}

extension MasterViewController {
	@IBAction func connect(sender: AnyObject) {
		println("yo!")
	}
}