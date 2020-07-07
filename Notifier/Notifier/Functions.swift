//
//  Functions.swift
//  Notifier
//
//  Copyright © 2020 dataJAR Ltd. All rights reserved.
//

import Cocoa
import SystemConfiguration

// Return the username of the logged in user
func atLoginWindow() -> String {
    let loggedInUser = SCDynamicStoreCopyConsoleUser(nil, nil, nil)! as String
    if loggedInUser == "loginwindow" || loggedInUser == "" {
        print("ERROR: No user logged in...")
        exit(1)
    } else {
        let userName = NSUserName()
        if userName != loggedInUser {
            return loggedInUser
        } else {
            return ""
        }
    }
}
