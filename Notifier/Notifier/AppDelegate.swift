//
//  AppDelegate.swift
//  Notifier
//
//  Copyright © 2023 dataJAR Ltd. All rights reserved.
//

import Cocoa
import CoreFoundation


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    // Check arguments passed to app, then OS if a valid argument is passed else print usage
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let loggedInUser = atLoginWindow()
        var notifierArgsArray = [String]()
        var notifierPath = ""
        var parsedType = ""
        var verboseMode = false

        // Exit if notificaiton center isn't running for the user
        guard !NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.notificationcenterui").isEmpty else {
            print("ERROR: Notification Center is not running...")
            exit(1)
        }

        // Define args to be parsed
        do {

            // The first argument is always the executable, drop it
            let passedArgs = Array(CommandLine.arguments.dropFirst())

            // If no args passed
            if passedArgs.count == 0 {
                try _ = argParser.parse(["--help"])
            }
            
            // Get the parsed args
            let parsedResult = try argParser.parse(passedArgs)
                        
            // If verbose mode is enabled
            verboseMode = parsedResult.verbose
            if verboseMode {
                NSLog("Notifier Log: notifier - verbose enabled")
                notifierArgsArray.append("--verbose")
            }

            // Check parsed args to make sure at least base args are found, if not show help
            if parsedResult.type != nil {
                if ((parsedResult.message == "") || (parsedResult.message == nil )) && ((parsedResult.remove == "") || (parsedResult.remove == nil)){
                    try _ = argParser.parse(["--help"])
                } else {
                    if let type = parsedResult.type {
                        if type != "alert" && type != "banner" {
                            try _ = argParser.parse(["--help"])
                        } else {
                            parsedType = type.lowercased()
                        }
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                }
            } else {
                try _ = argParser.parse(["--help"])
            }


           // If --remove all passed
           if (parsedResult.remove == "all") {
                if verboseMode {
                     NSLog("Notifier Log: notifier - remove all")
                }
                notifierArgsArray.append("--remove")
                notifierArgsArray.append("all")

            // If not parse other args
            } else {

                if (parsedResult.remove == "prior") {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - remove prior")
                    }
                    notifierArgsArray.append("--remove")
                    notifierArgsArray.append("prior")
                }

                if (parsedResult.message != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - message")
                    }
                    notifierArgsArray.append("--message")
                    if (parsedResult.message == "") {
                        notifierArgsArray.append(" ")
                    } else {
                        if let message = parsedResult.message {
                            notifierArgsArray.append(message)
                        } else {
                            try _ = argParser.parse(["--help"])
                        }
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.messageaction != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - messageaction")
                    }
                    notifierArgsArray.append("--messageaction")
                    if let messageaction = parsedResult.messageaction {
                        notifierArgsArray.append(messageaction)
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.sound != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - sound")
                    }
                    notifierArgsArray.append("--sound")
                    if let sound = parsedResult.sound {
                        notifierArgsArray.append(sound)
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.subtitle != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - subtitle")
                    }
                    notifierArgsArray.append("--subtitle")
                    if let subtitle = parsedResult.subtitle {
                        notifierArgsArray.append(subtitle)
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.title != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - title")
                    }
                    notifierArgsArray.append("--title")
                    if let title = parsedResult.title {
                        notifierArgsArray.append(title)
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if parsedType == "alert" && (parsedResult.messagebutton != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - messagebutton")
                    }
                    notifierArgsArray.append("--messagebutton")
                    if let messagebutton = parsedResult.messagebutton {
                        notifierArgsArray.append(messagebutton)
                    } else {
                        try _ = argParser.parse(["--help"])
                    }
                    if (parsedResult.messagebuttonaction != nil){
                        if verboseMode {
                             NSLog("Notifier Log: notifier - messagebuttonaction")
                        }
                        notifierArgsArray.append("--messagebuttonaction")
                        if let messagebuttonaction = parsedResult.messagebuttonaction {
                            notifierArgsArray.append(messagebuttonaction)
                        } else {
                            try _ = argParser.parse(["--help"])
                        }
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }
            }

        // Other errors
        } catch {
            let message = argParser.message(for: error)
            print(message)
            if verboseMode {
                 NSLog("Notifier Log: notifier - \(message).")
            }
            exit(1)
        }

        // Parse the --type arg to select a .app bundle in /Contents/MacOS/<< type agr value >>/ error if missing
        if parsedType != "" {
            if verboseMode {
                 NSLog("Notifier Log: notifier - type - %@", parsedType)
            }
            notifierPath = Bundle.main.path(forResource: nil, ofType: "app", inDirectory: parsedType)!
            notifierPath += "/Contents/MacOS/"
            do {
                let appBundle = try FileManager.default.contentsOfDirectory(atPath: notifierPath)
                notifierPath += appBundle.first!
                if verboseMode {
                     NSLog("Notifier Log: notifier - path - %@", notifierPath)
                }
            } catch {
                print("ERROR: Cannot find an app bundle at: \(notifierPath)...")
                if verboseMode {
                     NSLog("ERROR: Cannot find an app bundle at: \(notifierPath)...")
                }
                exit(1)
            }
        }

        // Launchg the wanted notification app as the user
        let task = Process()
        if loggedInUser != "" {
            if verboseMode {
                NSLog("Notifier Log: notifier - loggedInUser - %@", loggedInUser)
            }
            var suArgsString = "'" + notifierPath + "'"
            var suArgsArray = [String]()
            for parsedArg in notifierArgsArray {
                if parsedArg.hasPrefix("--"){
                    suArgsString += " " + parsedArg
                } else {
                    suArgsString += " '" + (parsedArg) + "'"
                }
            }
            suArgsArray = [suArgsString]
            task.launchPath = "/usr/bin/su"
            suArgsArray.insert("-c", at: 0)
            suArgsArray.insert(loggedInUser, at: 0)
            suArgsArray.insert("-l", at: 0)
            task.arguments = suArgsArray
            if verboseMode {
                NSLog("Notifier Log: notifier - suArgsArray - %@", suArgsArray)
            }
        } else {
            if verboseMode {
                NSLog("Notifier Log: notifier - running as user")
            }
            task.launchPath = notifierPath
            if verboseMode {
                NSLog("Notifier Log: notifier - task.launchPath - %@", String(describing: task.launchPath))
            }
            task.arguments = notifierArgsArray
            if verboseMode {
                NSLog("Notifier Log: notifier - task.arguments - %@", String(describing: task.arguments))
            }
        }
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        if verboseMode {
            NSLog("Notifier Log: notifier - launch")
        }
        task.launch()
        task.waitUntilExit()
        if verboseMode {
            NSLog("Notifier Log: notifier - complete")
        }
        exit(0)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
