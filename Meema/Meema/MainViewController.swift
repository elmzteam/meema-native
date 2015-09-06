//
//  MainViewController.swift
//  Meema
//
//  Created by Ellis Tsung on 9/5/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
	@IBOutlet weak var outline: NSOutlineView!
	var data: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		data = NSMutableArray(array: [NSMutableDictionary(dictionary: ["name": "asdfasdf", "children": NSMutableArray()])])
		serial.getFragments()
		outline.setDelegate(self)
		outline.setDataSource(self)
		println(data)
    }
	
	func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
		if let textField = view.textField {
			textField.stringValue = item as! String
		}
		return view
	}
	
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		return (item as! NSMutableDictionary)["name"]!
	}
}

extension MainViewController {
	@IBAction func newPass(sender: AnyObject) {
		// TODO: create dialog box
	}
}