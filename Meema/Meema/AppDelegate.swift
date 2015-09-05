//
//  AppDelegate.swift
//  Meema
//
//  Created by Ellis Tsung on 9/4/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

var serial: SerialController! = SerialController()
var masterViewController: MasterViewController!
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
	@IBOutlet weak var window: NSWindow!
	lazy var mainWindow = MainWindowController(windowNibName: "MainWindowController")

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
		masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
		
		window.contentView.addSubview(masterViewController!.view)
		masterViewController!.view.frame = (window.contentView as! NSView).bounds
		self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
		self.window.titlebarAppearsTransparent = true
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	// MARK: - NSUserNotifcationCenterDelegate
	
	func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
		let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
		dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
			center.removeDeliveredNotification(notification)
		}
	}
	
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		return true
	}
	
	func switchView() {
//		let mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
//		window.contentView.removeAllItems()
//		window.contentView.addSubview(mainViewController!.view)
//		mainViewController!.view.frame = (window.contentView as! NSView).bounds
		self.mainWindow.showWindow(self)
		self.mainWindow.window!.makeKeyAndOrderFront(nil)
	}
}

