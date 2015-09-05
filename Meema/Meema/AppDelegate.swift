//
//  AppDelegate.swift
//  Meema
//
//  Created by Ellis Tsung on 9/4/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var masterViewController: MasterViewController!
	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
		
		window.contentView.addSubview(masterViewController.view)
		masterViewController.view.frame = (window.contentView as! NSView).bounds
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

