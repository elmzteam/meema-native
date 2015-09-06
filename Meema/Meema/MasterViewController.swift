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
		users.removeAllItems()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		password.becomeFirstResponder()
	}
	
	func switchView() {
		let ad = NSApplication.sharedApplication().delegate as! AppDelegate
		ad.switchView()
	}
	
	func alertDialog(msg: String, informative: String) {
		let alert: NSAlert = NSAlert()
		alert.addButtonWithTitle("Okay")
		alert.messageText = msg
		alert.informativeText = informative
		alert.runModal()
	}
}

extension MasterViewController {
	@IBAction func login(sender: AnyObject) {
		if let selected = users.selectedItem {
			if password.stringValue.isEmpty {
				alertDialog("Empty password", informative: "Please enter a password for \(selected.title)")
			} else {
				serial.login(selected.title, password: password.stringValue)
			}
		} else {
			alertDialog("No user selected!", informative: "Please select a user")
		}
	}
}

extension MasterViewController {
	@IBAction func createAccount(sender: AnyObject) {
		let alert: NSAlert = NSAlert()
		let username: NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		username.usesSingleLineMode = true
		alert.messageText = "Create new account"
		alert.informativeText = "Username:"
		alert.addButtonWithTitle("Next")
		alert.addButtonWithTitle("Cancel")
		alert.accessoryView = username
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = username.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			if input.isEmpty {
				alertDialog("Empty username", informative: "Please enter a username")
			} else if contains(users.itemTitles as! [String], input) {
				alertDialog("Username is already registered!", informative: "Failed to create user \(input)")
			} else {
				println("Valid username!")
				createPassword(input)
			}
		}
	}
	
	func createPassword(username: String) {
		let alert: NSAlert = NSAlert()
		let password: NSSecureTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		password.usesSingleLineMode = true
		alert.messageText = "Create new account"
		alert.informativeText = "Set a password for '\(username)'"
		alert.addButtonWithTitle("Next")
		alert.addButtonWithTitle("Back")
		alert.accessoryView = password
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = password.stringValue
			if input.isEmpty {
				alertDialog("Empty password", informative: "Please enter a valid password")
			} else {
				confirmPassword(username, pwd: input)
			}
		} else if result == NSAlertSecondButtonReturn {
			createAccount(self)
		}
	}
	
	func confirmPassword(username: String, pwd: String) {
		let alert: NSAlert = NSAlert()
		let password: NSSecureTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		password.usesSingleLineMode = true
		alert.messageText = "Create new account"
		alert.informativeText = "Confirm password"
		alert.addButtonWithTitle("Finish")
		alert.addButtonWithTitle("Back")
		alert.accessoryView = password
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = password.stringValue
			if input != pwd {
				alertDialog("Password mismatch", informative: "Your entered passwords do not match")
				createPassword(username)
			} else {
				println("Creating account")
			}
		} else if result == NSAlertSecondButtonReturn {
			createPassword(username)
		}
	}
}