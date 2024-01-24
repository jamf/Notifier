//
//  UserNotifications.swift
//  Notifier - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// Add the notifications body
func addNotificationBody(ncContent: UNMutableNotificationContent, notificationString: String,
                         parsedResult: ArgParser) -> (UNMutableNotificationContent, String) {
    // Var declaration
    var tempString = notificationString
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - message")
    }
    // Set the message to the body of the notification
    ncContent.body = parsedResult.message
    // Append to tempString
    tempString += ncContent.body
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - notificationString - %@", notificationString)
    }
    // Return the modified vars
    return(ncContent, tempString)
}

// Adds an action to the notification body
func addNotificationBodyAction(ncContent: UNMutableNotificationContent, notificationString: String,
                               parsedResult: ArgParser) -> (UNMutableNotificationContent, String) {
    // Var declaration
    var tempString = notificationString
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - message")
    }
    // The action, in lowecase is logout
    if parsedResult.messageaction.lowercased() == "logout" {
        // Set the action in .userinfo to logout
        ncContent.userInfo["messageAction"] = "logout"
        // Append action to notificationString
        tempString += "logout"
        // Append type to notificationString
        tempString += "banner"
        // If we're in verbose mode
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
        }
    // If the action isn't logout
    } else {
        // Set the action in .userinfo
        ncContent.userInfo["messageAction"] = parsedResult.messageaction
        // Append type to notificationString
        tempString += "\(String(describing: parsedResult.messageaction))"
        // If we're in verbose mode
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
        }
    }
    // Return the modified vars
    return(ncContent, tempString)
}

// Adds a sound to the notification, which is played on delivery
func addNotificationSound(ncContent: UNMutableNotificationContent, notificationString: String,
                          parsedResult: ArgParser) -> (UNMutableNotificationContent, String) {
    // Var declaration
    var tempString = notificationString
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - sound")
    }
    // If we've been passed default for the sound
    if parsedResult.sound.lowercased() == "default" {
        // Set the notifications sound, to macOS's default
        ncContent.sound = UNNotificationSound.default
        // Append to notificationString
        tempString += "\(String(describing: ncContent.sound))"
        // If we're in verbose mode
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
        }
    // If we've been passed another sound
    } else {
        // Set the notifications sound
        ncContent.sound = UNNotificationSound(named:
                                                UNNotificationSoundName(rawValue:
                                                                            parsedResult.sound))
        // Append to notificationString
        tempString += "\(String(describing: ncContent.sound))"
        // If we're in verbose mode
        if parsedResult.verbose {
            // Progress log
            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
        }
    }
    // Return the modified vars
    return(ncContent, tempString)
}

// Adds a subtitle to the notification
func addNotificationSubtitle(ncContent: UNMutableNotificationContent, notificationString: String,
                             parsedResult: ArgParser) -> (UNMutableNotificationContent, String) {
    // Var declaration
    var tempString = notificationString
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - subtitle")
    }
    // Set the notifications subtitle
    ncContent.subtitle = parsedResult.subtitle
    // Append to notificationString
    tempString += ncContent.subtitle
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - notificationString - %@", notificationString)
    }
    // Return the modified vars
    return(ncContent, tempString)
}

// Adds a title to the notification
func addNotificationTitle(ncContent: UNMutableNotificationContent, notificationString: String,
                          parsedResult: ArgParser) -> (UNMutableNotificationContent, String) {
    // Var declaration
    var tempString = notificationString
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - title")
    }
    // Set the notifications title
    ncContent.title = parsedResult.title
    // Append to notificationString
    tempString += ncContent.title
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - notificationString - %@", notificationString)
    }
    // Return the modified vars
    return(ncContent, tempString)
}

// Process userinfo for UNNotification
func handleUNNotification(forResponse response: UNNotificationResponse) {
    // Var declarations
    var verboseMode = false
    var messageDismissed = true
    // Retrieve userInfo from the response object
    let userInfo = response.notification.request.content.userInfo
    // If verboseMode is set
    if userInfo["verboseMode"] != nil {
        // Then enable verboseMode
        verboseMode = true
        // Progress log
        NSLog("Notifier Log: banner - message - interacted")
    }
    // If the response actionIdentifier is ths default one
    if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" {
        // If verbose mode is set
        if verboseMode {
            // Progress log
            NSLog("Notifier Log: banner - message - clicked")
            // Progress log
            NSLog("Notifier Log: banner - message - userInfo %@", String(describing: userInfo))
        }
        // If the notification has a messageAction
        if userInfo["messageAction"] != nil {
            // If the notification's messageAction is logout
            if (userInfo["messageAction"] as? String) == "logout" {
                // If verbose mode is set
                if verboseMode {
                    // Progress log
                    NSLog("Notifier Log: banner - message - logout")
                }
                // Prompt to logout
                gracefullLogout(verboseMode: verboseMode)
                // Set messageDismissed to false
                messageDismissed = false
            // If the messageAction is something else
            } else {
                // If verbose mode is set
                if verboseMode {
                    // Progress log
                    NSLog("Notifier Log: banner - message - %@", String(describing: userInfo["messageAction"]))
                }
                // Open the requested item
                openItem(globalOpenItem: [(userInfo["messageAction"] as? String)!], verboseMode: verboseMode)
                // Set messageDismissed to false
                messageDismissed = false
            }
        }
    }
    // If verbose mode is set and the notification was dismissed
    if verboseMode && messageDismissed {
        // Progress log
        NSLog("Notifier Log: banner - message - dismissed by user")
    }
    // If verbose mode is set
    if verboseMode {
        // Progress log
        NSLog("Notifier Log: banner - message - removing notification")
    }
    // Remove the delivered notification
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:
                                                                        [response.notification.request.identifier])
    // Sleep for a second
    sleep(1)
    // If verbose mode is set
    if verboseMode {
        // Progress log
        NSLog("Notifier Log: banner - message - removing notification - done")
    }
    // Exit
    exit(0)
}

// Post the notification
func postNotification(ncCenter: UNUserNotificationCenter, ncContent: UNMutableNotificationContent,
                      notificationString: String, parsedResult: ArgParser) {
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - notification request")
    }
    // Convert notificationString into base64
    let ncContentbase64 = base64String(stringContent: notificationString)
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - ncContentbase64 - %@", ncContentbase64)
    }
    // Set the notification to be posted in 1 second
    let ncTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    // Create the request object
    let ncRequest = UNNotificationRequest(identifier: ncContentbase64,
                                          content: ncContent, trigger: ncTrigger)
    // Post the notification
    ncCenter.add(ncRequest)
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - notification delivered")
    }
    // Exit
    exit(0)
}
// If we're to remove a specific prior posted notification
func removePriorNotification(ncCenter: UNUserNotificationCenter, notificationString: String, parsedResult: ArgParser) {
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - remove prior")
    }
    // Convert notificationString into base64
    let ncContentbase64 = base64String(stringContent: notificationString)
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - ncContentbase64 - %@", ncContentbase64)
    }
    // Remove any prior notifications with the same identifier as ncContentbase64
    ncCenter.removeDeliveredNotifications(withIdentifiers: [ncContentbase64])
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - remove prior - done")
    }
    // Exit
    exit(0)
}

// If we're to remove all prior posted notifications
func removeAllPriorNotifications(ncCenter: UNUserNotificationCenter, parsedResult: ArgParser) {
    // If we're in verbose mode
    if parsedResult.verbose {
        // Verbose message
        NSLog("Notifier Log: banner - ncRemove all")
    }
    // Remove all delivered notifications
    ncCenter.removeAllDeliveredNotifications()
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedResult.verbose {
        // Progress log
        NSLog("Notifier Log: banner - ncRemove all - done")
    }
    // Exit
    exit(0)
}

// Request authorisation
func requestAuthorisation(verboseMode: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
        // If we're not been granted authorization to post notifications
        if !granted {
            // Print error
            print("ERROR: Authorisation not granted, exiting...")
            // If verbose mode is set
            if verboseMode {
                // Progress log
                NSLog("Notifier Log: banner - ERROR: Authorisation not granted, exiting...")
            }
            // Exit 1
            exit(1)
        }
    }
}

// Respond notification message click
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    // Get the interacted notification
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewNotification"),
                                    object: nil, userInfo: response.notification.request.content.userInfo)
    // Handle the response
    handleUNNotification(forResponse: response)
}

// Ensure that notification is shown, even if app is active
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping
                            (UNNotificationPresentationOptions) -> Void) {
    // Raise an error is an issue with completionHandler
    completionHandler(.alert)
}
