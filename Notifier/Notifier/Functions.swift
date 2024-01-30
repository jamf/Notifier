//
//  Functions.swift
//  Notifier
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa
import SystemConfiguration

// Changes the notifier apps icons, and if logged in restarts notificatoin center
func changeIcons(brandingImage: String, loggedInUser: String, parsedResult: ArgParser) {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - brandingImage: \(brandingImage)")
    }
    // Get the details of the file at brandingImage
    let imageData = getImageDetails(brandingImage: brandingImage, parsedResult: parsedResult)
    // Create an array to log progress for icon changes
    var brandingStatus = [Bool]()
    // For each application in brandingArray
    for notifierApp in [GlobalVariables.mainAppPath, GlobalVariables.alertAppPath,
                        GlobalVariables.bannerAppPath] {
        // Returns bool for ther  the branding status for each app
        brandingStatus.append(updateIcon(brandingImage: brandingImage, imageData: imageData!,
                                         objectPath: notifierApp, parsedResult: parsedResult))
    }
    // If brandingStatus just contains true
    if !brandingStatus.contains(false) {
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - Successfully rebranded Notifier")
        }
        // Check to see if at the loginwindow before looking to notify
        if loggedInUser != "" {
            // If we're logged in, look to restart apps for branding changes
            restartNotificationCenter(loggedInUser: loggedInUser, parsedResult: parsedResult)
            // Exit
            exit(0)
        }
    // If there is an issue
    } else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Failed to rebrand Notifier...",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
}

// Create JSON from ParsedArguments
func createJSON(parsedArguments: ParsedArguments, parsedResult: ArgParser) -> Data {
    // Var declaration
    var parsedArgumentsJSON = Data()
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - parsedArguments: \(parsedArguments)")
    }
    // Try to convert ParsedArguments to JSON
    do {
        // Turn parsedArguments into JSON
        parsedArgumentsJSON = try JSONEncoder().encode(parsedArguments)
    // If encoding into JSON fails
    } catch {
        // Raise an error
        postError(errorMessage: error.localizedDescription, functionName: #function.components(separatedBy: "(")[0],
                  parsedResult: parsedResult)
    }
    if parsedResult.verbose {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - parsedArgumentsJSON: \
              \(String(data: parsedArgumentsJSON, encoding: .utf8)!)
              """)
    }
    // Return the parsedArgumentsJSON
    return parsedArgumentsJSON
}

// Gets the modification date and time of the file and return as epoch
func getImageDetails(brandingImage: String, parsedResult: ArgParser) -> (NSImage?) {
    // Var declaration
    var imageData: NSImage?
    // If the file exists
    if FileManager.default.fileExists(atPath: brandingImage) {
        // Create imageData from the file passed to brandingImage
        imageData = NSImage(contentsOfFile: brandingImage)
        // If imageData isValid is nil, then brandingImage is not a valid icon
        if (imageData?.isValid) == nil {
            // Post error to stdout and NSLog if verbose mode is enabled
            postError(errorMessage: "ERROR: \(brandingImage) is not a valid image...",
                      functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
            // Exit
            exit(1)
        }
        // Return the image data
        return imageData
    // If the file doesn't exist
    } else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Cannot locate: \(brandingImage)....",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
}

// Checks that notification center is running, and exit if it's not
func isNotificationCenterRunning(parsedResult: ArgParser) {
    // Exit if notificaiton center isn't running for the user
    guard !NSRunningApplication.runningApplications(withBundleIdentifier:
                                                        "com.apple.notificationcenterui").isEmpty else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Notification Center is not running...",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - Notification Center is running...")
    }
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

// Post error to both NSLog and stdout
func postError(errorMessage: String, functionName: String, parsedResult: ArgParser) {
    // Print error
    print(errorMessage)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(functionName) - \(errorMessage)")
    }
}

// Passes parsedArgumentsJSON to the relevant app, exiting afterwards
func passToApp(loggedInUser: String, notifierPath: String, parsedArgumentsJSON: Data, parsedResult: ArgParser) {
    // Var declaration
    var taskArguments = [String]()
    var taskPath = String()
    // If the user running the app isn't the logged in user (root for example)
    if NSUserName() != loggedInUser {
        // Set taskPath to su as we need to use that to run as the user
        taskPath = "/usr/bin/su"
        // Create taskArguments
        taskArguments = [
            "-l", "\(loggedInUser)", "-c", "\'\(notifierPath)\' \(parsedArgumentsJSON.base64EncodedString())"
        ]
    // If the person running the app is the logged in user
    } else {
        // Set taskPath to the notifying apps path
        taskPath = notifierPath
        // Set taskArguments to the base64 of parsedArgumentsJSON
        taskArguments = [parsedArgumentsJSON.base64EncodedString()]
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskPath: \(taskPath), taskArguments: \(taskArguments)")
    }
    // Launch the wanted notification app as the user
    (_, _) = runTask(parsedResult: parsedResult, taskArguments: taskArguments, taskPath: taskPath)
    // Exit
    exit(0)
}

// Restarts notification center
func restartNotificationCenter(loggedInUser: String, parsedResult: ArgParser) {
    // Var declaration
    var taskArguments = [String]()
    var taskPath = String()
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - Restarting NotificationCenter for user: \(loggedInUser)...
              """)
    }
    // If the user running the app (NSUserName) isn't the logged in user
    if NSUserName() != loggedInUser {
        // Path for the task
        taskPath = "/usr/bin/su"
        // Arguments for the task
        taskArguments = ["-l", loggedInUser, "-c", "/usr/bin/killall -u \(loggedInUser) NotificationCenter"]
    // If the person running the app is the logged in user
    } else {
        // Path for the task
        taskPath = "/usr/bin/killall"
        // Arguments for the task
        taskArguments = ["NotificationCenter"]
    }
    // Run the task, ignoring returned exit status
    (_, _) = runTask(parsedResult: parsedResult, taskArguments: taskArguments, taskPath: taskPath)
}

// Make sure we're running as root, exit if not
func rootCheck(parsedResult: ArgParser, passedArg: String) {
    // If we're not root
    if NSUserName() != "root" {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: The argument: \(passedArg). Requires root privileges, exiting...",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
}

// Runs the passed task
func runTask(parsedResult: ArgParser, taskArguments: [String], taskPath: String) -> (String, Bool) {
    // Var declaration
    var successfulExit =  false
    // If verbose mode is enabled
    if parsedResult.verbose {
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

// Attempts to update the app passed to objectPath's icon
func updateIcon(brandingImage: String, imageData: NSImage, objectPath: String, parsedResult: ArgParser) -> Bool {
    // Get the items at the root of the .app bundle
    do {
        // Get the list of items in the apps bundle
        let appRootItems = try? FileManager.default.contentsOfDirectory(atPath: objectPath)
        // For each item found, wherethe item starts with Icon\r
        for appRootItem in appRootItems! where appRootItem.hasSuffix("Icon\r") {
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Progress log
                NSLog("\(#function.components(separatedBy: "(")[0]) - Deleting: \(objectPath + "/" + appRootItem)...")
            }
            // Delete the file
            try? FileManager.default.removeItem(atPath: objectPath + "/" + appRootItem)
            // Sleep for 1 second
            sleep(1)
        }
    }
    // Set the icon, returns bool
    let rebrandStatus = NSWorkspace.shared.setIcon(imageData, forFile: objectPath,
                                                   options: NSWorkspace.IconCreationOptions(rawValue: 0))
    // If we have succesfully branded the item at objectPath
    if rebrandStatus {
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - Successfully updated icon for \(objectPath), \
                  with icon: \(brandingImage).
                  """)
        }
    } else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Failed to update icon for \(objectPath), with icon: \(brandingImage).",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
    }
    // Return boolean
    return rebrandStatus
}
