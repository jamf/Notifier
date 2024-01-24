//
//  Functions.swift
//  Notifier - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa

// Converts pass string into base64
func base64String(stringContent: String) -> String {
    // Return base64 encoded string
    return stringContent.data(using: String.Encoding.utf8)!.base64EncodedString()
}

// Logout user, prompting to save
func gracefullLogout(verboseMode: Bool) {
    // Var declaration
    var error: NSDictionary?
    // If verbose mode is set
    if verboseMode {
        // Progress log
        NSLog("Notifier Log: alert - logout prompting")
    }
    // AppleScript command
    let appleScriptCommand = "tell application \"loginwindow\" to «event aevtlogo»"
    // Create an NSAppleScript object from the prior command
    if let scriptObject = NSAppleScript(source: appleScriptCommand) {
        // If we receive output from the prior command
        if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
            // Print the output
            print(outputString)
            // If verbose mode is set
            if verboseMode {
                // Progress log
                NSLog("Notifier Log: alert - logout - \(outputString)")
            }
        // If we have an error from the prior command
        } else if error != nil {
            // Print the error
            print("ERROR: ", error!)
            // If verbose mode is set
            if verboseMode {
                // Progress log
                NSLog("Notifier Log: alert - logout - ERROR: \(String(describing: error!))")
            }
        }
    }
}

// Checks that notification center is running, and exit if it's not
func isNotificationCenterRunning() {
    // Exit if notificaiton center isn't running for the user
    guard !NSRunningApplication.runningApplications(withBundleIdentifier:
                                                        "com.apple.notificationcenterui").isEmpty else {
        // Print error
        print("ERROR: Notification Center is not running...")
        // Exit
        exit(1)
    }
}

// Open the item passed, NSWorkspace was used but sometimes threw "app is not open errors"
func openItem(globalOpenItem: [String]?, verboseMode: Bool) {
    // If verbose mode is set
    if verboseMode {
        // Progress log
        NSLog("Notifier Log: alert - opening \(String(describing: globalOpenItem))")
    }
    // Create Task
    let task = Process()
    // Set task to call the binary
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    // Set task arguments
    task.arguments = globalOpenItem
    // Set stdout pipe
    let outputPipe = Pipe()
    // Set stderr pipe
    let errorPipe = Pipe()
    // Create stdout pipe
    task.standardOutput = outputPipe
    // Create stderr pipe
    task.standardError = errorPipe
    // Run the task
    try? task.run()
    // Wait until task exits
    task.waitUntilExit()
    // If verbose mode is set
    if verboseMode {
        // Return boolean
        if task.terminationStatus == 0 {
            // Progress log
            NSLog("Notifier Log: alert - opened \(String(describing: globalOpenItem))")
        // If tasks exits with anything other than 0
        } else {
            // Progress log
            NSLog("Notifier Log: alert - failed to open \(String(describing: globalOpenItem))")
        }
    }
}
