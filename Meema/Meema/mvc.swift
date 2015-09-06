//
//  mvc.swift
//  Meema
//
//  Created by Ellis Tsung on 9/6/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

class mvc: NSViewController, NSOutlineViewDelegate {
	@IBOutlet weak var outline: NSOutlineView!
	@IBOutlet weak var url: NSTextField!
	@IBOutlet var dataController: NSTreeController!
	var data = [PasswordModel]()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Clear treecontroller
		dataController.content = nil

		outline.setDelegate(self)
		serial.getFragments()
	}
	
	func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		return outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
	}
	
	func outlineViewSelectionDidChange(notification: NSNotification) {
		if let selected: AnyObject = (outline.itemAtRow(outline.selectedRow) as! NSTreeNode).representedObject {
			url.stringValue = (selected as! PasswordModel).url
		}
	}
}

extension mvc {
	@IBAction func newPass(sender: AnyObject) {
		// TODO: create dialog box
		println("Adding password")
		let alert: NSAlert = NSAlert()
		let url: NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		url.usesSingleLineMode = true
		alert.messageText = "Save new account credentials"
		alert.informativeText = "Name/URL:"
		alert.addButtonWithTitle("Next")
		alert.addButtonWithTitle("Cancel")
		alert.accessoryView = url
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = url.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			if input.isEmpty {
				masterViewController.alertDialog("Empty name", informative: "Please enter a name/URL")
			} else {
				setPassword(input)
			}
		}
	}
	
	func setPassword(name: String) {
		let alert: NSAlert = NSAlert()
		let password: NSSecureTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		password.usesSingleLineMode = true
		alert.messageText = "Save new account credentials"
		alert.informativeText = "Enter your password"
		alert.addButtonWithTitle("Next")
		alert.addButtonWithTitle("Back")
		alert.accessoryView = password
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = password.stringValue
			if input.isEmpty {
				masterViewController.alertDialog("Empty password", informative: "Please enter a valid password")
			} else {
				confirmPassword(name, pwd: input)
			}
		} else if result == NSAlertSecondButtonReturn {
			newPass(self)
		}
	}
	
	func confirmPassword(name: String, pwd: String) {
		let alert: NSAlert = NSAlert()
		let password: NSSecureTextField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 270, height: 24))
		password.usesSingleLineMode = true
		alert.messageText = "Save new account credentials"
		alert.informativeText = "Confirm your password"
		alert.addButtonWithTitle("Next")
		alert.addButtonWithTitle("Back")
		alert.accessoryView = password
		let result = alert.runModal()
		if result == NSAlertFirstButtonReturn {
			let input = password.stringValue
			if input.isEmpty {
				masterViewController.alertDialog("Empty password", informative: "Please enter a valid password")
			} else {
				serial.register(name, password: pwd)
			}
		} else if result == NSAlertSecondButtonReturn {
			setPassword(name)
		}
	}
}

extension mvc {
	@IBAction func clipboard(sender: AnyObject) {
		// Retrieve password
		if let selected: AnyObject = (outline.itemAtRow(outline.selectedRow) as! NSTreeNode).representedObject {
			serial.getFragment(selected as! PasswordModel)
		}
	}
	
	func saveToClipboard(password: String) {
		let pasteBoard = NSPasteboard.generalPasteboard()
		pasteBoard.clearContents()
		pasteBoard.writeObjects([password])
	}
}