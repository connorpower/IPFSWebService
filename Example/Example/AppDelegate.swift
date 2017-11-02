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

    let file = Bundle.main.url(forResource: "The Cathedral and the Bazaar", withExtension: ".pdf")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        testUpload()
    }

    private func testUpload() {
        DefaultAPI.add(file: file, recursive: false) { (response, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let response = response {
                print("File added.\n  Name: \(response.name!)\n  hash: \(response.hash!)\n  size: \(response.size!)")
            }
        }
    }

}
