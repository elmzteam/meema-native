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
	let commands: [String: UInt8] = ["ping": 0x01, "isUnlocked": 0x02, "getUID": 0x03, "getActiveAccount": 0x04, "getAllAccounts": 0x05, "login": 0x06, "getFragment": 0x07, "create": 0x10, "register": 0x11]
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
	var accounts: [String] = [] {
		didSet {
			masterViewController.accounts = self.accounts
		}
	}
	var activeAccount: String = ""
	
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
					delay(5) {
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
			postNotification("Meema not found!", message: "Please connect your Meema and try again.")
		}
	}
	
	func connect() {
		if let port = self.serialPort {
			if (!port.open) {
				port.open()
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
		println([channel] + message)
		self.serialPort?.sendData(NSData(bytes: [channel] + message, length: message.count + 1))
	}
	
	func getAccounts() {
		command = "getAllAccounts"
		send(self.commands[command]!)
	}
	
	func getActiveAccount() {
		command = "getActiveAccount"
		send(self.commands[command]!)
	}
	
	func login(username: String, password: String) {
		command = "login"
		send([self.commands[command]!, UInt8(count(username))] + [UInt8](username.utf8) + [UInt8(count(password))] + [UInt8](password.utf8))
	}
	
	// MARK: - ORSSerialPortDelegate
	
	func serialPortWasOpened(serialPort: ORSSerialPort) {
		println("Port opened")
		postNotification("Connected to Meemo", message: "Hooray!")
	}
	
	func serialPortWasClosed(serialPort: ORSSerialPort) {
		println("Port closed")
		postNotification("Meemo disconnected", message: "Hooray!")
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
				getAccounts()

			case self.responses["isUnlocked"]!:
				let unlocked: Bool = array[2] == 0x01
				switch command {
				case "login":
					if unlocked {
						println("logged in!")
					} else {
						println("not logged in.")
						let alert: NSAlert = NSAlert()
						alert.addButtonWithTitle("Try again")
						alert.messageText = "Invalid credentials"
						alert.informativeText = "Wrong password for selected user"
						alert.runModal()
					}
				default:
					break
				}

			case self.responses["response"]!:
				let length = Int(array[2]) * sizeof(UInt8) + Int(array[3])
				// Subtract 1 to remove delimiter from response
				let response: NSString = NSString(bytes: Array(array[4..<array.count]) as [UInt8], length: length, encoding: NSUTF8StringEncoding)!
				println(response)
				switch command {
				case "getAllAccounts":
					println("adsflkajsdf")
					self.accounts = NSJSONSerialization.JSONObjectWithData((response).dataUsingEncoding(NSUTF8StringEncoding)!,
						options: NSJSONReadingOptions.AllowFragments,
						error: nil) as! [String]
					println(self.accounts)
				default:
					println("Bad command")
				}
				command = ""

			case self.responses["approved"]!:
				switch command {
				case "getActiveAccount":
					break
				case "register":
					break
				default:
					break
				}
				command = ""

			case self.responses["denied"]!:
				switch command {
				default:
					break
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
					postNotification("Meemo disconnected!", message: "Check connection")
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
	
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
}