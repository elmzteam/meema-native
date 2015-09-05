//
//  MainWindowController.swift
//  Meema
//
//  Created by Ellis Tsung on 9/5/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		let mainVC: MainViewController = MainViewController(nibName: "MainViewController", bundle: nil)!
		self.window!.contentView.addSubview(mainVC.view)
		mainVC.view.frame = (self.window!.contentView as! NSView).bounds
		self.window!.styleMask = self.window!.styleMask | NSFullSizeContentViewWindowMask;
		self.window!.titlebarAppearsTransparent = true
		self.window!.titleVisibility = .Hidden
		self.window!.backgroundColor = NSColor.whiteColor()
    }
    
}
