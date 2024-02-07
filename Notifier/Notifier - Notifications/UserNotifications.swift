//
//  UserNotifications.swift
//  Notifiers - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// Returns the notifications body
func getNotificationBody(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
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
    if rootElements.verboseMode != nil {
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
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageSound - set to: \(tempSound)")
    }
    // Return tempSound
    return tempSound
}

// Returns the notifications subtitle
func getNotificationSubtitle(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(messageContent.messageSubtitle ?? "")")
    }
    // Return messageSubtitle
    return messageContent.messageSubtitle ?? ""
}

// Returns the notifications title
func getNotificationTitle(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
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
    // If verbose mode is set
    if userInfo["verboseMode"] != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - message - removing notification - done")
    }
    // Exit
    exit(0)
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
    // Create the request object
    let notificationRequest = UNNotificationRequest(identifier: passedBase64, content: notificationContent,
                                                    trigger: nil)
    // Post the notification
    notificationCenter.add(notificationRequest)
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - notification delivered")
    }
    // Sleep, so we don't exit before the notification has been delivered
    sleep(1)
    // Exit
    exit(0)
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
        }
        // Convert userInfo[userInfoKey] to a dict
        messageActionDict = userInfo[userInfoKey] as? [String: Any] ?? [:]
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
                    // Post error
                    postToNSLogAndStdOut(logLevel: "ERROR", logMessage:
                                         """
                                         Running: \(messageActionDict["taskPath"] ?? "")
                                         \(messageActionDict["taskArguments"] ?? []) failed with \(taskOutput).
                                         """, functionName: #function.components(separatedBy: "(")[0],
                                         verboseMode: "enabled")
                }
            }
        }
    }
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
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove prior - done")
    }
    // Sleep, so we don't exit before notification(s) have been removed
    sleep(1)
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
    // If we're in verbose mode
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - remove all - done")
    }
    // Sleep, so we don't exit before notification(s) have been removed
    sleep(1)
    // Exit
    exit(0)
}

// Request authorisation
func requestAuthorisation(verboseMode: String) {
        // Check authorization status with the UNUserNotificationCenter object
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
        if !granted {
            // Post error
            postToNSLogAndStdOut(logLevel: "ERROR", logMessage: """
                                 Authorisation not granted to post notifications, either manually approve \
                                 notifications for this application or deploy a Notification PPPCP to this Mac, and \
                                 try posting the message again...
                                 """, functionName: #function.components(separatedBy: "(")[0],
                                 verboseMode: "verboseMode")
            // Exit
            exit(1)
        }
    }
}
