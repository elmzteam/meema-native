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
	var data: [PasswordModel] = [PasswordModel(url: "a", children: [PasswordModel(url: "a", children: nil)]), PasswordModel(url: "a", children: nil)]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		serial.getFragments()
		outline.setDelegate(self)
		println(data)
	}
	
	func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		return outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
	}
	
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		return (item as! NSMutableDictionary)["name"]!
	}
}

//extension mvc {
//	@IBAction func newPass(sender: AnyObject) {
//		// TODO: create dialog box
//	}
//}
