//
//  LoadingViewController.swift
//  Meema
//
//  Created by Ellis Tsung on 9/5/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

class LoadingViewController: NSViewController {
	@IBOutlet weak var spinner: NSProgressIndicator!
	@IBOutlet weak var message: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		spinner.startAnimation(self)
    }
	
	func displayMessage(msg: String) {
		message.stringValue = msg
	}
	
	func stop() {
		spinner.stopAnimation(self)
		message.hidden = true
	}
}
