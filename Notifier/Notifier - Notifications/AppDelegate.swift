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
            //
            exit(0)
        }
        // The first argument is always the executable, drop it
        let passedArgs = Array(CommandLine.arguments.dropFirst())
        // If no args passed, show help
        if passedArgs.isEmpty {
            // If no args, show help
            _ = ArgParser.parseOrExit(["--help"])
            // If we have args
        } else {
            // Get the parsed args
            let parsedResult = ArgParser.parseOrExit(passedArgs)
            // Exit if notificaiton center isn't running
            isNotificationCenterRunning(parsedResult: parsedResult)
            // Ask permission
            requestAuthorisation(parsedResult: parsedResult)
            // Create a notification center object
            let ncCenter =  UNUserNotificationCenter.current()
            // Set delegate
            ncCenter.delegate = self
            // If verbose mode is set
            if parsedResult.verbose {
                // Progress log
                NSLog("\(#function.components(separatedBy: "(")[0]) - verbose enabled")
            }
            // Process the arguments as needed
            processArguments(ncCenter: ncCenter, parsedResult: parsedResult)
        }
    }
}

// Process the arguments as needed
func processArguments(ncCenter: UNUserNotificationCenter, parsedResult: ArgParser) {
    // Var declaration
    var notificationString = ""
    // Create a notification content object
    var ncContent = UNMutableNotificationContent()
    // If we're to remove all delivered notifications
    if parsedResult.remove.lowercased() == "all" {
        // Remove all notifications
        removeAllPriorNotifications(ncCenter: ncCenter, parsedResult: parsedResult)
    // If we're not removing
    } else {
        // Confirm that we have a message
        if parsedResult.message != "" {
            // Create the notifications body
            (ncContent, notificationString) = addNotificationBody(ncContent: ncContent,
                                                                  notificationString: notificationString,
                                                                  parsedResult: parsedResult)
        }
        // If we have a value for messageaction passed
        if parsedResult.messageaction != "" {
            // Add the notification message action
            (ncContent, notificationString) = addNotificationAction(contentKey: "messageAction",
                                                                                ncContent: ncContent,
                                                                                notificationString: notificationString,
                                                                                parsedResult: parsedResult)
        }
        // If we have a value for sound passed
        if parsedResult.sound != "" {
            // Add sound to the notification
            (ncContent, notificationString) = addNotificationSound(ncContent: ncContent,
                                                                   notificationString: notificationString,
                                                                   parsedResult: parsedResult)
        }
        // If we have a value for subtitle
        if parsedResult.subtitle != "" {
            // Add the subtitle to the notification
            (ncContent, notificationString) = addNotificationSubtitleOrTitle(contentKey: "subtitle",
                                                                             ncContent: ncContent,
                                                                             notificationString: notificationString,
                                                                             parsedResult: parsedResult)
        }
        // If we have a value for title
        if parsedResult.title != "" {
            // Add the title to the notification
            (ncContent, notificationString) = addNotificationSubtitleOrTitle(contentKey: "title", ncContent: ncContent,
                                                                             notificationString: notificationString,
                                                                             parsedResult: parsedResult)
        }
        // If we're to remove prior posted notificastions
        if parsedResult.remove.lowercased() == "prior" {
            // Remove a specific prior posted notification
            removePriorNotification(ncCenter: ncCenter, notificationString: notificationString,
                                    parsedResult: parsedResult)
        // If we're not removing
        } else {
            // Post the notification
            postNotification(ncCenter: ncCenter, ncContent: ncContent,
                             notificationString: notificationString, parsedResult: parsedResult)
        }
    }
}
