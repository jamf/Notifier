//
//  AppDelegate.swift
//  Notifier
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Cocoa
import CoreFoundation
import UserNotifications

// Declaration
@NSApplicationMain
// The apps class
class AppDelegate: NSObject, NSApplicationDelegate {
    // IBOutlet declaration
    @IBOutlet weak var window: NSWindow!
    // Check arguments passed to app, then OS if a valid argument is passed else print usage
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Get the username of the logged in user
        let loggedInUser = loggedInUser()
        // Check to see if at the loginwindow, and exit if we are
        if loggedInUser == "" {
            // Print error
            print("ERROR: No user logged in...")
            // Exit
            exit(1)
        }
        // Exit if notificaiton center isn't running for the user
        isNotificationCenterRunning()
        // The first argument is always the executable, drop it
        let passedArgs = Array(CommandLine.arguments.dropFirst())
        // If no args passed, show help
        if passedArgs.isEmpty {
            // If no args, show help
            _ = ArgParser.parseOrExit(["--help"])
            // Exit
            exit(1)
        }
        // Get the parsed args
        let parsedResult = ArgParser.parseOrExit(passedArgs)
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: notifier - verbose enabled")
        }
        // Set parsedtype to lowercase of type
        let parsedType = parsedResult.type.lowercased()
        // If an invalid type is pased, or we have don't have a message and we're not removing
        if parsedType != "alert" && parsedType != "banner" ||
            parsedResult.message == "" && parsedResult.remove == "" {
            // Show help
            _ = ArgParser.parseOrExit(["--help"])
            // Exit
            exit(1)
        }
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: notifier - type - %@", parsedType)
        }
        // Look for the corresponding app's bundle
        var notifierPath = Bundle.main.path(forResource: nil, ofType: "app", inDirectory: parsedType)!
        + "/Contents/MacOS/"
        // Check that the expected .app exists
        do {
            // Confirm that we can find the wanted app bundle
            let appBundle = try FileManager.default.contentsOfDirectory(atPath: notifierPath)
            // Append to path
            notifierPath += appBundle.first!
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Progress log
                NSLog("Notifier Log: notifier - path - %@", notifierPath)
            }
            // If we cannot find the expected app
        } catch {
            // Print error
            print("ERROR: Cannot find an app bundle at: \(notifierPath)...")
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Progress log
                NSLog("ERROR: Cannot find an app bundle at: \(notifierPath)...")
            }
            // Exit
            exit(1)
        }
        // If --remove all has been passed
        if parsedResult.remove.lowercased() == "all" {
            // Var declaration
            var notifierArgsArray = [String]()
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Append --verbose
                notifierArgsArray.append("--verbose")
            }
            // Append --remove all
            notifierArgsArray = appendRemoveAll(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
            // Post the arguments to the relevant app, exiting afterwards
            postToApp(loggedInUser: loggedInUser, notifierArgsArray: notifierArgsArray, notifierPath: notifierPath)
        }
        // Format the args as needed
        formatArgs(loggedInUser: loggedInUser, notifierPath: notifierPath, parsedResult: parsedResult,
                   parsedType: parsedType)
    }
}

// Format the args as needed
func formatArgs(loggedInUser: String, notifierPath: String, parsedResult: ArgParser,
                parsedType: String) {
    // Var declaration
    var notifierArgsArray = [String]()
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Append --verbose
        notifierArgsArray.append("--verbose")
    }
    // If we've been passed a message
    if parsedResult.message != "" {
        // Append --message
        notifierArgsArray = appendMessage(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we've been passed a messageaction
    if parsedResult.messageaction != "" {
        // Append --messageaction
        notifierArgsArray = appendMessageaction(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we've been passed a subtitle
    if parsedResult.subtitle != "" {
        // Append --subtitle
        notifierArgsArray = appendSubtitle(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we've been passed a title
    if parsedResult.title != "" {
        // Append --title
        notifierArgsArray = appendTitle(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we've been passed a sound
    if parsedResult.sound != "" {
        // Append --sound
        notifierArgsArray = appendSound(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we're to remove a prior posted notification
    if parsedResult.remove.lowercased() == "prior" {
        // Append --remove prior
        notifierArgsArray = appendRemovePrior(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    // If we've been passed something other than all or prior
    } else {
        // Show help
        _ = ArgParser.parseOrExit(["--help"])
        // Exit
        exit(1)
    }
    // If we're dealing with an alert, check for additional items
    if parsedType == "alert" {
        // If we've been passed a messagebutton
        if parsedResult.messagebutton != "" {
            // Append --messagebutton
            notifierArgsArray = appendMessagebutton(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
        }
        // If we've been passed a messagebuttonaction
        if parsedResult.messagebuttonaction != "" {
            // Append --messagebuttonaction
            notifierArgsArray = appendMessagebuttonaction(notifierArgsArray: notifierArgsArray,
                                                          parsedResult: parsedResult)
        }
    }
    // Post the arguments to the relevant app, exiting afterwards
    postToApp(loggedInUser: loggedInUser, notifierArgsArray: notifierArgsArray, notifierPath: notifierPath)
}

// Post the arguments to the relevant app, exiting afterwards
func postToApp(loggedInUser: String, notifierArgsArray: [String], notifierPath: String) {
    // Build the taskArgumentsArray
    let taskArgumentsArray = buildTaskArgumentsArray(loggedInUser: loggedInUser,
                                                     notifierArgsArray: notifierArgsArray, notifierPath: notifierPath)
    // Launch the wanted notification app as the user
    let (_, _) = runTask(taskPath: "/usr/bin/su", taskArguments: taskArgumentsArray)
    // Exit
    exit(0)
}
