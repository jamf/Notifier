//
//  UserNotifications.swift
//  Notifiers - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// Returns the notifications body
func getNotificationBody(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(messageContent.messageBody!)")
    }
    // Return messageBody, forcing as this is set unless we remove all.. and if we aren we won't get here
    return messageContent.messageBody!
}

// Returns the notifications body's action
func getNotificationBodyAction(messageContent: MessageContent, rootElements: RootElements) -> [AnyHashable: Any] {
    // Var declaration
    var messageAction = [AnyHashable: Any]()
    // Add taskPath from messagAction to messageAction
    messageAction["taskPath"] = messageContent.messageAction?[0].taskPath
    // Add taskArguments from messageAction
    messageAction["taskArguments"] = messageContent.messageAction?[0].taskArguments
    // If verbose mode is enabled
    if rootElements.verboseMode != "" {
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
func getNotificationSound(messageContent: MessageContent, rootElements: RootElements) -> UNNotificationSound {
    // Var declaration
    var tempSound = UNNotificationSound.default
    // If we're not using macOS's default sound
    if messageContent.messageSound?.lowercased() != "default" {
        // Set the notifications sound
        tempSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: messageContent.messageSound ?? ""))
    }
    // If verbose mode is enabled
    if rootElements.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageSound - set to: \(tempSound)")
    }
    // Return tempSound
    return tempSound
}

// Returns the notifications subtitle
func getNotificationSubtitle(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(messageContent.messageSubtitle ?? "")")
    }
    // Return messageSubtitle
    return messageContent.messageSubtitle ?? ""
}

// Returns the notifications title
func getNotificationTitle(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != "" {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(messageContent.messageTitle ?? "")")
    }
    // Return messageTitle
    return messageContent.messageTitle ?? ""
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
        processNotificationActions(userInfoKey: "messageAction", userInfo: userInfo)
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
        processNotificationActions(userInfoKey: "messageButtonAction", userInfo: userInfo)
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

// Adds messageButton (always needed) and messageButtonAction (when defined)
func processMessageButton(notificationCenter: UNUserNotificationCenter, messageContent: MessageContent,
                          rootElements: RootElements) ->
        ([AnyHashable: Any], UNNotificationCategory) {
    // Var declaration
    var tempCategory = UNNotificationCategory(identifier: "alert", actions: [], intentIdentifiers: [],
                                              options: .customDismissAction)
    var messageButtonAction = [AnyHashable: Any]()
    // If we have a value for messageButton passed
    if messageContent.messageButton != nil {
        // Create an action object
        let notificationAction = UNNotificationAction(identifier: "messagebutton",
                                                      title: messageContent.messageButton ?? "",
                                                      options: [])
        // Amend tempCategory
        tempCategory = UNNotificationCategory(identifier: "alert", actions: [notificationAction],
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
        // If verbose mode is enabled
        if rootElements.verboseMode != "" {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - messagebutton processed")
        }
        // If we have a values for messageButton and messageButtonAction passed
        if messageContent.messageButtonAction != nil {
            // Add taskPath from messagAction to messageButtonAction
            messageButtonAction["taskPath"] = messageContent.messageButtonAction?[0].taskPath
            // Add taskArguments from messageButtonAction
            messageButtonAction["taskArguments"] =
            messageContent.messageButtonAction?[0].taskArguments
            // If verbose mode is enabled
            if rootElements.verboseMode != "" {
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
        if rootElements.verboseMode != "" {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - no messagebutton defined")
        }
    }
    // Return empty userInfo for messageButtonAction and tempCategory
    return ([:], tempCategory)
}

// Process actions when interacted
func processNotificationActions(userInfoKey: String, userInfo: [AnyHashable: Any]) {
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
                NSLog("\(#function.components(separatedBy: "(")[0]) - \(userInfoKey) - \(userInfo[userInfoKey] ?? [])")
            }
            // Run the task, returning boolean
            let (taskOutput, taskStatus) = runTask(taskPath: messageActionDict["taskPath"] as? String ?? "",
                                                   taskArguments: messageActionDict["taskArguments"]
                                                   as? [String] ?? [], userInfo: userInfo)
            // If verbose mode is set
            if userInfo["verboseMode"] != nil {
                // If the task completed successfully
                if taskStatus {
                    // Progress log
                    NSLog("""
                          "\(messageActionDict["taskPath"] ?? "") \(messageActionDict["taskArguments"] ?? [])"
                          completed successfully, returned output: \(taskOutput)
                          """)
                // If task failed to run
                } else {
                    // Post error to stdout and NSLog if verbose mode is enabled
                        postError(errorMessage: """
                                                Running: \(messageActionDict["taskPath"] ?? "")
                                                \(messageActionDict["taskArguments"] ?? []) failed with \(taskOutput).
                                                """,
                                  functionName: #function.components(separatedBy: "(")[0], verboseMode: "enabled")
                }
            }
        }
    }
}

// Post the notification
func postNotification(notificationCenter: UNUserNotificationCenter, notificationContent: UNMutableNotificationContent,
                      messageContent: MessageContent, passedBase64: String, rootElements: RootElements) {
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
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
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notification delivered")
    }
    // Exit
    exit(0)
}

// If we're to remove a specific prior posted notification
func removePriorNotification(notificationCenter: UNUserNotificationCenter, messageContent: MessageContent,
                             passedBase64: String, rootElements: RootElements) {
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior - passedBase64 - [\(passedBase64)]")
    }
    // Remove any prior notifications with the same identifier as ncContentbase64
    notificationCenter.removeDeliveredNotifications(withIdentifiers: [passedBase64])
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior - done")
    }
    // Exit
    exit(0)
}

// If we're to remove all prior posted notifications
func removeAllPriorNotifications(notificationCenter: UNUserNotificationCenter, messageContent: MessageContent,
                                 rootElements: RootElements) {
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Verbose message
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove all")
    }
    // Remove all delivered notifications
    notificationCenter.removeAllDeliveredNotifications()
    // Sleep for a second
    sleep(1)
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
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
            postError(errorMessage: "Authorisation not granted to post notifications, exiting...",
                      functionName: #function.components(separatedBy: "(")[0],
                      verboseMode: verboseMode)
            // Exit
            exit(1)
        }
    }
}
