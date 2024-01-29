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
func openItem(userInfo: [AnyHashable: Any], userInfoKey: String) {
    // Var declaration
    var actionString = String()
    var regexDict = [String: String]()
    var taskArgumentsArray = [String]()
    var taskPath = String()
    // If we have an action
    if userInfo[userInfoKey] != nil {
        // Set action string to the action
        actionString = userInfo[userInfoKey] as! String
    }
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - opening: \(actionString)")
    }
    // Regex pattern to look for items in single or double quotes
    let regexPattern = try! NSRegularExpression(pattern: "\'(.*?)\'|\"(.*?)\"")
    // Apply regex, and return matches
    let regexMatches = regexPattern.matches(in: actionString, options: [],
                                             range: NSRange(location: 0, length: actionString.utf16.count))
    // If we have a first match
    if let firstMatch = regexMatches.first {
        // Set the range to the 1st match
        let someRange = firstMatch.range(at: 1)
        // Create a Range object
        if let swiftRange = Range(someRange, in: actionString) {
            // Add to regexDict and %20 escape spaces
            regexDict[actionString[swiftRange].description] =
            actionString[swiftRange].description.replacingOccurrences(of: " ", with: "%20")
        }
    }
    // If we have items in regexDict
    if !regexDict.isEmpty {
        // For each key value pair we have in regexDict
        for (matchedKey, matchedValue) in regexDict {
            // Replace the occurences of matchedKey with matchedValue
            actionString = actionString.replacingOccurrences(of: matchedKey,
                                                                                          with: matchedValue)
        }
        // Set taskArgumentsArray to the amended string
        taskArgumentsArray = Array(actionString.components(separatedBy: " "))
        // Iterate over the array elements which contain %20
        for arrayElement in taskArgumentsArray where arrayElement.contains("%20") {
            // Get the index of the element
            let arrayIndex = taskArgumentsArray.firstIndex(of: arrayElement)
            // Update the element in the array, removing %20, single and double quotes
            taskArgumentsArray[arrayIndex!] = arrayElement.replacingOccurrences(of: "%20", with: " ")
                .replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: "\"", with: "")
        }
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskArgumentsArray1 - \(taskArgumentsArray)")
    // If regexDict is empty
    } else {
        // Set taskArgumentsArray to the passed action
        taskArgumentsArray = Array(actionString.components(separatedBy: " "))
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskArgumentsArray2 - \(taskArgumentsArray)")
    }
    // If we only have a single task
    if taskArgumentsArray.count == 1 {
        // Set the tasks path to open, this is to mimic pre-3.0 behaviour
        taskPath = "/usr/bin/open"
    // If we have more than one task
    } else {
        // Set the tasks path to the 1st item within the taskArgumentsArray
        taskPath = taskArgumentsArray[0]
        // Remove the above from the taskArgumentsArray
        taskArgumentsArray.remove(at: 0)
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskArgumentsArray3 - \(taskArgumentsArray)")
    }
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskPath - \(taskPath)")
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskArgumentsArray - \(taskArgumentsArray)")
    }
    // Run the task, returning boolean
    let taskStatus = runTask(taskPath: taskPath, taskArguments: taskArgumentsArray, userInfo: userInfo)
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // If task ran successfully
        if taskStatus {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - \
                  opened \(String(describing: userInfo[userInfoKey]))
                  """)
        // If tasks exits with anything other than 0
        } else {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - failed \
                  to open \(String(describing: userInfo[userInfoKey]))
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
