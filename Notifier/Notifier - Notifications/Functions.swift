//
//  Functions.swift
//  Notifier - Notifications
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
func gracefulLogout(userInfo: [AnyHashable: Any]) {
    // Var declaration
    var error: NSDictionary?
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - logout prompting")
    }
    // AppleScript command
    let appleScriptCommand = "tell application \"loginwindow\" to «event aevtlogo»"
    // Create an NSAppleScript object from the prior command
    if let scriptObject = NSAppleScript(source: appleScriptCommand) {
        // If we receive output from the prior command
        if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // Progress log
                NSLog("\(#function.components(separatedBy: "(")[0]) - logout - \(outputString)")
            }
        // If we have an error from the prior command
        } else if error != nil {
            // Print the error
            print("ERROR: ", error!)
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // Progress log
                NSLog("""
                      \(#function.components(separatedBy: "(")[0]) - logout - \
                      ERROR: \(String(describing: error!))
                      """)
            }
        }
    }
}

// Checks that notification center is running, and exit if it's not
func isNotificationCenterRunning(parsedResult: ArgParser) {
    // Exit if notificaiton center isn't running for the user
    guard !NSRunningApplication.runningApplications(withBundleIdentifier:
                                                        "com.apple.notificationcenterui").isEmpty else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Notification Center is not running...",
                  functionName: #function.components(separatedBy: "(")[0], verboseMode: parsedResult.verbose)
        // Exit
        exit(1)
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - Notification Center is running...")
    }
}

// Open the item passed, NSWorkspace was used but sometimes threw "app is not open errors"
func openItem(userInfo: [AnyHashable: Any]) {
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - opening
              \(String(describing: userInfo["messageAction"]))
              """)
    }
    // Path for the task
    let taskPath = "/usr/bin/open"
    // Arguments for the task
    let taskArgumentsArray = [(String(describing: userInfo["messageAction"]))]
    // Run the task, returning boolean
    let taskStatus = runTask(taskPath: taskPath, taskArguments: taskArgumentsArray, userInfo: userInfo)
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // If task ran successfully
        if taskStatus {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - \
                  opened \(String(describing: userInfo["messageAction"]))
                  """)
        // If tasks exits with anything other than 0
        } else {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - failed \
                  to open \(String(describing: userInfo["messageAction"]))
                  """)
        }
    }
}

// Post error to both NSLog and stdout
func postError(errorMessage: String, functionName: String, verboseMode: Bool) {
    // Print error
    print(errorMessage)
    // If verbose mode is enabled
    if verboseMode {
        // Progress log
        NSLog("\(functionName) - \(errorMessage)")
    }
}

// Runs the passed task
func runTask(taskPath: String, taskArguments: [String], userInfo: [AnyHashable: Any]) -> Bool {
    // If verbose mode is enabled
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskPath: \(taskPath), taskArguments: \(taskArguments)")
    }
    // Create Task
    let task = Process()
    // Set task to call the binary
    task.executableURL = URL(fileURLWithPath: taskPath)
    // Set task arguments
    task.arguments = taskArguments
    // Run the task
    try? task.run()
    // Wait until task exits
    task.waitUntilExit()
    // Return boolean
    if task.terminationStatus == 0 {
        // Return that the task ran sucessfully
        return true
    // If tasks exits with anything other than 0
    } else {
        // Return that the task failed
        return true
    }
}
