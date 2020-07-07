//
//  Funcions.swift
//  Notifier Alerts
//
//  Copyright © 2020 dataJAR Ltd. All rights reserved.
//

import Cocoa
import Foundation
import UserNotifications


// Base64 content
func base64String(stringContent: String) -> String {
    return stringContent.data(using: String.Encoding.utf8)!.base64EncodedString()
}

// Logout user, prompting to save
func gracefullLogout(verboseMode: Bool) {
    if verboseMode {
        NSLog("Notifier Log: alert - logout prompting")
    }
    let logoutUser = "tell application \"loginwindow\" to «event aevtlogo»"
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: logoutUser) {
        if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
            print(outputString)
            if verboseMode {
                NSLog("Notifier Log: alert - logout - %@", outputString)
            }
        } else if (error != nil) {
            print("error: ", error!)
            if verboseMode {
                NSLog("Notifier Log: alert - logout - %@", String(describing: error!))
            }
        }
    }
}

// Open the item passed, NSWorkspace was used but sometimes threw "app is not open errors"
func openItem(globalOpenItem: [String]?, verboseMode: Bool) {
    if verboseMode {
        NSLog("Notifier Log: alert - opening %@", String(describing: globalOpenItem))
    }
    openItem:
    do {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = globalOpenItem
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.launch()
        if verboseMode {
            NSLog("Notifier Log: alert - opened %@", String(describing: globalOpenItem))
        }
    }
}

// Request authorisation
func requestAuthorisation (verboseMode: Bool) -> Void {
    if #available(macOS 10.15, *) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        if !granted {
            print("ERROR: Authorisation not granted, exiting...")
            if verboseMode {
                NSLog("Notifier Log: alert - ERROR: Authorisation not granted, exiting...")
            }
            exit(1)
        }
      }
    }
}

// Process userinfo for UNNotification
@available(macOS 10.14, *)
func handleUNNotification(forResponse response: UNNotificationResponse) {
    let userInfo = response.notification.request.content.userInfo
    var verboseMode = false
    var messageDismissed = true
    if userInfo["verboseMode"] != nil {
        verboseMode = true
    }
    if verboseMode {
        NSLog("Notifier Log: alert - message - interacted")
    }
    if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" {
        if verboseMode {
            NSLog("Notifier Log: alert - message - clicked")
            NSLog("Notifier Log: alert - message - userInfo %@", String(describing: userInfo))
        }
        if userInfo["messageAction"] != nil {
            if (userInfo["messageAction"] as? String) == "logout" {
                if verboseMode {
                    NSLog("Notifier Log: alert - message - logout")
                }
                gracefullLogout(verboseMode: verboseMode)
                messageDismissed = false
            } else {
                if verboseMode {
                    NSLog("Notifier Log: alert - message - %@", String(describing: userInfo["messageAction"]))
                }
                openItem(globalOpenItem: [(userInfo["messageAction"] as? String)!], verboseMode: verboseMode)
                messageDismissed = false
            }
        }
    } else if response.actionIdentifier == "com.apple.UNNotificationDismissActionIdentifier" {
        // need to capture this, but we don't want to do anything
    } else {
        if verboseMode {
            NSLog("Notifier Log: alert - message button - clicked")
            NSLog("Notifier Log: alert - message button - userInfo %@", String(describing: userInfo))
        }
        if userInfo["messageButtonAction"] != nil {
            if (userInfo["messageButtonAction"] as? String) == "logout" {
                if verboseMode {
                    NSLog("Notifier Log: alert - message button - logout")
                }
                gracefullLogout(verboseMode: verboseMode)
                messageDismissed = false
            } else {
                if verboseMode {
                    NSLog("Notifier Log: alert - message button - %@", String(describing: userInfo["messageButtonAction"]))
                }
                openItem(globalOpenItem: [(userInfo["messageButtonAction"] as? String)!], verboseMode: verboseMode)
                messageDismissed = false
            }
        }
    }
    if verboseMode && messageDismissed {
        NSLog("Notifier Log: alert - message - dismissed by user")
    }
    if verboseMode {
        NSLog("Notifier Log: alert - message - removing notification")
    }
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
    sleep(1)
    if verboseMode {
        NSLog("Notifier Log: alert - message - removing notification - done")
    }
    exit(0)
}

// Process userinfo for NSUserNotification
func handleNSUserNotification(forNotification notification: NSUserNotification) {
    let center =  NSUserNotificationCenter.default
    let userInfo = notification.userInfo
    var verboseMode = false
    var messageDismissed = true
    if userInfo?["verboseMode"] != nil {
        verboseMode = true
    }
    if verboseMode {
        NSLog("Notifier Log: alert - message - interacted")
    }
    switch (notification.activationType) {
    case .none:
        exit(0)
    case .contentsClicked:
        if verboseMode {
            NSLog("Notifier Log: alert - message - clicked")
            NSLog("Notifier Log: alert - message - userInfo %@", String(describing: userInfo))
        }
        if userInfo?["messageAction"] != nil {
            if (userInfo?["messageAction"] as? String) == "logout" {
                if verboseMode {
                    NSLog("Notifier Log: alert - message - logout")
                }
                gracefullLogout(verboseMode: verboseMode)
                messageDismissed = false
            } else {
                if verboseMode {
                    NSLog("Notifier Log: alert - message - %@", String(describing: userInfo?["messageAction"]))
                }
                openItem(globalOpenItem: [(userInfo?["messageAction"] as? String)!], verboseMode: verboseMode)
                messageDismissed = false
            }
        }
    case .actionButtonClicked:
        if verboseMode {
            NSLog("Notifier Log: alert - message button - clicked")
            NSLog("Notifier Log: alert - message button - userInfo %@", String(describing: userInfo))
        }
        if userInfo?["messageButtonAction"] != nil {
            if (userInfo?["messageButtonAction"] as? String) == "logout" {
                if verboseMode {
                    NSLog("Notifier Log: alert - message button - logout")
                }
                gracefullLogout(verboseMode: verboseMode)
                messageDismissed = false
            } else {
                if verboseMode {
                    NSLog("Notifier Log: alert - message button - %@", String(describing: userInfo?["messageButtonAction"]))
                }
                openItem(globalOpenItem: [(userInfo?["messageButtonAction"] as? String)!], verboseMode: verboseMode)
                messageDismissed = false
            }
        }
    case .replied:
        exit(0)
    case .additionalActionClicked:
        exit(0)
    @unknown default:
        exit(0)
    }
    if verboseMode && messageDismissed {
        NSLog("Notifier Log: alert - message - dismissed by user")
    }
    if verboseMode {
        NSLog("Notifier Log: alert - message - removing notification")
    }
    center.removeDeliveredNotification(notification)
    sleep(1)
    if verboseMode {
        NSLog("Notifier Log: alert - message - removing notification - done")
    }
    exit(0)
}
