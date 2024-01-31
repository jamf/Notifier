//
//  AppDelegate.swift
//  Notifier - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa
import UserNotifications

// Declaration
@NSApplicationMain
// The apps class
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    // IBOutlet declaration
    @IBOutlet weak var window: NSWindow!
    // When we've finished launching
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // If .userInfo ios populated, we've baen launched by interation with a prior posted notification
        if let response = (aNotification as NSNotification).userInfo?[
            NSApplication.launchUserNotificationUserInfoKey] as? UNNotificationResponse {
            // Handle the notification
            handleNotification(forResponse: response)
            // Exit
            exit(0)
        }
        // Get the args passed to the binary
        let passedCLIArguments = Array(CommandLine.arguments)
        // If no args passed, exit
        if passedCLIArguments.count == 1 {
            // Post an error to stdout and console
            postError(errorMessage: "ERROR: No arguments passed to binary",
                      functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
            // Exit
            exit(0)
        } else {
            // Exit if notificaiton center isn't running
            isNotificationCenterRunning(verboseMode: "enabled")
            // Ask permission
            requestAuthorisation(verboseMode: "enabled")
            // Create a notification center object
            let notificationCenter =  UNUserNotificationCenter.current()
            // Set delegate
            notificationCenter.delegate = self
            // Process the arguments as needed
            processArguments(notificationCenter: notificationCenter, passedCLIArguments: passedCLIArguments)
        }
    }
}

// Process the arguments as needed
func processArguments(notificationCenter: UNUserNotificationCenter,
                      passedCLIArguments: [String]) {
    // Get the passed base64 string at commandline argument at index 1
    let parsedArguments = decodeJSON(parsedArgumentsJSON: passedCLIArguments[1])
    // Create a notification content object
    let notificationContent = UNMutableNotificationContent()
    // Add category identifier to notificationContent required anyway so setting here
    notificationContent.categoryIdentifier = "banner"
    // If verbose mode is set
    if parsedArguments.verboseMode != "" {
        // Add verboseMode to userInfo
        notificationContent.userInfo["verboseMode"] = "enabled"
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - verbose enabled")
    }
    // If we're to remove all delivered notifications
    if parsedArguments.removeOption == "all" {
        // Remove all notifications
        removeAllPriorNotifications(notificationCenter: notificationCenter, parsedArguments: parsedArguments)
    // If we're not removing
    } else {
        // Set the message to the body of the notification as not removing all, we have to have this
        notificationContent.body = getNotificationBody(parsedArguments: parsedArguments)
        // If we have a value for messageAction passed
        if parsedArguments.messageAction != nil {
            // Add messageAction to userInfo
            notificationContent.userInfo["messageAction"] = getNotificationBodyAction(parsedArguments: parsedArguments)
        }
        // If we have a value for messageSound passed
        if parsedArguments.messageSound != nil {
            // Set the notifications sound
            notificationContent.sound = getNotificationSound(parsedArguments: parsedArguments)
        }
        // If we've been passed a messageSubtitle
        if parsedArguments.messageSubtitle != nil {
            // Set the notifications subtitle
            notificationContent.subtitle = getNotificationSubtitle(parsedArguments: parsedArguments)
        }
        // If we have a value for messageTitle
        if parsedArguments.messageTitle != nil {
            // Set the notifications title
            notificationContent.title = getNotificationTitle(parsedArguments: parsedArguments)
        }
        // If we're to remove a prior posted notification
        if parsedArguments.removeOption == "prior" {
            // Remove a specific prior posted notification
            removePriorNotification(notificationCenter: notificationCenter, parsedArguments: parsedArguments,
                                    passedBase64: passedCLIArguments[1])
        } else {
            // Post the notification
            postNotification(notificationCenter: notificationCenter, notificationContent: notificationContent,
                             parsedArguments: parsedArguments, passedBase64: passedCLIArguments[1])
        }
    }
}
