//
//  AppDelegate.swift
//  Notifier
//
//  Copyright © 2020 dataJAR Ltd. All rights reserved.
//

import Cocoa
import CoreFoundation
import SPMUtility

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

            let argParser = ArgumentParser(commandName: "notifier", usage: "--type <alert/banner> --message <some message> <options>", overview: "Notifier: Sends banner or alert notifications.", seeAlso: "https://github.com/dataJAR/Notifier")
            let ncMessage = argParser.add(option: "--message", kind: String.self, usage: "message text - REQUIRED if not passing --remove all")
            let ncMessageAction = argParser.add(option: "--messageaction", kind: String.self, usage: "The action to be performed when the message is clicked. Either pass 'logout' or path to item to open on click. Can be a .app, file, URL etc. With non-.app items being opened in their default handler")
            let ncMessageButton = argParser.add(option: "--messagebutton", kind: String.self, usage: "alert type only. Sets the message buttons text")
            let ncMessageButtonAction = argParser.add(option: "--messagebuttonaction", kind: String.self, usage: "alert type only. The action to be performed when the message button is clicked. Either pass 'logout' or path to item to open on click. Can be a .app, file, URL etc. With non-.app items being opened in their default handler. Requires '--messagebutton' to be passed")
            let ncRemove = argParser.add(option: "--remove", kind: String.self, usage: "\"prior\" or \"all\". If passing \"prior\", the full message will be required too. Including all passed flags")
            let ncSound = argParser.add(option: "--sound", kind: String.self, usage: "sound to play. Pass \"default\" for the default macOS sound, else the name of a sound in /Library/Sounds or /System/Library/Sounds. If the sound cannot be found, macOS will use the \"default\" sound" )
            let ncSubtitle = argParser.add(option: "--subtitle", kind: String.self, usage: "message subtitle")
            let ncTitle = argParser.add(option: "--title", kind: String.self, usage: "message title")
            let ncType = argParser.add(option: "--type", kind: String.self, usage: "alert or banner - REQUIRED")
            let ncVerbose = argParser.add(option: "--verbose", kind: Bool.self, usage: "Enables logging of actions. Check console for  'Notifier Log:' messages")

            // The first argument is always the executable, drop it
            let passedArgs = Array(CommandLine.arguments.dropFirst())

            // If no args passed
            if passedArgs.count == 0 {
                try _ = argParser.parse(["--help"])
            }
            
            // Get the parsed args
            let parsedResult = try argParser.parse(passedArgs)

            // If verbose mode is enabled
            verboseMode = parsedResult.get(ncVerbose) ?? false
            if verboseMode {
                NSLog("Notifier Log: notifier - verbose enabled")
                notifierArgsArray.append("--verbose")
            }

            // Check parsed args to make sure at least base args are found, if not show help
            if (parsedResult.get(ncType) != nil){
                if ((parsedResult.get(ncMessage) == "") || (parsedResult.get(ncMessage) == nil )) && ((parsedResult.get(ncRemove) == "") || (parsedResult.get(ncRemove) == nil)){
                    try _ = argParser.parse(["--help"])
                } else {
                    parsedType = parsedResult.get(ncType)!.lowercased()
                    if parsedType != "alert" && parsedType != "banner" {
                        try _ = argParser.parse(["--help"])
                    }
                }
            } else {
                try _ = argParser.parse(["--help"])
            }

           // If --remove all passed
           if (parsedResult.get(ncRemove) == "all") {
                if verboseMode {
                     NSLog("Notifier Log: notifier - remove all")
                }
                notifierArgsArray.append("--remove")
                notifierArgsArray.append("all")

            // If not parse other args
            } else {

                if (parsedResult.get(ncRemove) == "prior") {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - remove prior")
                    }
                    notifierArgsArray.append("--remove")
                    notifierArgsArray.append("prior")
                }

                if (parsedResult.get(ncMessage) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - message")
                    }
                    notifierArgsArray.append("--message")
                    if (parsedResult.get(ncMessage) == "") {
                        notifierArgsArray.append(" ")
                    } else {
                        notifierArgsArray.append(parsedResult.get(ncMessage)!)
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }
            
                if (parsedResult.get(ncMessageAction) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - messageaction")
                    }
                    notifierArgsArray.append("--messageaction")
                    notifierArgsArray.append(parsedResult.get(ncMessageAction)!)
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.get(ncSound) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - sound")
                    }
                    notifierArgsArray.append("--sound")
                    notifierArgsArray.append(parsedResult.get(ncSound)!)
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.get(ncSubtitle) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - subtitle")
                    }
                    notifierArgsArray.append("--subtitle")
                    notifierArgsArray.append(parsedResult.get(ncSubtitle)!)
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if (parsedResult.get(ncTitle) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - title")
                    }
                    notifierArgsArray.append("--title")
                    notifierArgsArray.append(parsedResult.get(ncTitle)!)
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }

                if parsedType == "alert" && (parsedResult.get(ncMessageButton) != nil) {
                    if verboseMode {
                         NSLog("Notifier Log: notifier - messagebutton")
                    }
                    notifierArgsArray.append("--messagebutton")
                    notifierArgsArray.append(parsedResult.get(ncMessageButton)!)
                    if (parsedResult.get(ncMessageButtonAction) != nil){
                        if verboseMode {
                             NSLog("Notifier Log: notifier - messagebuttonaction")
                        }
                        notifierArgsArray.append("--messagebuttonaction")
                        notifierArgsArray.append(parsedResult.get(ncMessageButtonAction)!)
                    }
                    if verboseMode {
                         NSLog("Notifier Log: notifier - notifierArgsArray - %@", notifierArgsArray)
                    }
                }
            }

        // If we're missing a value for an arg
        } catch ArgumentParserError.expectedValue(let value) {
            print("Missing value for argument \(value).")
            if verboseMode {
                 NSLog("Notifier Log: notifier - Missing value for argument \(value).")
            }
            exit(1)
        // If we're missing a value for an arg
        } catch ArgumentParserError.expectedArguments( _, let stringArray) {
            print("Missing arguments: \(stringArray.joined()).")
            if verboseMode {
                 NSLog("Notifier Log: notifier - Missing value for argument \(stringArray.joined()).")
            }
            exit(1)
        // Other errors
        } catch {
            print(error.localizedDescription)
            if verboseMode {
                 NSLog("Notifier Log: notifier - \(error.localizedDescription).")
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
