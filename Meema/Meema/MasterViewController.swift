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
	@IBOutlet weak var password: NSSecureTextField!
	var accounts: [String] = [] {
		didSet {
			users.removeAllItems()
			users.addItemsWithTitles(accounts)
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		serial.locateDevice(false)
		users.removeAllItems()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		switchView()
	}
	
	func switchView() {
		let ad = NSApplication.sharedApplication().delegate as! AppDelegate
		ad.switchView()
	}
}

extension MasterViewController {
	@IBAction func login(sender: AnyObject) {
		if let selected = users.selectedItem {
			if password.stringValue.isEmpty {
				let alert: NSAlert = NSAlert()
				alert.addButtonWithTitle("Okay")
				alert.messageText = "Empty password"
				alert.informativeText = "Please enter a password for \(selected.title)"
				alert.runModal()
			} else {
				serial.login(selected.title, password: password.stringValue)
			}
		} else {
			let alert: NSAlert = NSAlert()
			alert.addButtonWithTitle("Okay")
			alert.messageText = "No user selected!"
			alert.informativeText = "Please select a user"
			alert.runModal()
		}
	}
}