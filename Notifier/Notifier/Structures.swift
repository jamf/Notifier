//
//  Structures.swift
//  Notifier
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Imports
import Foundation

// Variables to be used globally
struct GlobalVariables {
    // Path to the main apps bundle
    static let mainAppPath = Bundle.main.bundlePath
    // Path to the alert apps bundle
    static let alertAppPath = mainAppPath + "/Contents/Helpers/Notifier - Alerts.app"
    // Path to the banner apps bundle
    static let bannerAppPath = mainAppPath + "/Contents/Helpers/Notifier - Notifications.app"
}
