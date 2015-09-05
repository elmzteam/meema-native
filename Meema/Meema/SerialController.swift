//
//  SerialController.swift
//  Meema
//
//  Created by Ellis Tsung on 9/4/15.
//  Copyright (c) 2015 ELMZ. All rights reserved.
//

import Cocoa
import ORSSerial

class SerialController: NSObject, ORSSerialPortDelegate {
	let manager = ORSSerialPortManager.sharedSerialPortManager()
	let commands: [String: UInt8] = ["ping": 0x01, "isUnlocked": 0x02, "getUID": 0x03, "getActiveAccount": 0x04, "getAllAccounts": 0x05, "authenticate": 0x06, "getFragment": 0x07, "create": 0x10, "register": 0x11]
	let responses: [String: UInt8] = ["getChannel": 0xFF, "isUnlocked": 0xFE, "response": 0xF2, "approved": 0xF1, "denied": 0xF0]
	var serialPort: ORSSerialPort? {
		didSet {
			oldValue?.close()
			oldValue?.delegate = nil
			serialPort?.delegate = self
		}
	}
	var channel: UInt8 = 0x00
	
	func locateDevice() {
		var ports: [ORSSerialPort] = manager.availablePorts as! [ORSSerialPort]
		for port in ports {
			if port.name.rangeOfString("usbmodem") != nil {
				port.baudRate = 9600
				self.serialPort = port
				println("Found and set port")
				connect()
				break
			}
		}
		if self.serialPort == nil {
			postNotification("Meema not found!", message: "Please connect your Meema and try again.")
		}
	}
	
	func connect() {
		if let port = self.serialPort {
			if (!port.open) {
				port.open()
				println("Port opened")
				postNotification("Connected to Meemo", message: "Hooray!")
			}
		} else {
			println("No port selected!")
		}
	}
	
	func disconnect() {
		if let port = self.serialPort {
			if (port.open) {
				println("Port closed")
				port.close()
				self.channel = 0x00
				postNotification("Meemo disconnected", message: "Hooray!")
			}
		} else {
			println("No port selected!")
		}
	}
	
	func send(message: [UInt8]) {
		self.serialPort?.sendData(NSData(bytes: message, length: message.count))
	}
	
	// MARK: - ORSSerialPortDelegate
	
	func serialPortWasOpened(serialPort: ORSSerialPort) {
	}
	
	func serialPortWasClosed(serialPort: ORSSerialPort) {
	}
	
	func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
		// the number of elements:
		let count = data.length / sizeof(UInt8)
		
		// create array of appropriate length:
		var array = [UInt8](count: count, repeatedValue: 0)
		
		// copy bytes into array
		data.getBytes(&array, length:count * sizeof(UInt8))

		if array[0] == self.channel {
			// Received data on correct channel
			switch array[1] {
			case self.responses["getChannel"]!:
				self.channel = array[2]
			case self.responses["isUnlocked"]!:
				break
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

	func postNotification(title: String, message: String) {
		let notif = NSUserNotification()
		notif.title = title
		notif.informativeText = message
		notif.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notif)
	}
}