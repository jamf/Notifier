//
//  UserNotifications.swift
//  Notifiers - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// Parses the action text, splitting it into argv compliant format
func parseAction(actionString: String, parsedResult: ArgParser) -> [ParsedArguments.TaskObject] {
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
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - regexDict: \(regexDict)")
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
        if taskArguments[0].lowercased() == "logout"{
            // Set the tasks path to open, this is to mimic pre-3.0 behaviour
            taskPath = "logout"
            // Clear taskArguments
            taskArguments = []
        } else {
            // Set the  tasks path to open, this is to mimic pre-3.0 behaviour
            taskPath = "/usr/bin/open"
        }
    // If we have more than one task
    } else {
        // Set the tasks path to the 1st item within the taskArguments
        taskPath = taskArguments[0]
        // Remove the above from the taskArguments
        taskArguments.remove(at: 0)
    }
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - taskPath: \(taskPath), taskArguments: \(taskArguments)")
    }
    return [ParsedArguments.TaskObject(taskPath: taskPath, taskArguments: taskArguments)]
}

// Sets the notifications body to what was passed to --message
func setNotificationBody(parsedResult: ArgParser) -> String {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) \(parsedResult.message)")
    }
    // Returns the value passed to --message
    return parsedResult.message
}

// Sets the notifications message button to what was passed to --messagebutton
func setNotificationMessageButton(parsedResult: ArgParser) -> String {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) \(parsedResult.messagebutton)")
    }
    // Returns the value passed to --messagebutton
    return parsedResult.messagebutton
}

// Sets the notifications sound to what was passed to --sound
func setNotificationSound(parsedResult: ArgParser) -> String {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) \(parsedResult.sound)")
    }
    // Returns the value passed to --sound
    return parsedResult.sound
}

// Sets the notifications subtitle to what was passed to --subtitle
func setNotificationSubtitle(parsedResult: ArgParser) -> String {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) \(parsedResult.subtitle)")
    }
    // Returns the value passed to --subtitle
    return parsedResult.subtitle
}

// Sets the notifications title to what was passed to --title
func setNotificationTitle(parsedResult: ArgParser) -> String {
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) \(parsedResult.title)")
    }
    // Returns the value passed to --title
    return parsedResult.title
}
