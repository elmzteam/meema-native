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
var loadingViewController: LoadingViewController!
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
	@IBOutlet weak var window: NSWindow!
	lazy var mainWindow = MainWindowController(windowNibName: "MainWindowController")

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Initialize notifications
		NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

		// Create login screen
		masterViewController = MasterViewController(nibName: "MasterViewController", bundle: nil)
		loadingViewController = LoadingViewController(nibName: "LoadingViewController", bundle: nil)
		
		// Set layout
		window.contentView.addSubview(loadingViewController.view)
		loadingViewController.view.frame = (window.contentView as! NSView).bounds

		// Setup window
		self.window.styleMask = self.window.styleMask | NSFullSizeContentViewWindowMask;
		self.window.titlebarAppearsTransparent = true

		// Search for serial port
		serial.locateDevice(false)
//		switchView()
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
	
	func showLogin() {
		loadingViewController.stop()
		window.contentView.addSubview(masterViewController.view)
		masterViewController.view.frame = (window.contentView as! NSView).bounds
	}

	func switchView() {
//		let mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
//		window.contentView.addSubview(mainViewController!.view)
//		mainViewController!.view.frame = (window.contentView as! NSView).bounds
		self.window.close()
		self.mainWindow.showWindow(self)
		self.mainWindow.window!.makeKeyAndOrderFront(nil)
	}
}

