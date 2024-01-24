//
//  Functions.swift
//  Notifier
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa
import SystemConfiguration

// Appends --message to the passed array
func appendMessage(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - message")
    }
    // Append to notifierArgsArray
    tempArray.append("--message")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.message)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --messageaction to the passed array
func appendMessageaction(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - messageaction")
    }
    // Append to notifierArgsArray
    tempArray.append("--messageaction")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messageaction)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --messagebutton to the passed array
func appendMessagebutton(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - messagebutton")
    }
    // Append to notifierArgsArray
    tempArray.append("--messagebutton")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messagebutton)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --messagebuttonaction to the passed array
func appendMessagebuttonaction(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - messagebuttonaction")
    }
    // Append to notifierArgsArray
    tempArray.append("--messagebuttonaction")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messagebuttonaction)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --remove all to the passed array
func appendRemoveAll(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - remove all")
    }
    // Append to notifierArgsArray
    tempArray.append("--remove")
    // Append to notifierArgsArray
    tempArray.append("all")
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --remove prior to the passed array
func appendRemovePrior(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - remove prior")
    }
    // Append to notifierArgsArray
    tempArray.append("--remove")
    // Append to notifierArgsArray
    tempArray.append("prior")
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --sound to the passed array
func appendSound(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - sound")
    }
    // Append to notifierArgsArray
    tempArray.append("--sound")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.sound)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --subtitle to the passed array
func appendSubtitle(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - subtitle")
    }
    // Append to notifierArgsArray
        tempArray.append("--subtitle")
    // Append to notifierArgsArray
        tempArray.append(parsedResult.subtitle)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Appends --title to the passed array
func appendTitle(notifierArgsArray: [String], parsedResult: ArgParser) -> [String] {
    // Var declaration
    var tempArray = notifierArgsArray
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - title")
    }
    // Append to notifierArgsArray
        tempArray.append("--title")
    // Append to notifierArgsArray
        tempArray.append(parsedResult.title)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: notifier - notifierArgsArray - \(notifierArgsArray)")
    }
    // Return the updated array
    return tempArray
}

// Build the taskArgumentsArray
func buildTaskArgumentsArray(loggedInUser: String, notifierArgsArray: [String], notifierPath: String) -> [String] {
    // Create suArgsString var
    var suArgsString = "'" + notifierPath + "'"
    // Create suArgsArray
    var taskArgumentsArray = [String]()
    // For each parsedArg in the notifierArgsArray
    for parsedArg in notifierArgsArray {
        // If the passedArg is prefixed with --
        if parsedArg.hasPrefix("--") {
            // Append to string, prepending with a space
            suArgsString += " " + parsedArg
        // If not prefixed --
        } else {
            // Add to string, with different formatting
            suArgsString += " '" + (parsedArg) + "'"
        }
    }
    // Create ann array of the su args
    taskArgumentsArray = [suArgsString]
    // Insert -c at index 0
    taskArgumentsArray.insert("-c", at: 0)
    // Insert the loggedInUsers username at index 0
    taskArgumentsArray.insert(loggedInUser, at: 0)
    // Insert -l at index 0
    taskArgumentsArray.insert("-l", at: 0)
    // Return the populated array
    return taskArgumentsArray
}

// Returns username if a user is logged in, and "" if at the loginwindow
func loggedInUser() -> String {
    // Get the name of the logged in user
    let loggedInUser = SCDynamicStoreCopyConsoleUser(nil, nil, nil)! as String
    // If no-one or loginwindow is returned
    if loggedInUser == "loginwindow" || loggedInUser == "" {
        return ""
    // Else if we have someone logged in
    } else {
        // Return their username
        return loggedInUser
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

// Runs the passed task
func runTask(taskPath: String, taskArguments: [String]) -> (String, Bool) {
    // Var declaration
    var successfulExit = false
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
