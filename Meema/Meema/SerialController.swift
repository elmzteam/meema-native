//
//  SerialController.swift
//  Meema/Users/El1t/Documents/Repo/meema-native/Meema/Meema/SerialController.swift:27:4: 'MasterViewController.Type' does not have a member named 'accounts'
//
//  Created by Ellis Tsung on 9/4/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa
import ORSSerial

class SerialController: NSObject, ORSSerialPortDelegate {
	let manager = ORSSerialPortManager.sharedSerialPortManager()
	let commands: [String: UInt8] = ["ping": 0x01, "isUnlocked": 0x02, "getUID": 0x03, "getActiveAccount": 0x04, "getAllAccounts": 0x05, "login": 0x06, "getFragment": 0x07, "getFragments": 0x08, "create": 0x10, "register": 0x11]
	let responses: [String: UInt8] = ["getChannel": 0xFF, "isUnlocked": 0xFE, "response": 0xF2, "approved": 0xF1, "denied": 0xF0, "error": 0xEF]
	var serialPort: ORSSerialPort? {
		didSet {
			oldValue?.close()
			oldValue?.delegate = nil
			serialPort?.delegate = self
		}
	}
	var channel: UInt8 = 0x00
	var command: String = ""
	var lastUsername: String = ""
	var accounts: [String] = [] {
		didSet {
			masterViewController.accounts = self.accounts
		}
	}
	var UID: String = ""
	var activeAccount: String = ""
	var recent: String = ""
	
	override init() {
		super.init()
		
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserver(self, selector: "serialPortsWereConnected:", name: ORSSerialPortsWereConnectedNotification, object: nil)
		nc.addObserver(self, selector: "serialPortsWereDisconnected:", name: ORSSerialPortsWereDisconnectedNotification, object: nil)
	}
	
	func locateDevice(wait: Bool) {
		var ports: [ORSSerialPort] = manager.availablePorts as! [ORSSerialPort]
		for port in ports {
			if port.name.rangeOfString("usbmodem") != nil {
				port.baudRate = 9600
				self.serialPort = port
				println("Found Meema and set port")
				if wait {
					println("Waiting 8 secs for Edison bootup")
					loadingViewController.displayMessage("Waiting for Meema...")
					delay(5) {
						loadingViewController.displayMessage("Almost ready...")
					}
					delay(8) {
						// Wait for kernel to load
						self.connect()
					}
				} else {
					self.connect()
				}
				break
			}
		}
		if self.serialPort == nil {
			println("No Meema found")
			postNotification("Meema not found!", message: "Please ensure your Meema connected and warmed up.")
		}
	}
	
	func connect() {
		if let port = self.serialPort {
			if (!port.open) {
				port.open()
				loadingViewController.displayMessage("Communicating with Meema...")
				// Request a channel
				delay(0.1) {
					serial.send(serial.commands["ping"]!)
				}
			}
		} else {
			println("No port selected!")
		}
	}
	
	func disconnect() {
		if let port = self.serialPort {
			if (port.open) {
				port.close()
				self.channel = 0x00
			}
		} else {
			println("No port selected!")
		}
	}
	
	func send(message: UInt8) {
		send([message])
	}

	func send(message: [UInt8]) {
		println("Sending message: \([channel] + message)")
		self.serialPort?.sendData(NSData(bytes: [channel] + message, length: message.count + 1))
	}

	// ===========Tasks=============
	
	func getAccounts() {
		command = "getAllAccounts"
		send(self.commands[command]!)
	}
	
	func getActiveAccount() {
		command = "getActiveAccount"
		send(self.commands[command]!)
	}
	
	func getFragment(model: PasswordModel) {
		recent = model.url
		command = "getFragment"
		send([self.commands[command]!, UInt8(count(model.url))] + [UInt8](model.url.utf8))
	}
	
	func getFragments() {
		command = "getFragments"
		send(self.commands[command]!)
	}
	
	func login(username: String, password: String) {
		lastUsername = username
		command = "login"
		send([self.commands[command]!, UInt8(count(username))] + [UInt8](username.utf8) + [UInt8(count(password))] + [UInt8](password.utf8))
	}
	
	func createAccount(username: String, password: String) {
		command = "create"
		send([self.commands[command]!, UInt8(count(username))] + [UInt8](username.utf8) + [UInt8(count(password))] + [UInt8](password.utf8))

	}
	
	func register(name: String, password: String) {
		command = "register"
		// TODO: split password to fragments and only send fragment over
		send([self.commands[command]!, UInt8(count(name))] + [UInt8](name.utf8) + [UInt8(count(password))] + [UInt8](password.utf8))
		mainViewController.dataController.addObject(PasswordModel(url: name, children: nil))
	}
	
	func getUID() {
		command = "getUID"
		send(self.commands[command]!)
	}
	
	// MARK: - ORSSerialPortDelegate
	
	func serialPortWasOpened(serialPort: ORSSerialPort) {
		println("Port opened")
		postNotification("Connected to Meema", message: "Meema is ready for you!")
	}
	
	func serialPortWasClosed(serialPort: ORSSerialPort) {
		println("Port closed")
		postNotification("Meema disconnected", message: "Sad to see you go!")
	}
	
	// Receive data
	func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
		let count = data.length / sizeof(UInt8)
		var array = [UInt8](count: count, repeatedValue: 0)
		data.getBytes(&array, length:count * sizeof(UInt8))

		if array[0] == self.channel {
			// Received data on correct channel
			switch array[1] {
			case self.responses["getChannel"]!:
				println("Channel is now \(array[2])")
				self.channel = array[2]
				loadingViewController.displayMessage("Receiving data...")
				getAccounts()

			case self.responses["isUnlocked"]!:
				let unlocked: Bool = array[2] == 0x01
				switch command {
				case "login":
					if unlocked {
						println("logged in!")
						masterViewController.switchView()
					} else {
						println("not logged in.")
						let alert: NSAlert = NSAlert()
						alert.addButtonWithTitle("Try again")
						alert.messageText = "Invalid credentials"
						alert.informativeText = "Wrong password for selected user"
						alert.runModal()
					}
				default:
					println("\(command) received a \(unlocked) from isUnlocked")
				}
				command = ""

			case self.responses["response"]!:
				let length = Int(array[2]) * sizeof(UInt8) + Int(array[3])
				// Subtract 1 to remove delimiter from response
				let response: NSString = NSString(bytes: Array(array[4..<array.count]) as [UInt8], length: length, encoding: NSUTF8StringEncoding)!
				println("Meema response: \(response)")
				switch command {
				case "getAllAccounts":
					// Switch display to login screen
					(NSApplication.sharedApplication().delegate as! AppDelegate).showLogin()
					// Grab accounts from JSON data
					self.accounts = NSJSONSerialization.JSONObjectWithData((response).dataUsingEncoding(NSUTF8StringEncoding)!,
						options: NSJSONReadingOptions.AllowFragments,
						error: nil) as! [String]
					println("Accounts set")
					getUID()
				case "getFragments":
					// Grab accounts from JSON data
					let list = NSJSONSerialization.JSONObjectWithData((response).dataUsingEncoding(NSUTF8StringEncoding)!,
						options: NSJSONReadingOptions.AllowFragments,
					error: nil) as! [String]
					mainViewController.dataController.content = nil
					// Insert objects into sidebar
					for e in list {
						mainViewController.dataController.addObject(PasswordModel(url: e, children: nil))
					}
				case "getFragment":
					// TODO: send var response to server
					// get result and call
					let url = NSURL(string: "www.meema.co/\(UID)/\(lastUsername)/\(hash(recent as String))")
					let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, resp, error) in
						let json = NSJSONSerialization.JSONObjectWithData(data,
							options: NSJSONReadingOptions.AllowFragments,
						error: nil) as! [String: String]
//						let result = json["password"]! ^ response as String
						mainViewController.saveToClipboard("Password")
					}
					
				case "getUID":
					UID = response as String
					command = ""
				default:
					println("\(command) received a response, but it wasn't handled!")
				}
				if command != "getUID" {
					command = ""
				}

			case self.responses["approved"]!:
				switch command {
				case "getActiveAccount":
					break
				case "create":
					postNotification("Account created", message: "You may now log in")
				case "register":
					postNotification("Credentials saved", message: "Your credenitials have been stored onto your Meema")
				default:
					println("\(command) was approved")
				}
				command = ""

			case self.responses["denied"]!:
				switch command {
				default:
					println("\(command) was denied")
				}
				command = ""

			case self.responses["error"]!:
				println("Error oh no")

			default:
				println("Something dumb was received")
			}
		}
	}
	
	func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
		self.serialPort = nil
	}
	
	func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
		println("SerialPort \(serialPort) encountered an error: \(error)")
	}
	
	// MARK: - Notifications
	
	func serialPortsWereConnected(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
			println("Ports were connected: \(connectedPorts)")
			if self.serialPort == nil {
				locateDevice(true)
			}
		}
	}
	
	func serialPortsWereDisconnected(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
			println("Ports were disconnected: \(disconnectedPorts)")
			for port in disconnectedPorts {
				if port == self.serialPort {
					self.serialPort = nil
				}
			}
		}
	}
	
	func postNotification(title: String, message: String) {
		let notif = NSUserNotification()
		notif.title = title
		notif.informativeText = message
		notif.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notif)
	}
	
//	var hashCode = function(str) {
//		var hash = 0, i, chr, len;
//		if (str.length == 0) return hash;
//		for (i = 0, len = str.length; i < len; i++) {
//			chr   = str.charCodeAt(i);
//			hash  = ((hash << 5) - hash) + chr;
//			hash |= 0; // Convert to 32bit integer
//		}
//		return hash;
//	};
	func hash(input: String) -> Int {
		var result: Int = 0
		if count(input) == 0 {
			return result
		}
		for i in 0..<count(input) {
			result = (result << 5 - result) + String(input[advance(input.startIndex, i)]).toInt()!
			result |= 0
		}
		return result
	}
	
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
}