//
//  AppDelegate.swift
//  Notifier Alerts
//
//  Copyright © 2020 dataJAR Ltd. All rights reserved.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    // Gimme some applicationDidFinishLaunching
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let actionIdentifier = "alert"
        var notificationString = ""
        var verboseMode = false

        // Exit if notificaiton center isn't running for the user
        guard !NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.notificationcenterui").isEmpty else {
            print("ERROR: Notification Center is not running...")
            exit(1)
        }

        // Ask permission, 10.15+ only
        if #available(macOS 10.15, *) {
            requestAuthorisation(verboseMode: verboseMode)
        }

        // See if we have any .userInfo when launched on, such as from user interaction
        if #available(macOS 10.15, *) {
            if let response = (aNotification as NSNotification).userInfo?[NSApplication.launchUserNotificationUserInfoKey] as? UNNotificationResponse {
                handleUNNotification(forResponse: response)
            }
        } else {
            if let notification = (aNotification as NSNotification).userInfo![NSApplication.launchUserNotificationUserInfoKey] as? NSUserNotification {
                handleNSUserNotification(forNotification: notification)
            }
        }

        // Parse arguments & post notification
        do {

            let passedArgs = Array(CommandLine.arguments.dropFirst())
            let parsedResult = try argParser.parse(passedArgs)

            verboseMode = parsedResult.verbose

            if verboseMode {
                NSLog("Notifier Log: alert - verbose enabled")
            }

            // User UNUser API's for 10.15+, NSUser for older
            if #available(macOS 10.15, *) {

                if verboseMode {
                    NSLog("Notifier Log: alert - running on 10.15+")
                }

                let ncCenter =  UNUserNotificationCenter.current()
                let ncContent = UNMutableNotificationContent()

                ncCenter.delegate = self

                if verboseMode {
                    ncContent.userInfo["verboseMode"] = "enabled"
                }

                if parsedResult.remove?.lowercased() == "all" {
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncRemove all")
                    }
                    ncCenter.removeAllDeliveredNotifications()
                    sleep(1)
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncRemove all - done")
                    }
                    exit(0)

                } else {

                    if (parsedResult.message != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - ncMessage")
                        }
                        ncContent.body = parsedResult.message!
                        notificationString += ncContent.body
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.messageaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messageaction")
                        }
                        if parsedResult.messageaction?.lowercased() == "logout" {
                            ncContent.userInfo["messageAction"] = "logout"
                            notificationString += "logout"
                            notificationString += actionIdentifier
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        } else {
                            ncContent.userInfo["messageAction"] = parsedResult.messageaction!
                            notificationString += "\(String(describing: parsedResult.messageaction))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.messagebutton != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebutton")
                        }
                        let actionTitle = parsedResult.messagebutton
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebutton - %@", "\(String(describing: parsedResult.messagebutton))")
                        }
                        let ncAction = UNNotificationAction(identifier: "messagebutton", title: actionTitle!, options: .init(rawValue: 0))
                        let ncCategory = UNNotificationCategory(identifier: actionIdentifier, actions: [ncAction], intentIdentifiers: [], options: .customDismissAction)
                        ncCenter.setNotificationCategories([ncCategory])
                        ncContent.categoryIdentifier = actionIdentifier
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: alert - no messagebutton")
                        }
                        let ncCategory = UNNotificationCategory(identifier: actionIdentifier, actions: [], intentIdentifiers: [], options: .customDismissAction)
                        ncCenter.setNotificationCategories([ncCategory])
                        ncContent.categoryIdentifier = actionIdentifier
                    }

                    if (parsedResult.messagebuttonaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebuttonaction")
                        }
                        if parsedResult.messagebuttonaction!.lowercased() == "logout" {
                            ncContent.userInfo["messageButtonAction"] = "logout"
                            notificationString += "logout"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        } else {
                            ncContent.userInfo["messageButtonAction"] = parsedResult.messagebuttonaction!
                            notificationString += "\(String(describing: parsedResult.messagebuttonaction))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.sound != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - sound")
                        }
                        if parsedResult.sound?.lowercased() == "default" {
                            ncContent.sound = UNNotificationSound.default
                            notificationString += "\(String(describing: ncContent.sound))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        } else {
                            ncContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: parsedResult.sound!))
                            notificationString += "\(String(describing: ncContent.sound))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.subtitle != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - subtitle")
                        }
                        ncContent.subtitle = parsedResult.subtitle!
                        notificationString += ncContent.subtitle
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.title != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - ncTitle")
                        }
                        ncContent.title = parsedResult.title!
                        notificationString += ncContent.title
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    let ncContentbase64 = base64String(stringContent: notificationString)
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncContentbase64 - %@", ncContentbase64)
                    }

                    if parsedResult.remove?.lowercased() == "prior" {
                        if verboseMode {
                            NSLog("Notifier Log: alert - ncRemove prior")
                        }
                        ncCenter.removeDeliveredNotifications(withIdentifiers: [ncContentbase64])
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: alert - ncRemove prior - done")
                        }
                        exit(0)
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: alert - notification request")
                        }
                        let ncTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let ncRequest = UNNotificationRequest(identifier: ncContentbase64, content: ncContent, trigger: ncTrigger)
                        ncCenter.add(ncRequest)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: alert - notification delivered")
                        }
                        exit(0)
                    }
                }

            } else {

                if verboseMode {
                    NSLog("Notifier Log: alert - running on 10.10 - 10.14")
                }

                let ncCenter =  NSUserNotificationCenter.default
                let ncContent = NSUserNotification()
                var userInfoDict:[String:Any] = [:]

                ncCenter.delegate = self

                if verboseMode {
                    userInfoDict["verboseMode"] = "enabled"
                }

                if parsedResult.remove?.lowercased() == "all" {
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncRemove all")
                    }
                    ncCenter.removeAllDeliveredNotifications()
                    sleep(1)
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncRemove all - done")
                    }
                    exit(0)

                } else {

                    if (parsedResult.message != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - message")
                        }
                        ncContent.informativeText = parsedResult.message
                        notificationString += "\(String(describing: ncContent.informativeText))"
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.messageaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messageaction")
                        }
                        if parsedResult.messageaction?.lowercased() == "logout" {
                            userInfoDict["messageAction"] = "logout"
                            notificationString += "logout"
                            notificationString += actionIdentifier
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        } else {
                            userInfoDict["messageAction"] = parsedResult.messageaction
                            notificationString += "\(String(describing: parsedResult.messageaction))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.messagebutton != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebutton")
                        }
                        ncContent.actionButtonTitle = parsedResult.messagebutton!
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebutton - %@", "\(String(describing: parsedResult.messagebutton))")
                        }
                        notificationString += "\(String(describing: ncContent.hasActionButton))"
                        notificationString += ncContent.actionButtonTitle
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: alert - no ncMessageButton")
                        }
                        ncContent.hasActionButton = false
                        ncContent.otherButtonTitle = "Close"
                        if verboseMode {
                            NSLog("Notifier Log: alert - ncMessageButton - set to close")
                        }
                        notificationString += "\(String(describing: ncContent.hasActionButton))"
                        notificationString += ncContent.otherButtonTitle
                    }

                    if (parsedResult.messagebuttonaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: alert - messagebuttonaction")
                        }
                        if parsedResult.messagebuttonaction!.lowercased() == "logout" {
                            userInfoDict["messageButtonAction"] = "logout"
                            notificationString += "logout"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        } else {
                            userInfoDict["messageButtonAction"] = parsedResult.messagebuttonaction
                            notificationString += "\(String(describing: parsedResult.messagebuttonaction))"
                            if verboseMode {
                                NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.sound != nil){
                        if verboseMode {
                            NSLog("Notifier Log: alert - sound")
                        }
                        if parsedResult.sound?.lowercased() == "default" {
                            ncContent.soundName = NSUserNotificationDefaultSoundName
                        } else {
                            ncContent.soundName = parsedResult.sound!
                        }
                        notificationString += "\(String(describing: ncContent.soundName))"
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.subtitle != nil){
                        if verboseMode {
                            NSLog("Notifier Log: alert - subtitle")
                        }
                        ncContent.subtitle = parsedResult.subtitle!
                        notificationString += ncContent.subtitle!
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.title != nil){
                        if verboseMode {
                            NSLog("Notifier Log: alert - title")
                        }
                        ncContent.title = parsedResult.title!
                        notificationString += ncContent.title!
                        if verboseMode {
                            NSLog("Notifier Log: alert - notificationString - %@", notificationString)
                        }
                    }

                    let ncContentbase64 = base64String(stringContent: notificationString)
                    ncContent.identifier = ncContentbase64
                    if verboseMode {
                        NSLog("Notifier Log: alert - ncContentbase64 - %@", ncContentbase64)
                    }

                    ncContent.userInfo = userInfoDict

                    if parsedResult.remove?.lowercased() == "prior" {
                        if verboseMode {
                            NSLog("Notifier Log: alert - remove prior")
                        }
                        ncCenter.removeDeliveredNotification(ncContent)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: alert - remove prior - done")
                        }
                        exit(0)
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: alert - notification request")
                        }
                        NSLog("Notifier Log: alert - message - userInfo %@", String(describing: ncContent.userInfo))
                        ncCenter.deliver(ncContent)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: alert - notification delivered")
                        }
                        exit(0)
                    }
                }
            }
        } catch {
            let message = argParser.message(for: error)
            print(message)
            print(error.localizedDescription)
            exit(1)
        }
    }

    // Insert code here to tear down your application
    func applicationWillTerminate(_ aNotification: Notification) {
    }

    // NSUser - Respond to click
    @available(macOS, obsoleted: 10.15)
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        handleNSUserNotification(forNotification: notification)
    }

    // NSUser  - Ensure that notification is shown, even if app is active
    @available(macOS, obsoleted: 10.15)
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    // NSUser - Get value of the otherButton, used to mimic single button UNUser alerts
    @available(macOS, obsoleted: 10.15)
    @objc
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDismissAlert notification: NSUserNotification){
        center.removeDeliveredNotification(notification)
        exit(0)
    }

    // UNUser - Respond to click
    @available(macOS 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewNotification") , object: nil, userInfo: response.notification.request.content.userInfo)
        handleUNNotification(forResponse: response)
    }

    // UNUser - Ensure that notification is shown, even if app is active
    @available(macOS 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

@available(macOS 10.15, *)
    extension AppDelegate: UNUserNotificationCenterDelegate {
}

@available(macOS, obsoleted: 10.15)
    extension AppDelegate: NSUserNotificationCenterDelegate {
}
