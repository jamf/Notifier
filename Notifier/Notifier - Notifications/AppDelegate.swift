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
            // Print error
            print("ERROR: No arguments passed to binary, exiting...")
            // Exit
            exit(0)
        } else {
            // Get the passed base64 string at commandline argument at index 1
            let (messageContent, passedBase64, rootElements) = decodeJSON(passedJSON: passedCLIArguments[1])
            // Exit if Notification Center isn't running
            isNotificationCenterRunning(verboseMode: rootElements.verboseMode ?? "")
            // Ask permission
            requestAuthorisation(verboseMode: rootElements.verboseMode ?? "")
            // Create a notification center object
            let notificationCenter =  UNUserNotificationCenter.current()
            // Set delegate
            notificationCenter.delegate = self
            // Process the arguments as needed
            processArguments(messageContent: messageContent, notificationCenter: notificationCenter,
                             passedBase64: passedBase64, passedCLIArguments: passedCLIArguments,
                             rootElements: rootElements)
        }
    }
}

// Process the arguments as needed
func processArguments(messageContent: MessageContent, notificationCenter: UNUserNotificationCenter,
                      passedBase64: String, passedCLIArguments: [String], rootElements: RootElements) {
    // Create a notification content object
    let notificationContent = UNMutableNotificationContent()
    // Add category identifier to notificationContent required anyway so setting here
    notificationContent.categoryIdentifier = "banner"
    // If verbose mode is set
    if rootElements.verboseMode != nil {
        // Add verboseMode to userInfo
        notificationContent.userInfo["verboseMode"] = "enabled"
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - verbose enabled")
    }
    // If we're to remove all delivered notifications
    if rootElements.removeOption == "all" {
        // Remove all notifications
        removeAllPriorNotifications(notificationCenter: notificationCenter, messageContent: messageContent,
                                    rootElements: rootElements)
    // If we're not removing
    } else {
        // Set the message to the body of the notification as not removing all, we have to have this
        notificationContent.body = getNotificationBody(messageContent: messageContent, rootElements: rootElements)
        // If we have a value for messageAction passed
        if messageContent.messageAction != nil {
            // Add messageAction to userInfo
            notificationContent.userInfo["messageAction"] = getNotificationBodyAction(messageContent: messageContent,
                                                                                      rootElements: rootElements)
        }
        // If we have a value for messageSound passed
        if messageContent.messageSound != nil {
            // Set the notifications sound
            notificationContent.sound = getNotificationSound(messageContent: messageContent, rootElements: rootElements)
        }
        // If we've been passed a messageSubtitle
        if messageContent.messageSubtitle != nil {
            // Set the notifications subtitle
            notificationContent.subtitle = getNotificationSubtitle(messageContent: messageContent,
                                                                   rootElements: rootElements)
        }
        // If we have a value for messageTitle
        if messageContent.messageTitle != nil {
            // Set the notifications title
            notificationContent.title = getNotificationTitle(messageContent: messageContent, rootElements: rootElements)
        }
        // If we're to remove a prior posted notification
        if rootElements.removeOption == "prior" {
            // Remove a specific prior posted notification
            removePriorNotification(notificationCenter: notificationCenter, messageContent: messageContent,
                                    passedBase64: passedBase64, rootElements: rootElements)
        } else {
            // Post the notification
            postNotification(notificationCenter: notificationCenter, notificationContent: notificationContent,
                             messageContent: messageContent, passedBase64: passedBase64, rootElements: rootElements)
        }
    }
}
