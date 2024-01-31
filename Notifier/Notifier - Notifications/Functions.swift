//
//  Functions.swift
//  Notifier - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa

// Decodes base64String from base64, exiting if fails
func base64Decode(base64String: String) -> String {
    // Create a data object from the string, and decode to string
    guard let base64EncodedData = base64String.data(using: .utf8),
        let encodedData = Data(base64Encoded: base64EncodedData),
        let decodedString = String(data: encodedData, encoding: .utf8)
    else {
        // Post an error to stdout and console
        postError(errorMessage: "Failed to decode: \(base64String) from base64.",
                  functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
        // Exit
        exit(1)
    }
    // Return's a string decoded from base64
    return decodedString
}

// Decodes the passed JSON
func decodeJSON(passedJSON: String) -> (MessageContent, String, RootElements) {
    // Var declaration
    var messageContent = MessageContent()
    var passedBase64 = String()
    var rootElements = RootElements()
    // Try to convert RootElements to JSON from base64
    do {
        // Decode from base64, exiting if fails
        let tempDecoded = base64Decode(base64String: passedJSON)
        // Turn parsedArguments into JSON
        rootElements = try JSONDecoder().decode(RootElements.self, from: Data(tempDecoded.utf8))
        // If verbose mode is set
        if rootElements.verboseMode != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - \(rootElements)")
        }
        // If encoding into JSON fails
    } catch {
        // Post an error to stdout and console
        postError(errorMessage: "Failed to decode: \(rootElements) from JSON.",
                  functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
        // Exit
        exit(1)
    }
    // If we have messageContent
    if rootElements.messageContent != nil {
        // Try to convert RootElements to JSON from base64
        do {
            // Set to the base64 passed to the app
            passedBase64 = rootElements.messageContent ?? ""
            // Decode from base64, exiting if fails
            let tempDecoded = base64Decode(base64String: passedBase64)
            // Turn messageContent into JSON
            messageContent = try JSONDecoder().decode(MessageContent.self, from: Data(tempDecoded.utf8))
            // If verbose mode is set
            if rootElements.verboseMode != nil {
                // Progress log
                NSLog("\(#function.components(separatedBy: "(")[0]) - \(messageContent)")
            }
            // If encoding into JSON fails
        } catch {
            // Post an error to stdout and console
            postError(errorMessage: "Failed to decode: \(messageContent) from JSON.",
                      functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
            // Exit
            exit(1)
        }
    }
    // Return messageContent and parsedArguments
    return (messageContent, passedBase64, rootElements)
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
            // Post an error to stdout and console
            postError(errorMessage: "\(error!)", functionName: #function.components(separatedBy: "(")[0],
                      verboseMode: "enabled")
            // Exit
            exit(1)
        }
    }
}

// Checks that notification center is running, and exit if it's not
func isNotificationCenterRunning(verboseMode: String) {
    // Exit if notificaiton center isn't running for the user
    guard !NSRunningApplication.runningApplications(withBundleIdentifier:
                                                        "com.apple.notificationcenterui").isEmpty else {
        // Post warning
        postWarning(warningMessage: "Notification Center is not running...",
                    functionName: #function.components(separatedBy: "(")[0], verboseMode: verboseMode)
        // Exit
        exit(0)
    }
    // If verbose mode is enabled
    if verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - Notification Center is running...")
    }
}

// Post error to both NSLog and stdout
func postError(errorMessage: String, functionName: String, verboseMode: String) {
    // Var declaration
    let fullMessage = "ERROR: \(functionName) - \(errorMessage)"
    // Print error
    print(fullMessage)
    // If verbose mode is enabled
    if verboseMode != "" {
        // Progress log
        NSLog(fullMessage)
    }
}

// Post warning to both NSLog and stdout
func postWarning(warningMessage: String, functionName: String, verboseMode: String) {
    // Var declaration
    let fullMessage = "WARNING: \(functionName) - \(warningMessage)"
    // Print error
    print(fullMessage)
    // If verbose mode is enabled
    if verboseMode != "" {
        // Progress log
        NSLog(fullMessage)
    }
}

// Runs the passed task
func runTask(taskPath: String, taskArguments: [String], userInfo: [AnyHashable: Any]) -> (String, Bool) {
    // Var declaration
    var successfulExit =  false
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
    // Create pipe
    let outPipe = Pipe()
    // Set pipe to be used for stdout
    task.standardOutput = outPipe
    // Set pipe to be used for stderr
    task.standardError = outPipe
    // Run the task
    try? task.run()
    // Wait until task exits
    task.waitUntilExit()
    // Get output
    let outdata = outPipe.fileHandleForReading.readDataToEndOfFile()
    // Convert to string
    let cmdOut = String(data: outdata, encoding: String.Encoding.utf8) ?? ""
    // Return boolean
    if task.terminationStatus == 0 {
        // Return true
        successfulExit = true
    // If tasks exits with anything other than 0
    } else {
        // Return false
        successfulExit =  false
    }
    // Return cmdOut text and if the task exited successfully or not
    return (cmdOut, successfulExit)
}
