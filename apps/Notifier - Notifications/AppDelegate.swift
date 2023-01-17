//
//  AppDelegate.swift
//  Notifier Notifications
//
//  Copyright © 2023 dataJAR Ltd. All rights reserved.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    // Gimme some applicationDidFinishLaunching
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let actionIdentifier = "banner"
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
                NSLog("Notifier Log: banner - verbose enabled")
            }

            // User UNUser API's for 10.15+, NSUser for older
            if #available(macOS 10.15, *) {

                if verboseMode {
                    NSLog("Notifier Log: banner - running on 10.15+")
                }

                let ncCenter =  UNUserNotificationCenter.current()
                let ncContent = UNMutableNotificationContent()

                ncCenter.delegate = self

                if verboseMode {
                    ncContent.userInfo["verboseMode"] = "enabled"
                }

                if parsedResult.remove?.lowercased() == "all" {
                    if verboseMode {
                        NSLog("Notifier Log: banner - ncRemove all")
                    }
                    ncCenter.removeAllDeliveredNotifications()
                    sleep(1)
                    if verboseMode {
                        NSLog("Notifier Log: banner - ncRemove all - done")
                    }
                    exit(0)

                } else {

                    if (parsedResult.message != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - message")
                        }
                        ncContent.body = parsedResult.message!
                        notificationString += ncContent.body
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.messageaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - messageaction")
                        }
                        if parsedResult.messageaction!.lowercased() == "logout" {
                            ncContent.userInfo["messageAction"] = "logout"
                            notificationString += "logout"
                            notificationString += actionIdentifier
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        } else {
                            ncContent.userInfo["messageAction"] = parsedResult.messageaction!
                            notificationString += "\(String(describing: parsedResult.messageaction))"
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.sound != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - sound")
                        }
                        if parsedResult.sound?.lowercased() == "default" {
                            ncContent.sound = UNNotificationSound.default
                            notificationString += "\(String(describing: ncContent.sound))"
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        } else {
                            ncContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: parsedResult.sound!))
                            notificationString += "\(String(describing: ncContent.sound))"
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.subtitle != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - subtitle")
                        }
                        ncContent.subtitle = parsedResult.subtitle!
                        notificationString += ncContent.subtitle
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.title != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - title")
                        }
                        ncContent.title = parsedResult.title!
                        notificationString += ncContent.title
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    let ncContentbase64 = base64String(stringContent: notificationString)
                    if verboseMode {
                        NSLog("Notifier Log: banner - ncContentbase64 - %@", ncContentbase64)
                    }

                    if parsedResult.remove?.lowercased() == "prior" {
                        if verboseMode {
                            NSLog("Notifier Log: banner - remove prior")
                        }
                        ncCenter.removeDeliveredNotifications(withIdentifiers: [ncContentbase64])
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: banner - remove prior - done")
                        }
                        exit(0)
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: banner - notification request")
                        }
                        let ncTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let ncRequest = UNNotificationRequest(identifier: ncContentbase64, content: ncContent, trigger: ncTrigger)
                        ncCenter.add(ncRequest)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: banner - notification delivered")
                        }
                        exit(0)
                    }
                }

            } else {

                if verboseMode {
                    NSLog("Notifier Log: banner - running on 10.13 - 10.14")
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
                        NSLog("Notifier Log: banner - remove all")
                    }
                    ncCenter.removeAllDeliveredNotifications()
                    sleep(1)
                    if verboseMode {
                        NSLog("Notifier Log: banner - remove all - done")
                    }
                    exit(0)

                } else {

                    if (parsedResult.message != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - message")
                        }
                        ncContent.informativeText = parsedResult.message
                        notificationString += "\(String(describing: ncContent.informativeText))"
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.messageaction != nil) {
                        if verboseMode {
                            NSLog("Notifier Log: banner - messageaction")
                        }
                        if parsedResult.messageaction?.lowercased() == "logout" {
                            userInfoDict["messageAction"] = "logout"
                            notificationString += "logout"
                            notificationString += actionIdentifier
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        } else {
                            userInfoDict["messageAction"] = parsedResult.messageaction
                            notificationString += "\(String(describing: parsedResult.messageaction))"
                            if verboseMode {
                                NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                            }
                        }
                    }

                    if (parsedResult.sound != nil){
                        if verboseMode {
                            NSLog("Notifier Log: banner - sound")
                        }
                        if parsedResult.sound?.lowercased() == "default" {
                            ncContent.soundName = NSUserNotificationDefaultSoundName
                        } else {
                            ncContent.soundName = parsedResult.sound!
                        }
                        notificationString += "\(String(describing: ncContent.soundName))"
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.subtitle != nil){
                        if verboseMode {
                            NSLog("Notifier Log: banner - subtitle")
                        }
                        ncContent.subtitle = parsedResult.subtitle!
                        notificationString += ncContent.subtitle!
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    if (parsedResult.title != nil){
                        if verboseMode {
                            NSLog("Notifier Log: banner - ncTitle")
                        }
                        ncContent.title = parsedResult.title!
                        notificationString += ncContent.title!
                        if verboseMode {
                            NSLog("Notifier Log: banner - notificationString - %@", notificationString)
                        }
                    }

                    let ncContentbase64 = base64String(stringContent: notificationString)
                    ncContent.identifier = ncContentbase64
                    if verboseMode {
                        NSLog("Notifier Log: banner - ncContentbase64 - %@", ncContentbase64)
                    }

                    ncContent.userInfo = userInfoDict

                    if parsedResult.remove?.lowercased() == "prior" {
                        if verboseMode {
                            NSLog("Notifier Log: banner - ncRemove prior")
                        }
                        ncCenter.removeDeliveredNotification(ncContent)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: banner - ncRemove prior - done")
                        }
                        exit(0)
                    } else {
                        if verboseMode {
                            NSLog("Notifier Log: banner - notification request")
                        }
                        NSLog("Notifier Log: banner - message - userInfo %@", String(describing: ncContent.userInfo))
                        ncCenter.deliver(ncContent)
                        sleep(1)
                        if verboseMode {
                            NSLog("Notifier Log: banner - notification delivered")
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
