//
//  AppDelegate.swift
//  Example
//
//  Created by Connor Power on 02.11.17.
//  Copyright © 2017 Connor Power. All rights reserved.
//

import Cocoa
import IPFSWebService

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let file = URL(fileURLWithPath: "/Users/connorpower/Desktop/The Cathedral and the Bazaar.pdf")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        testUpload()
    }

    private func testUpload() {
        DefaultAPI.add(file: file, recursive: false) { (response, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let response = response {
                print("File added.\n  Name: \(response.Name!)\n  hash: \(response.Hash!)\n  size: \(response.Size!)")
            }
        }
    }

}
