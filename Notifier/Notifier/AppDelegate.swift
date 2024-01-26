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
        // The first argument is always the executable, drop it
        let passedArgs = Array(CommandLine.arguments.dropFirst())
        // Get the parsed args
        let parsedResult = ArgParser.parseOrExit(passedArgs)
        // Get the username of the logged in user
        let loggedInUser = loggedInUser()
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - verbose enabled - arguments: \(parsedResult)")
        }
        // If rebrand has been passed
        if parsedResult.rebrand != "" {
            // Confirm we're root before proceeding
            rootCheck(parsedResult: parsedResult, passedArg: "--rebrand")
            // Rebrand Notifier apps
            changeIcon(brandingImage: parsedResult.rebrand, loggedInUser: loggedInUser, parsedResult: parsedResult)
        // If we're not rebranding and no user is logged in exit
        } else if loggedInUser == "" {
            // Post error to stdout and NSLog if verbose mode is enabled
            postError(errorMessage: "ERROR: No user logged in...",
                      functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
            // Exit
            exit(1)
        }
        // Exit if notificaiton center isn't running for the user
        isNotificationCenterRunning(parsedResult: parsedResult)
        // If an invalid type OR remove option has been passed OR there is no message & we're not rebranding
        if (parsedResult.type.lowercased() != "alert" && parsedResult.type.lowercased() != "banner") ||
            parsedResult.remove != "" &&
            (parsedResult.remove.lowercased() != "all" && parsedResult.remove.lowercased() != "prior") ||
            parsedResult.message == "" && parsedResult.rebrand == "" {
            // Show help
            _ = ArgParser.parseOrExit(["--help"])
            // Exit
            exit(1)
        }
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - type - \(parsedResult.type)")
        }
        // Look for the corresponding app's directory
        var notifierPath = Bundle.main.path(forResource: nil, ofType: "app", inDirectory: parsedResult.type)!
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
                NSLog("\(#function.components(separatedBy: "(")[0]) - path - \(notifierPath)")
            }
            // If we cannot find the expected app
        } catch {
            // Post error to stdout and NSLog if verbose mode is enabled
            postError(errorMessage: "ERROR: Cannot find an app bundle at: \(notifierPath)...",
                      functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
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
            postToApp(loggedInUser: loggedInUser, notifierArgsArray: notifierArgsArray, notifierPath: notifierPath,
                      parsedResult: parsedResult)
        } else {
            // Format the args as needed
            formatArgs(loggedInUser: loggedInUser, notifierPath: notifierPath, parsedResult: parsedResult)
        }
    }

}

// Format the args as needed
func formatArgs(loggedInUser: String, notifierPath: String, parsedResult: ArgParser) {
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
    // If we've been passed a sound
    if parsedResult.sound != "" {
        // Append --sound
        notifierArgsArray = appendSound(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
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
    // If we're to remove a prior posted notification
    if parsedResult.remove.lowercased() == "prior" {
        // Append --remove prior
        notifierArgsArray = appendRemovePrior(notifierArgsArray: notifierArgsArray, parsedResult: parsedResult)
    }
    // If we're dealing with an alert, check for additional items
    if parsedResult.type.lowercased() == "alert" {
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
    postToApp(loggedInUser: loggedInUser, notifierArgsArray: notifierArgsArray, notifierPath: notifierPath,
              parsedResult: parsedResult)
}
