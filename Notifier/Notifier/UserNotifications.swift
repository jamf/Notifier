//
//  UserNotifications.swift
//  Notifiers - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

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
