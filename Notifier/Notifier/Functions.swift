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
        postError(errorMessage: "Failed to rebrand Notifier...",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(1)
    }
}

// Create JSON from passed string
func createJSON(messageContent: MessageContent, parsedResult: ArgParser, rootElements: RootElements) -> String {
    // Var declaration
    var contentJSON = Data()
    var fullJSON = Data()
    var rootContent = rootElements
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageContent: \(messageContent)")
    }
    // Try to convert messageContent to JSON
    do {
        // Create a JSONEncoder object
        let jsonEncoder = JSONEncoder()
        // Set formatting to sortedKeys - to make sure that the base64 is static
        jsonEncoder.outputFormatting = .sortedKeys
        // Turn messageContent into JSON
        contentJSON = try jsonEncoder.encode(messageContent)
    // If encoding into JSON fails
    } catch {
        // Raise an error
        postError(errorMessage: error.localizedDescription, functionName: #function.components(separatedBy: "(")[0],
                  parsedResult: parsedResult)
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - contentJSON: \(String(data: contentJSON, encoding: .utf8)!)
             """)
    }
    // Add to contentJSON, but base64 encoded
    rootContent.messageContent = contentJSON.base64EncodedString()
    // Try to convert jsonContent to JSON
    do {
        // Create a JSONEncoder object
        let jsonEncoder = JSONEncoder()
        // Set formatting to sortedKeys - to make sure that the base64 is static
        jsonEncoder.outputFormatting = .sortedKeys
        // Turn jsonContent into JSON
        fullJSON = try jsonEncoder.encode(rootContent)
    // If encoding into JSON fails
    } catch {
        // Raise an error
        postError(errorMessage: error.localizedDescription, functionName: #function.components(separatedBy: "(")[0],
                  parsedResult: parsedResult)
    }
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - rootJSON: \(String(data: fullJSON, encoding: .utf8)!)")
    }
    // Return fullJSON, base64 encoded
    return fullJSON.base64EncodedString()
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
            postError(errorMessage: "\(brandingImage) is not a valid image...",
                      functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
            // Exit
            exit(1)
        }
        // Return the image data
        return imageData
    // If the file doesn't exist
    } else {
        // Post error to stdout and NSLog if verbose mode is enabled
        postError(errorMessage: "Cannot locate: \(brandingImage)....",
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
        // Post warning
        postWarning(warningMessage: "Notification Center is not running...",
                    functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Exit
        exit(0)
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

// Parses the action text, splitting it into argv compliant format
func parseAction(actionString: String, parsedResult: ArgParser) -> [MessageContent.TaskObject] {
    // Var declaration
    var regexDict = [String: String]()
    var taskArguments = [String]()
    var taskPath = String()
    var tempActionString = actionString
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - actionString: \(actionString)")
    }
    // The regex pattern we're to use
    let regexPattern = try? NSRegularExpression(pattern: "\'(.*?)\'|\"(.*?)\"")
    // Apply pattern to actionText, returning matches
    let regexMatches = regexPattern?.matches(in: actionString, options: [],
                                            range: NSRange(location: 0, length: actionString.utf16.count))
    // Iterate over each match
    for regexMatch in regexMatches! {
        // Set the range
        let regexRange = regexMatch.range(at: 1)
        // Create a Range object
        if let swiftRange = Range(regexRange, in: actionString) {
            // Create key in regex dict with the  and %20 escape spaces
            regexDict[actionString[swiftRange].description] =
            actionString[swiftRange].description.replacingOccurrences(of: " ", with: "%20")
        }
    }
    // If we have items in regexDict
    if !regexDict.isEmpty {
        // For each key value pair we have in regexDict
        for (matchedKey, matchedValue) in regexDict {
            // Replace the occurences of matchedKey with matchedValue
            tempActionString = tempActionString.replacingOccurrences(of: matchedKey, with: matchedValue)
        }
        // Set taskArguments to the amended string
        taskArguments = Array(tempActionString.components(separatedBy: " "))
        // Iterate over the array elements which contain %20
        for arrayElement in taskArguments where arrayElement.contains("%20") {
            // Get the index of the element
            let arrayIndex = taskArguments.firstIndex(of: arrayElement)
            // Update the element in the array, removing %20, single and double quotes
            taskArguments[arrayIndex!] = arrayElement.replacingOccurrences(of: "%20", with: " ")
                .replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: "\"", with: "")
        }
    // If regexDict is empty
    } else {
        // Set taskArguments to the passed action
        taskArguments = Array(tempActionString.components(separatedBy: " "))
    }
    // If we only have a single task
    if taskArguments.count == 1 {
        // If we've been passed logout
        if taskArguments[0].lowercased() == "logout" {
            // Set the tasks path to open, this is to mimic pre-3.0 behaviour
            taskPath = "logout"
            // Clear taskArguments
            taskArguments = []
        } else {
            // Set the tasks path to open, this is to mimic pre-3.0 behaviour
            taskPath = "/usr/bin/open"
        }
    // If we have more than one task, the 1st argument starts with /
    } else if taskArguments[0].hasPrefix("/") {
        // Set the tasks path to the 1st item within the taskArguments
        taskPath = taskArguments[0]
        // Remove the above from the taskArguments
        taskArguments.remove(at: 0)
    // If we have more than one task, and the 1st argument does not start with /
    } else {
        // Warning message
        let warningMessage = "\(taskArguments[0]) is not a path to a binary, not adding to notification..."
        // Post warning
        postWarning(warningMessage: warningMessage, functionName: #function.components(separatedBy: "(")[0],
                    parsedResult: parsedResult)
        // Return an empty TaskObject
        return [MessageContent.TaskObject(taskPath: "", taskArguments: [])]
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskPath: \(taskPath), taskArguments: \(taskArguments)")
    }
    // Return a TaskObject with taskPath and taskArguments set
    return [MessageContent.TaskObject(taskPath: taskPath, taskArguments: taskArguments)]
}

// Passes messageContentJSON to the relevant app, exiting afterwards
func passToApp(commandJSON: String, loggedInUser: String, notifierPath: String, parsedResult: ArgParser) {
    // Var declaration
    var taskArguments = [String]()
    var taskPath = String()
    // If the user running the app isn't the logged in user (root for example)
    if NSUserName() != loggedInUser {
        // Set taskPath to su as we need to use that to run as the user
        taskPath = "/usr/bin/su"
        // Create taskArguments
        taskArguments = [
            "-l", "\(loggedInUser)", "-c", "\'\(notifierPath)\' \(commandJSON)"
        ]
    // If the person running the app is the logged in user
    } else {
        // Set taskPath to the notifying apps path
        taskPath = notifierPath
        // Set taskArguments to the base64 of messageContentJSON
        taskArguments = [commandJSON]
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

// Post error to both NSLog and stdout
func postError(errorMessage: String, functionName: String, parsedResult: ArgParser) {
    // Var declaration
    let fullMessage = "ERROR: \(functionName) - \(errorMessage)"
    // Print error
    print(fullMessage)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog(fullMessage)
    }
}

// Post warning to both NSLog and stdout
func postWarning(warningMessage: String, functionName: String, parsedResult: ArgParser) {
    // Var declaration
    let fullMessage = "WARNING: \(functionName) - \(warningMessage)"
    // Print error
    print(fullMessage)
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog(fullMessage)
    }
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
        postError(errorMessage: "The argument: \(passedArg), requires root privileges, exiting...",
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
        postError(errorMessage: "Failed to update icon for \(objectPath), with icon: \(brandingImage).",
                  functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
    }
    // Return boolean
    return rebrandStatus
}
