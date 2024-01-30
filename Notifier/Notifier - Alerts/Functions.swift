//
//  Functions.swift
//  Notifier - Alerts
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
        postError(errorMessage: "ERROR: Failed to decode: \(base64String) from base64.",
                  functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
        // Exit with an exit code of 1, to exit the run
        exit(1)
    }
    // Return's a string decoded from base64
    return decodedString
}

// Converts pass string into base64
func base64String(stringContent: String) -> String {
    // Return base64 encoded string
    return stringContent.data(using: String.Encoding.utf8)!.base64EncodedString()
}

// Decodes the passed base64 JSON string
func decodeJSON(parsedArgumentsJSON: String) -> ParsedArguments {
    // Decode from base64, exiting if fails
    let base64Decoded = base64Decode(base64String: parsedArgumentsJSON)
    // Try to convert ParsedArguments to ParsedArguments
    do {
        // Turn parsedArguments into JSON
        let parsedArguments = try JSONDecoder().decode(ParsedArguments.self, from: Data(base64Decoded.utf8))
        // If verbose mode is set
        if parsedArguments.verboseMode != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - parsedArguments: \(parsedArguments)")
        }
        // Return parsedArguments
        return parsedArguments
    // If encoding into JSON fails
    } catch {
        // Post an error to stdout and console
        postError(errorMessage: "ERROR: Failed to decode: \(parsedArgumentsJSON) from JSON.",
                  functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
        // Exit with an exit code of 1, to exit the run
        exit(1)
    }
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
                NSLog("\(#function.components(separatedBy: "(")[0]) - logout - ERROR: \(String(describing: error!))")
            }
        }
    }
}

// Checks that notification center is running, and exit if it's not
func isNotificationCenterRunning(verboseMode: String) {
    // Exit if notificaiton center isn't running for the user
    guard !NSRunningApplication.runningApplications(withBundleIdentifier:
                                                        "com.apple.notificationcenterui").isEmpty else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Notification Center is not running...",
                  functionName: #function.components(separatedBy: "(")[0],
                  verboseMode: verboseMode)
        // Exit
        exit(1)
    }
    // If verbose mode is enabled
    if verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - Notification Center is running...")
    }
}

// Post error to both NSLog and stdout
func postError(errorMessage: String, functionName: String, verboseMode: String) {
    // Print error
    print(errorMessage)
    // If verbose mode is enabled
    if verboseMode != "" {
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
