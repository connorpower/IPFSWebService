//
//  AppDelegate.swift
//  Example
//
//  Created by Connor Power on 02.11.17.
//  Copyright © 2017 Connor Power. All rights reserved.
//

import Cocoa
import IPFSWebService
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let fileURL = Bundle.main.url(forResource: "The Cathedral and the Bazaar", withExtension: ".pdf")!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        testUpload(of: fileURL)
    }

    private func testUpload(of file: URL) {
        print("Adding file...\n")

        DefaultAPI.add(file: file) { (response, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let response = response {
                print("File added.\n  Name: \(response.name!)\n  Hash: \(response.hash!)\n  Size: \(response.size!)\n")
                self.testPublish(of: response.hash!)
            }
        }
    }

    private func testPublish(of hash: String) {
        print("Publishing file...\n")

        DefaultAPI.publish(arg: hash) { (response, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let response = response {
                print("File published.\n  Name: \(response.name!)\n  Value: \(response.value!)\n")
                self.testResolve(of: response.name!)
            }
        }
    }

    private func testResolve(of name: String) {
        print("Resolving name...\n")

        DefaultAPI.resolve(arg: name) { (response, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let response = response {
                print("Name resolved.\n  Path: \(response.path!)\n")
                self.testGet(of: response.path!)
            }
        }
    }

    private func testGet(of path: String) {
        print("Getting file...\n")

        DefaultAPI.callGet(arg: path) { (data, error) in
            if let error = error {
                fatalError("\(error)")
            } else if let data = data {
                print("File retrieved.\n  Size: \(data.count)\n")
                self.compare(data: data, withLocalFileAt: self.fileURL)
            }
        }
    }

    private func compare(data: Data, withLocalFileAt url: URL) {
        let localData = try! Data(contentsOf: url)

        let localPDF = PDFDocument(data: localData)!
        guard let remotePDF = PDFDocument(data: data) else {
            print("Could not create PDF from retrieved file. ❌\n")
            return
        }

        if localPDF.pageCount == remotePDF.pageCount {
            print("File compared to local counterpart.\n  Is PDF with same number of pages: ✅\n")
        } else {
            print("File compared to local counterpart.\n  Is PDF with same number of pages: ❌\n")
        }
    }

}
