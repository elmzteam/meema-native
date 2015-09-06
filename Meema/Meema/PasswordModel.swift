//
//  PasswordModel.swift
//  Meema
//
//  Created by Ellis Tsung on 9/5/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Foundation

class PasswordModel: NSObject {
	var url: String
	var children: [PasswordModel]?
	init(url: String, children: [PasswordModel]?) {
		self.url = url
		self.children = children
	}
}