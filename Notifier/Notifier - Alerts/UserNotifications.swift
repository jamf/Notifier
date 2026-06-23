//
//  UserNotifications.swift
//  Notifiers - Alerts
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import UserNotifications

// If we cannot post notifications
func authorisationNotGranted(statusDescription: String, verboseMode: String) {
    // Post error to NSLog and std out
    postToNSLogAndStdOut(logLevel: "ERROR", logMessage: """
                         Authorisation status: \(statusDescription). Either manually approve notifications for this \
                         application or deploy a Notification PPPCP to this Mac, and try posting the notification again.
                         """, functionName: #function.components(separatedBy: "(")[0],
                         verboseMode: verboseMode)
    // Exit
    exit(1)
}

// Returns the notifications body
func getNotificationBody(messageContent: MessageContent, rootElements: RootElements) -> String {
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messageBody: \(messageContent.messageBody!)")
    }
    // Return messageBody, forcing as this is set unless we remove all.. and if we aren't we won't get here
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

// Maps a notification action identifier to a userInfo key and a log message
func resolveNotificationAction(for actionIdentifier: String) -> (userInfoKey: String?, logMessage: String?) {
    // Switch on the action identifier to determine which action to perform
    switch actionIdentifier {
    // The notification message body was clicked
    case "com.apple.UNNotificationDefaultActionIdentifier":
        // Return the messageAction key and its log message
        return ("messageAction", "message - clicked")
    // The notification was dismissed without interaction
    case "com.apple.UNNotificationDismissActionIdentifier":
        // Return the messageDismissAction key and its log message
        return ("messageDismissAction", "message - dismissed")
    // The first message button was clicked
    case "messagebutton":
        // Return the messageButtonAction key and its log message
        return ("messageButtonAction", "message button - clicked")
    // The second message button was clicked
    case "messagebutton2":
        // Return the messageButton2Action key and its log message
        return ("messageButton2Action", "message button 2 - clicked")
    // Unknown action identifier - no action to perform
    default:
        // Return nil for both - no known action or log message for this identifier
        return (nil, nil)
    }
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
    // Resolve the action identifier to a userInfo key and log message
    let (actionKey, logMessage) = resolveNotificationAction(for: response.actionIdentifier)
    // If verbose mode is set and there is a log message for this action
    if userInfo["verboseMode"] != nil, let logMessage = logMessage {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - \(logMessage)")
    }
    // If there is a userInfo key for this action, process the associated action
    if let actionKey = actionKey {
        // Performs any actions set for this interaction type
        processNotificationActions(userInfoKey: actionKey, userInfo: userInfo)
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

// Builds an action dictionary from the first element of a TaskObject array
func buildButtonActionDict(taskObjects: [MessageContent.TaskObject],
                           verboseLabel: String, rootElements: RootElements) -> [AnyHashable: Any] {
    // Var declaration
    var actionDict = [AnyHashable: Any]()
    // Add taskPath to the action dictionary
    actionDict["taskPath"] = taskObjects[0].taskPath
    // Add taskArguments to the action dictionary
    actionDict["taskArguments"] = taskObjects[0].taskArguments
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("""
              \(#function.components(separatedBy: "(")[0]) - \(verboseLabel) - taskPath: \
              \(actionDict["taskPath"] ?? ""),
              taskArguments: \(actionDict["taskArguments"] ?? [])
              """)
    }
    // Return the populated action dictionary
    return actionDict
}

// Handles the second message button, updating the category to include both buttons
func processMessageButton2(notificationAction: UNNotificationAction, messageContent: MessageContent,
                           rootElements: RootElements) ->
        ([AnyHashable: Any], UNNotificationCategory) {
    // Create an action object for the second button
    let notificationAction2 = UNNotificationAction(identifier: "messagebutton2",
                                                   title: messageContent.messageButton2 ?? "",
                                                   options: [])
    // Build a category that includes both button actions
    let updatedCategory = UNNotificationCategory(identifier: "alert",
                                                 actions: [notificationAction, notificationAction2],
                                                 intentIdentifiers: [],
                                                 options: .customDismissAction)
    // If verbose mode is enabled
    if rootElements.verboseMode != nil {
        // Progress log
        NSLog("\(#function.components(separatedBy: "(")[0]) - messagebutton2 processed")
    }
    // If a second button action was also passed, build and return the action dictionary
    if messageContent.messageButton2Action != nil {
        // Build the second button action dictionary
        let messageButton2Action = buildButtonActionDict(taskObjects: messageContent.messageButton2Action!,
                                                        verboseLabel: "messageButton2Action",
                                                        rootElements: rootElements)
        // Return the second button action dict and the updated category
        return (messageButton2Action, updatedCategory)
    }
    // Return an empty action dict and the updated category
    return ([:], updatedCategory)
}

// Adds messageButton (always needed), messageButtonAction, messageButton2 and messageButton2Action (when defined)
func processMessageButton(notificationCenter: UNUserNotificationCenter, messageContent: MessageContent,
                          rootElements: RootElements) ->
        ([AnyHashable: Any], [AnyHashable: Any], UNNotificationCategory) {
    // Var declaration
    var tempCategory = UNNotificationCategory(identifier: "alert", actions: [], intentIdentifiers: [],
                                              options: .customDismissAction)
    // Var declaration for the second message button action
    var messageButton2Action = [AnyHashable: Any]()
    // If we have a value for messageButton passed
    if messageContent.messageButton != nil {
        // Create an action object for the first button
        let notificationAction = UNNotificationAction(identifier: "messagebutton",
                                                      title: messageContent.messageButton ?? "",
                                                      options: [])
        // Amend tempCategory to include the first button action
        tempCategory = UNNotificationCategory(identifier: "alert", actions: [notificationAction],
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
        // If verbose mode is enabled
        if rootElements.verboseMode != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - messagebutton processed")
        }
        // If a second message button label was also passed
        if messageContent.messageButton2 != nil {
            // Process the second button, updating the category to include both buttons
            (messageButton2Action, tempCategory) = processMessageButton2(notificationAction: notificationAction,
                                                                         messageContent: messageContent,
                                                                         rootElements: rootElements)
        }
        // If we have values for messageButton and messageButtonAction passed
        if messageContent.messageButtonAction != nil {
            // Build the first button action dictionary
            let messageButtonAction = buildButtonActionDict(taskObjects: messageContent.messageButtonAction!,
                                                            verboseLabel: "messageButtonAction",
                                                            rootElements: rootElements)
            // Return messageButtonAction, messageButton2Action and tempCategory
            return (messageButtonAction, messageButton2Action, tempCategory)
        }
    // If we don't have a value for messageButton
    } else {
        // If verbose mode is enabled
        if rootElements.verboseMode != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - no messagebutton defined")
        }
    }
    // Return empty dicts for messageButtonAction and messageButton2Action, along with tempCategory
    return ([:], [:], tempCategory)
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
    // Post the notification, using the completion handler to catch any scheduling errors
    notificationCenter.add(notificationRequest) { error in
        // If the notification failed to schedule
        if let error = error {
            // Post error
            postToNSLogAndStdOut(logLevel: "ERROR",
                                 logMessage: "Failed to post notification: \(error.localizedDescription)",
                                 functionName: #function.components(separatedBy: "(")[0],
                                 verboseMode: rootElements.verboseMode ?? "")
            // Exit
            exit(1)
        }
        // If we're in verbose mode
        if rootElements.verboseMode != nil {
            // Progress log
            NSLog("\(#function.components(separatedBy: "(")[0]) - notification scheduled")
        }
        // Sleep, so we don't exit before the notification has been delivered
        sleep(1)
        // Check with Notification Center what was delivered
        notificationCenter.getDeliveredNotifications { notifications in
            // Find the notification we posted by its identifier
            if notifications.first(where: { $0.request.identifier == passedBase64 }) != nil {
                // Post progress...
                postToNSLogAndStdOut(logLevel: "INFO", logMessage: "notification delivered successfully!",
                                     functionName: #function.components(separatedBy: "(")[0],
                                     verboseMode: rootElements.verboseMode ?? "")
            // If we cannot find the notification we posted...
            } else {
                // Post warning...
                postToNSLogAndStdOut(logLevel: "WARNING", logMessage:
                                     """
                                     Notification delivered but not shown as DND/Focus mode is enabled. The \
                                     notification can be found within Notification Centre.
                                     """,
                                     functionName: #function.components(separatedBy: "(")[0],
                                     verboseMode: rootElements.verboseMode ?? "")
                // Exit with code 2 to indicate notification was not shown.
                exit(2)
            }
            // Exit
            exit(0)
        }
    }
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
    // Post success...
    postToNSLogAndStdOut(logLevel: "INFO", logMessage: "removed requested prior delivered alert notification!",
                         functionName: #function.components(separatedBy: "(")[0],
                         verboseMode: rootElements.verboseMode ?? "")
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
    // Post success...
    postToNSLogAndStdOut(logLevel: "INFO", logMessage: "removed all prior delivered alert notifications!",
                         functionName: #function.components(separatedBy: "(")[0],
                         verboseMode: rootElements.verboseMode ?? "")
    // Sleep, so we don't exit before notification(s) have been removed
    sleep(1)
    // Exit
    exit(0)
}

// Check authorisation status, exit if not granted
func requestAuthorisation(verboseMode: String) async {
    // Attempt to request authorisation, catching any system-level errors
    do {
        // Request authorization, capturing the result as a variable
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
        // If authorisation was not granted
        if !granted {
            // Check whether authorisation is denied or not yet determined
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            // Declare a human-readable description of the authorisation status
            let statusDescription: String
            // Switch on the status to produce a descriptive string
            switch settings.authorizationStatus {
            // Authorisation was explicitly denied by the user
            case .denied:
                statusDescription = "denied"
            // Authorisation has not been approved yet
            case .notDetermined:
                statusDescription = "not approved"
            // Any other status that does not permit notifications
            default:
                statusDescription = "not granted (status: \(settings.authorizationStatus.rawValue))"
            }
            // Post authorisation error
            authorisationNotGranted(statusDescription: statusDescription, verboseMode: verboseMode)
        }
    // If the authorisation request itself threw an error...
    } catch {
        // If we get here, then the status is: "not approved"
        authorisationNotGranted(statusDescription: "not approved", verboseMode: verboseMode)
    }
}
