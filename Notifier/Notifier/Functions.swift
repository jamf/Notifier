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
        NSLog("\(#function.components(separatedBy: "(")[0]) - message: \(parsedResult.message)")
    }
    // Append to notifierArgsArray
    tempArray.append("--message")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.message)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageaction: \(parsedResult.messageaction)")
    }
    // Append to notifierArgsArray
    tempArray.append("--messageaction")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messageaction)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - messagebutton: \(parsedResult.messagebutton)")
    }
    // Append to notifierArgsArray
    tempArray.append("--messagebutton")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messagebutton)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - messagebuttonaction: \(parsedResult.messagebuttonaction)")
    }
    // Append to notifierArgsArray
    tempArray.append("--messagebuttonaction")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.messagebuttonaction)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove all - \(parsedResult.type)")
    }
    // Append to notifierArgsArray
    tempArray.append("--remove")
    // Append to notifierArgsArray
    tempArray.append("all")
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior")
    }
    // Append to notifierArgsArray
    tempArray.append("--remove")
    // Append to notifierArgsArray
    tempArray.append("prior")
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - sound: \(parsedResult.sound)")
    }
    // Append to notifierArgsArray
    tempArray.append("--sound")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.sound)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - subtitle: \(parsedResult.subtitle)")
    }
    // Append to notifierArgsArray
    tempArray.append("--subtitle")
    // Append to notifierArgsArray
    tempArray.append(parsedResult.subtitle)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
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
        NSLog("\(#function.components(separatedBy: "(")[0]) - title: \(parsedResult.title)")
    }
    // Append to notifierArgsArray
        tempArray.append("--title")
    // Append to notifierArgsArray
        tempArray.append(parsedResult.title)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notifierArgsArray: \(tempArray)")
    }
    // Return the updated array
    return tempArray
}

// Build the taskArgumentsArray
func buildTaskArguments(loggedInUser: String, notifierArgsArray: [String], notifierPath: String,
                        parsedResult: ArgParser) -> ([String], String) {
    // Var declaration
    var taskArgumentsArray = [String]()
    var taskPath = String()
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - buildTaskArgumentsArray: \(notifierArgsArray)")
    }
    // If the user running the app (NSUserName) isn't the logged in user
    if NSUserName() != loggedInUser {
        // Set taskPath to su as we need to use that to run as the user
        taskPath = "/usr/bin/su"
        // Create suArgsString var
        var suArgsString = "'" + notifierPath + "'"
        // Create taskArgumentsArray
        taskArgumentsArray = ["-l", loggedInUser, "-c"]
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
        // Append suArgsString
        taskArgumentsArray.append(suArgsString)
    // If the person running the app is the logged in user
    } else {
        // Set taskPath to the notifying apps path
        taskPath = notifierPath
        // Set taskArgumentsArray to notifierArgsArray
        taskArgumentsArray = notifierArgsArray
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskArgumentsArray: \(taskArgumentsArray)")
    }
    // Return the populated array
    return (taskArgumentsArray, taskPath)
}

func changeIcon(brandingImage: String, loggedInUser: String, parsedResult: ArgParser) {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - brandingImage: \(brandingImage)")
    }
    // Get the details of the file at brandingImage
    let imageData = getImageDetails(brandingImage: brandingImage, parsedResult: parsedResult)
    // Get path to the main Notifier.app
    let notifierAppPath = Bundle.main.bundlePath
    // Get path to the Alert app
    let notifierAlertPath = (Bundle.main.path(forResource: nil, ofType: "app", inDirectory: "alert") ?? "") as String
    // Get path to the Banner app
    let notifierBannerPath = (Bundle.main.path(forResource: nil, ofType: "app", inDirectory: "banner") ?? "") as String
    // Create Array of apps to update the icons of
    let notifierApps = [notifierAppPath, notifierAlertPath, notifierBannerPath]
    // Create an array to log progress for icon changes
    var brandingStatus = [Bool]()
    // For each application in brandingArray
    for notifierApp in notifierApps {
        brandingStatus.append(updateIcon(brandingImage: brandingImage, imageData: imageData!, objectPath: notifierApp,
                                         parsedResult: parsedResult))
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
            exit(0)
        }
    } else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "ERROR: Failed to rebrand Notifier...",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
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

// Post the arguments to the relevant app, exiting afterwards
func postToApp(loggedInUser: String, notifierArgsArray: [String], notifierPath: String, parsedResult: ArgParser) {
    // Build the taskArgumentsArray
    let (taskArgumentsArray, taskPath) = buildTaskArguments(loggedInUser: loggedInUser,
                                                            notifierArgsArray: notifierArgsArray,
                                                            notifierPath: notifierPath, parsedResult: parsedResult)
    // Launch the wanted notification app as the user
    _ = runTask(parsedResult: parsedResult, taskPath: taskPath, taskArguments: taskArgumentsArray)
    // Exit
    exit(0)
}

// Restarts notification center
func restartNotificationCenter(loggedInUser: String, parsedResult: ArgParser) {
    // Var declaration
    var taskArgumentsArray = [String]()
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
        taskArgumentsArray = ["-l", loggedInUser, "-c", "/usr/bin/killall -u \(loggedInUser) NotificationCenter"]
    // If the person running the app is the logged in user
    } else {
        // Path for the task
        taskPath = "/usr/bin/killall"
        // Arguments for the task
        taskArgumentsArray = ["NotificationCenter"]
    }
    // Run the task, ignoring returned exit status
    _ = runTask(parsedResult: parsedResult, taskPath: taskPath, taskArguments: taskArgumentsArray)
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
func runTask(parsedResult: ArgParser, taskPath: String, taskArguments: [String]) -> Bool {
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

// Attempts to update the app passed to objectPath's icon
func updateIcon(brandingImage: String, imageData: NSImage, objectPath: String, parsedResult: ArgParser) -> Bool {
    // Register app
    LSRegisterURL(objectPath as! CFURL, true)
    // Get the items at the root of the .app bundle
    let appRootItems = try? FileManager.default.contentsOfDirectory(atPath: objectPath)
    // If we have items
    if (appRootItems?.isEmpty) != nil {
        // For each item found, wherethe item starts with Icon\r
        for appRootItem in appRootItems! where appRootItem.hasSuffix("Icon\r") {
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Progress log
                NSLog("""
                      \(#function.components(separatedBy: "(")[0]) - Deleting: \(objectPath + "/" + appRootItem)...
                      """)
            }
            // Delete the file
            try? FileManager.default.removeItem(atPath: objectPath + "/" + appRootItem)
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
