//
//  Structures.swift
//  Notifier - Notifications
//
//  Copyright © 2024 dataJAR Ltd. All rights reserved.
//

// Structure of MessageContent
struct MessageContent: Codable {
    // Optional - action to perform when the message is clicked
    var messageAction: [TaskObject]?
    // The notifications message (required)
    var messageBody: String?
    // Optional - message button label
    var messageButton: String?
    // Optional - action to perform when the message button is clicked
    var messageButtonAction: [TaskObject]?
    // Optional - the sound played when the notification has been delivered
    var messageSound: String?
    // Optional - the notifications subtitle
    var messageSubtitle: String?
    // Optional - the notifications title
    var messageTitle: String?
    // Arguments for the task object
    struct TaskObject: Codable {
        // The tasks executable
        var taskPath: String?
        // Arguments to pass to the task executable
        var taskArguments: [String]?
    }
    // Initialize MessageContent
    init(messageAction: [TaskObject]? = nil, messageBody: String? = nil, messageButton: String? = nil,
         messageButtonAction: [TaskObject]? = nil, messageSound: String? = nil, messageSubtitle: String? = nil,
         messageTitle: String? = nil) {
        self.messageAction = messageAction
        self.messageBody = messageBody
        self.messageButton = messageButton
        self.messageButtonAction = messageButtonAction
        self.messageSound = messageSound
        self.messageSubtitle = messageSubtitle
        self.messageTitle = messageTitle
    }
}

// Structure of RootElements
struct RootElements: Codable {
    // Optional - the messages content
    var messageContent: String?
    // Optional - removes a specific notification or all notifications delivered
    var removeOption: String?
    // Optional - enables verbose logging
    var verboseMode: String?
    // Initialize MessageContent
    init(messageContent: String? = nil, removeOption: String? = nil, verboseMode: String? = nil) {
        self.messageContent = messageContent
        self.removeOption = removeOption
        self.verboseMode = verboseMode
    }
}

// For storing data in the notifications userInfo
struct UserInfo: Codable {
    // Optional - action to perform when the message is clicked
    var messageAction: [TaskObject]?
    // Optional - action to perform when the message button is clicked
    var messageButtonAction: [TaskObject]?
    // Arguments for the task object
    struct TaskObject: Codable {
        // The tasks executable
        var taskPath: String?
        // Arguments to pass to the task executable
        var taskArguments: [String]?
    }
    // Initialize ParsedArguments
    init(messageAction: [TaskObject]? = nil, messageButtonAction: [TaskObject]? = nil) {
        self.messageAction = messageAction
        self.messageButtonAction = messageButtonAction
    }
}
