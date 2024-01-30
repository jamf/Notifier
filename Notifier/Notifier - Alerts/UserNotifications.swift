//
//  UserNotifications.swift
//  Notifiers - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// Returns the notifications body
func getNotificationBody(parsedArguments: ParsedArguments) -> String {
    // If verbose mode is enabled
    if parsedArguments.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(parsedArguments.messageBody!)")
    }
    // Return messageBody, forcing as this is set unless we remove all.. and if we aren we won't get here
    return parsedArguments.messageBody!
}

// Returns the notifications body's action
func getNotificationBodyAction(parsedArguments: ParsedArguments) -> [AnyHashable: Any] {
    // Var declaration
    var messageAction = [AnyHashable: Any]()
    // Add taskPath from messagAction to messageAction
    messageAction["taskPath"] = parsedArguments.messageAction?[0].taskPath
    // Add taskArguments from messageAction
    messageAction["taskArguments"] = parsedArguments.messageAction?[0].taskArguments
    // If verbose mode is enabled
    if parsedArguments.verboseMode != "" {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - messageAction - taskPath: \
              \(messageAction["taskPath"] ?? ""), taskArguments: \(messageAction["taskArguments"] ?? [])
              """)
    }
    // Return messageAction
    return messageAction
}

// Returns the notifications sound
func getNotificationSound(parsedArguments: ParsedArguments) -> UNNotificationSound {
    // Var declaration
    var tempSound = UNNotificationSound.default
    // If we're not using macOS's default sound
    if parsedArguments.messageSound?.lowercased() != "default" {
        // Set the notifications sound
        tempSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: parsedArguments.messageSound ?? ""))
    }
    // If verbose mode is enabled
    if parsedArguments.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageSound - set to: \(tempSound)")
    }
    // Return tempSound
    return tempSound
}

// Returns the notifications subtitle
func getNotificationSubtitle(parsedArguments: ParsedArguments) -> String {
    // If verbose mode is enabled
    if parsedArguments.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(parsedArguments.messageSubtitle ?? "")")
    }
    // Return messageSubtitle
    return parsedArguments.messageSubtitle ?? ""
}

// Returns the notifications title
func getNotificationTitle(parsedArguments: ParsedArguments) -> String {
    // If verbose mode is enabled
    if parsedArguments.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(parsedArguments.messageTitle ?? "")")
    }
    // Return messageTitle
    return parsedArguments.messageTitle ?? ""
}

// Handles when a notification is interacted with
func handleNotification(forResponse response: UNNotificationResponse) {
    // Retrieve userInfo from the response object
    let userInfo = response.notification.request.content.userInfo
    // If verboseMode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - message - interacted: \(userInfo)")
    }
    // Triggered when the notification message is clicked
    if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" {
        // If verbose mode is set
        if userInfo["verboseMode"] != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - message - clicked")
        }
        // Performs any actions set when the user clicks the message
        handleNotificationActions(userInfoKey: "messageAction", userInfo: userInfo)
    // If the notification was dismissed
    } else if response.actionIdentifier == "com.apple.UNNotificationDismissActionIdentifier" {
        // If verbose mode is set
        if userInfo["verboseMode"] != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - message - message was dismissed")
        }
    // If the messageButton was clicked
    } else {
        // If verbose mode is set
        if userInfo["verboseMode"] != nil {
            // Progress log
            NSLog("""
                  \(#function.components(separatedBy: "(")[0]) - message button - \
                  clicked - userInfo \(String(describing: userInfo))
                  """)
        }
        // Performs any actions set when the user clicks the messagebutton
        handleNotificationActions(userInfoKey: "messageButtonAction", userInfo: userInfo)
    }
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - message - removing notification")
    }
    // Remove the delivered notification
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:
                                                                        [response.notification.request.identifier])
    // Sleep for a second
    sleep(1)
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - message - removing notification - done")
    }
    // Exit
    exit(0)
}

// Handles when a notification is interacted with
func handleNotificationActions(userInfoKey: String, userInfo: [AnyHashable: Any]) {
    // Var declaration
    var messageActionDict = [String: Any]()
    // If we have a userInfoKey in the notifications userinfo
    if userInfo[userInfoKey] != nil {
        // If verbose mode is set
        if userInfo["verboseMode"] != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - \(userInfoKey) - \(userInfo[userInfoKey] ?? [])")
            // Convert userInfo[userInfoKey] to a dict
            messageActionDict = userInfo[userInfoKey] as? [String: Any] ?? [:]
        }
        // If we have logout as taskPath
        if messageActionDict["taskPath"] as? String == "logout" {
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // Progress log
                NSLog("\(#function.components(separatedBy: "(")[0]) - \(userInfoKey) - logout")
            }
            // Prompt to logout
            gracefulLogout(userInfo: userInfo)
            // If we have an action thaty's not logout
        } else {
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // Progress log
                NSLog("""
                      \(#function.components(separatedBy: "(")[0]) - \(userInfoKey) \
                      - \(String(describing: userInfo[userInfoKey]))
                      """)
            }
            // Run the task, returning boolean
            let taskStatus = runTask(taskPath: messageActionDict["taskPath"] as? String ?? "",
                                                   taskArguments: messageActionDict["taskArguments"]
                                                   as? [String] ?? [], userInfo: userInfo)
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // If the task completed successfully
                if taskStatus {
                    // Progress log
                    NSLog("""
                          Successfully ran: \(messageActionDict["taskPath"] ?? "") \
                          \(messageActionDict["taskArguments"] ?? []).
                          """)
                // If task failed to run
                } else {
                    // Post error to stdout and NSLog if verbose mode is enabled
                        postError(errorMessage: """
                                                ERROR: Running: \(messageActionDict["taskPath"] ?? "")
                                                \(messageActionDict["taskArguments"] ?? []) failed.
                                                """,
                              functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
                }
            }
        }
    }
}

// Post the notification
func postNotification(notificationCenter: UNUserNotificationCenter, notificationContent: UNMutableNotificationContent,
                      parsedArguments: ParsedArguments, passedBase64: String) {
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - notification \
              request - notificationContent - \(notificationContent).
              """)
    }
    // Set the notification to be posted in 1 second
    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    // Create the request object
    let notificationRequest = UNNotificationRequest(identifier: passedBase64, content: notificationContent,
                                                    trigger: notificationTrigger)
    // Post the notification
    notificationCenter.add(notificationRequest)
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notification delivered")
    }
    // Exit
    exit(0)
}

// Adds messageButton (always needed) and messageButtonAction (when defined)
func processMessageButton(notificationCenter: UNUserNotificationCenter, parsedArguments: ParsedArguments) ->
        ([AnyHashable: Any], UNNotificationCategory) {
    // Var declaration
    var tempCategory = UNNotificationCategory(identifier: "alert", actions: [], intentIdentifiers: [],
                                              options: .customDismissAction)
    var messageButtonAction = [AnyHashable: Any]()
    // If we have a value for messageButton passed
    if parsedArguments.messageButton != nil {
        // Create an action object
        let notificationAction = UNNotificationAction(identifier: "messagebutton",
                                                      title: parsedArguments.messageButton ?? "",
                                                      options: .init(rawValue: 0))
        // Amend tempCategory
        tempCategory = UNNotificationCategory(identifier: "alert", actions: [notificationAction],
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
        // If verbose mode is enabled
        if parsedArguments.verboseMode != "" {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - messagebutton processed")
        }
        // If we have a values for messageButton and messageButtonAction passed
        if parsedArguments.messageButtonAction != nil {
            // Add taskPath from messagAction to messageButtonAction
            messageButtonAction["taskPath"] = parsedArguments.messageButtonAction?[0].taskPath
            // Add taskArguments from messageButtonAction
            messageButtonAction["taskArguments"] =
            parsedArguments.messageButtonAction?[0].taskArguments
            // If verbose mode is enabled
            if parsedArguments.verboseMode != "" {
                // Progress log
                NSLog("""
                      \(#function.components(separatedBy: "(")[0]) - messageButtonAction - taskPath: \
                      \(messageButtonAction["taskPath"] ?? ""),
                      taskArguments: \(messageButtonAction["taskArguments"] ?? [])
                      """)
            }
            // Return tempCategory and tempUserInfo
            return (messageButtonAction, tempCategory)
        }
        // If we don't have a value for messageButton
    } else {
        // If verbose mode is enabled
        if parsedArguments.verboseMode != "" {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - no messagebutton defined")
        }
    }
    // Return empty userInfo for messageButtonAction and tempCategory
    return ([:], tempCategory)
}

// If we're to remove a specific prior posted notification
func removePriorNotification(notificationCenter: UNUserNotificationCenter, parsedArguments: ParsedArguments,
                             passedBase64: String) {
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior - passedBase64 - \(passedBase64)")
    }
    // Remove any prior notifications with the same identifier as ncContentbase64
    notificationCenter.removeDeliveredNotifications(withIdentifiers: [passedBase64])
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior - done")
    }
    // Exit
    exit(0)
}

// If we're to remove all prior posted notifications
func removeAllPriorNotifications(notificationCenter: UNUserNotificationCenter, parsedArguments: ParsedArguments) {
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Verbose message
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove all")
    }
    // Remove all delivered notifications
    notificationCenter.removeAllDeliveredNotifications()
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if parsedArguments.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove all - done")
    }
    // Exit
    exit(0)
}

// Request authorisation
func requestAuthorisation(verboseMode: String) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
        // If we're not been granted authorization to post notifications
        if !granted {
            // Post error to stdout and NSLog if verbose mode is enabled
            postError(errorMessage: "ERROR: Authorisation not granted, exiting...",
                      functionName: #function.components(separatedBy: "(")[0],
                      verboseMode: verboseMode)
            // Exit
            exit(1)
        }
    }
}

// Respond to notification message click
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    // Get the interacted notification
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewNotification"),
                                    object: nil,
                                    userInfo: response.notification.request.content.userInfo)
    // Handle the response
    handleNotification(forResponse: response)
}

// Ensure that notification is shown, even if app is active
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping
                            (UNNotificationPresentationOptions) -> Void) {
    // Raise an error if there is an issue with completionHandler
    completionHandler(.alert)
}
