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
    // If we're about to load, make sure we're logged in, exit otherwise
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Get the username of the logged in user
        let loggedInUser = loggedInUser()
        // The first argument is always the executable, drop it
        let passedArgs = Array(CommandLine.arguments.dropFirst())
        // Get the parsed args
        let parsedResult = ArgParser.parseOrExit(passedArgs)
        // If rebrand has been passed
        if parsedResult.rebrand != "" {
            // Rebrand Notifier apps
            changeIcons(brandingImage: parsedResult.rebrand, loggedInUser: loggedInUser, parsedResult: parsedResult)
        // If we're not rebranding and no user is logged in, exit
        } else if loggedInUser == "" {
            // Post message
            print("INFO: No user logged in, and we're not rebranding... exiting...")
            // Exit
            exit(0)
        }
    }
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
            // Rebrand Notifier apps
            changeIcons(brandingImage: parsedResult.rebrand, loggedInUser: loggedInUser, parsedResult: parsedResult)
        // If we're not rebranding and no user is logged in, exit
        } else if loggedInUser == "" {
            // Post message
            postToNSLogAndStdOut(logLevel: "INFO", logMessage: "No user logged in, exiting...",
                                 functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
            // Exit
            exit(0)
        // If we have no value passed to --type
        } else if parsedResult.type == "" {
            // Show help
            _ = ArgParser.parseOrExit(["--help"])
            // Exit
            exit(1)
        }
        // Exit if Notification Center isn't running for the user
        isNotificationCenterRunning(parsedResult: parsedResult)
        // Check that we have all the needed arguments and that they are valid options, exiting if not
        checkArgs(parsedResult: parsedResult)
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - type - \(parsedResult.type)")
        }
        // Var declaration
        var notifierPath = String()
        // If we're looking for the alert app
        if parsedResult.type == "alert" {
            // Get the alert apps path
            notifierPath = GlobalVariables.alertAppPath + "/Contents/MacOS/Notifier - Alerts"
        // If we're looking for the notifications app
        } else {
            // Get the alert apps path
            notifierPath = GlobalVariables.bannerAppPath + "/Contents/MacOS/Notifier - Notifications"
        }
        // If --remove all has been passed
        if parsedResult.remove.lowercased() == "all" {
            // Initialize a rootElements object
            var rootElements = RootElements(removeOption: "all")
            // Initialize a messageContent object
            let messageContent = MessageContent()
            // If verbose mode is enabled
            if parsedResult.verbose {
                // Set verboseMode
                rootElements.verboseMode = "enabled"
            }
            // Create the JSON to pass to the notifying app
            let commandJSON = createJSON(messageContent: messageContent, parsedResult: parsedResult,
                                         rootElements: rootElements)
            // Pass commandJSON to the relevant app, exiting afterwards
            passToApp(commandJSON: commandJSON, loggedInUser: loggedInUser, notifierPath: notifierPath,
                      parsedResult: parsedResult)
        } else {
            // Format the args as needed
            formatArgs(loggedInUser: loggedInUser, notifierPath: notifierPath, parsedResult: parsedResult)
        }
    }
}

// Check that we have all the needed arguments and that they are valid options, exiting if not
func checkArgs(parsedResult: ArgParser) {
    // If an invalid value for --type has been passed
    if parsedResult.type.lowercased() != "alert" && parsedResult.type.lowercased() != "banner" {
        // Post message
        postToNSLogAndStdOut(logLevel: "ERROR", logMessage: "incorrect argument passed to --type, exiting...\n",
                             functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Show help
        _ = ArgParser.parseOrExit(["--help"])
        // Exit
        exit(1)
    }
    // If an invalid value for --remove has been passed
    if parsedResult.remove != "" && parsedResult.remove.lowercased() != "all" && parsedResult.remove.lowercased()
          != "prior" {
        // Post message
        postToNSLogAndStdOut(logLevel: "ERROR", logMessage: "incorrect argument passed to --remove, exiting...\n",
                              functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Show help
        _ = ArgParser.parseOrExit(["--help"])
        // Exit
        exit(1)
    }
    // If we've got here and no --message has been passed and we're not removing
    if parsedResult.remove == "" && parsedResult.message == "" {
        // Post message
        postToNSLogAndStdOut(logLevel: "ERROR", logMessage: """
                        missing value for --message and we're neither rebranding nor removing, exiting...\n
                        """, functionName: #function.components(separatedBy: "(")[0], parsedResult: parsedResult)
        // Show help
        _ = ArgParser.parseOrExit(["--help"])
        // Exit
        exit(1)
    }
}

// Format the args as needed
func formatArgs(loggedInUser: String, notifierPath: String, parsedResult: ArgParser) {
    // Initialize a messageContent object
    var messageContent = MessageContent()
    // Initialize a rootElements object
    var rootElements = RootElements()
    // If verbose mode is enabled
    if parsedResult.verbose {
        // Set verboseMode
        rootElements.verboseMode = "enabled"
    }
    // Set the message to the body of the notification as not removing all, we have to have this
    messageContent.messageBody = setNotificationBody(parsedResult: parsedResult)
    // If we've been passed a messageaction
    if parsedResult.messageaction != "" {
        // Set messageAction
        messageContent.messageAction = parseAction(actionString: parsedResult.messageaction,
                                                    parsedResult: parsedResult)
    }
    // If we've been passed a sound
    if parsedResult.sound != "" {
        // Set messageSound
        messageContent.messageSound = setNotificationSound(parsedResult: parsedResult)
    }
    // If we've been passed a subtitle
    if parsedResult.subtitle != "" {
        // Set messageSubtitle
        messageContent.messageSubtitle = setNotificationSubtitle(parsedResult: parsedResult)
    }
    // If we've been passed a title
    if parsedResult.title != "" {
        // Set messageTitle
        messageContent.messageTitle = setNotificationTitle(parsedResult: parsedResult)
    }
    // If we're to remove a prior posted notification
    if parsedResult.remove.lowercased() == "prior" {
        // Set removeOption
        rootElements.removeOption = "prior"
        // If verbose mode is enabled
        if parsedResult.verbose {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - removeOption: \(rootElements.removeOption!))")
        }
    }
    // If we've been passed a messagebutton, and messagebuttonaction
    if parsedResult.messagebutton != "" {
        // Set messageButton and messagebuttonaction
        messageContent.messageButton = setNotificationMessageButton(parsedResult: parsedResult)
        // If we've been passed a messagebuttonaction, only set if a messagebutton was passed too
        if parsedResult.messagebuttonaction != "" {
            // Set messageButtonAction
            messageContent.messageButtonAction = parseAction(actionString:
                                                              parsedResult.messagebuttonaction,
                                                              parsedResult: parsedResult)
        }
    }
    // Create the JSON to pass to the notifying app
    let commandJSON = createJSON(messageContent: messageContent, parsedResult: parsedResult,
                                 rootElements: rootElements)
    // Pass commandJSON to the relevant app, exiting afterwards
    passToApp(commandJSON: commandJSON, loggedInUser: loggedInUser, notifierPath: notifierPath,
              parsedResult: parsedResult)
}
