//
//  ArgParser.swift
//  Notifier
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import ArgumentParser
import Foundation

// Struct for ArgParser
struct ArgParser: ParsableCommand {
    // Set overview and usage text
    static let configuration = CommandConfiguration(
        abstract: """
                  Notifier \(String(describing:
                                    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)): \
                  Posts alert or banner notifications.
                  """,
        usage: """
               --type <alert/banner> --message <some message> <options>
               --type <alert/banner> --remove prior <some message> <options>
               --type <alert/banner> --remove all
               --rebrand <path to image>
               """,
        helpNames: [.long]
    )
    // Required - notification type
    @Option(help: """
                  alert or banner - REQUIRED.

                  """)
    var type: String = ""
    // The notifications message
    @Option(help: """
                  The notifications message.

                  """)
    var message: String = ""
    // Optional action
    @Option(help: """
                  The action to be performed under the users account when the message is clicked.

                  • Passing 'logout' will prompt the user to logout.
                  • If passed a single item, this will be launched via: /usr/bin/open
                  • More complex commands can be passed, but the 1st argument needs to be a binaries path.

                  For example: \"/usr/bin/open\" will work, \"open\" will not.

                  """)
    var messageaction: String = ""
    // Optional message button text
    @Option(help: """
                  Adds a button to the message, with the label being what is passed.

                  """)
    var messagebutton: String = ""
    // Optional action when the alert button is clicked
    @Option(help: """
                  The action to be performed under the users account when the optional message button is clicked.

                  • Passing 'logout' will prompt the user to logout.
                  • If passed a single item, this will be launched via: /usr/bin/open
                  • More complex commands can be passed, but the 1st argument needs to be a binaries path.

                  For example: \"/usr/bin/open\" will work, \"open\" will not.

                  """)
    var messagebuttonaction: String = ""
    // Triggers rebrand function
    @Option(help: """
                  Requires root privileges and that the calling process needs either Full Disk Access (10.15+) or at \
                  a minimum App Management (macOS 13+) permissions, as well as the notifying applications being given \
                  permission to post to Notification Center. Any of these permissions can be granted manually, but \
                  ideally via PPPCP's delivered via an MDM.

                  If successful and someone is logged in, Notification Center is restarted.

                  """)
    var rebrand: String = ""
    // Option to remove a specific notification or all notifications delivered
    @Option(help: """
                  \"prior\" or \"all\". If passing \"prior\", the full message will be required too. \
                  Including all passed flags.

                  """)
    var remove: String = ""
    // Optional sound to play when notification is delivered
    @Option(help: """
                  The sound to play when notification is delivered. Pass \"default\" for the default \
                  macOS sound, else the name of a sound in /Library/Sounds or /System/Library/Sounds.

                  If the sound cannot be found, macOS will use the \"default\" sound.

                  """)
    var sound: String = ""
    // Optional subtitle for the notification
    @Option(help: """
                  The notifications subtitle.

                  """)
    var subtitle: String = ""
    // Optional Title for the notification
    @Option(help: """
                  The notifications title.

                  """)
    var title: String = ""
    // Enables verbose logging
    @Flag(help: """
                Enables logging of actions. Check console for 'Notifier' messages.

                """)
    var verbose = false
}
