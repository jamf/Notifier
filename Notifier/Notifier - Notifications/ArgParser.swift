//
//  ArgParser.swift
//  Notifier - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import ArgumentParser

// Struct for ArgParser
struct ArgParser: ParsableCommand {
    // Set overview and usage text
    static let configuration = CommandConfiguration(
        abstract: "Notifier: Sends banner notifications.",
        usage: "--message <some message> <options>"
    )
    // Required, the notifications message
    @Argument(help: "message text - REQUIRED")
    var message: String = ""
    // Optional action
    @Option(help: """
                  The action to be performed when the message is clicked. Either pass 'logout' \
                  or path to item to open on click. Can be a .app, file, URL etc. With non-.app \
                  items being opened in their default handler.
                  """)
    var messageaction: String = ""
    // Optional sound to play when notification is delivered
    @Option(help: """
                  sound to play when notification is delivered. Pass \"default\" for the default \
                  macOS sound, else the name of a sound in /Library/Sounds or /System/Library/Sounds. \
                  If the sound cannot be found, macOS will use the \"default\" sound.
                  """)
    var sound: String = ""
    // Optional subtitle for the notification
    @Option(help: "The notifications subtitle.")
    var subtitle: String = ""
    // Optional Title for the notification
    @Option(help: "The notifications title.")
    var title: String = ""
    // Option to remove a specific notification or all notifications delivered
    @Option(help: """
                  \"prior\" or \"all\". If passing \"prior\", the full message will be required too. \
                  Including all passed flags.
                  """)
    var remove: String = ""
    // Enables verbose logging
    @Flag(help: "Enables logging of actions. Check console for  'Notifier Log:' messages.")
      var verbose = false
}
