//
//  Message.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

public enum MessageType {
    case NewBest
    case WorkoutComplete
    case ExerciseComplete
    case SessionComplete
    case ObjectSaved
    case ObjectCreated
}

/* This is declared as an NSObject because we use it an @objc protocol */
public class Message: NSObject {
    // The type of message this is
    public let type: MessageType
    // The identifier for the message (typically the name that describes the value)
    private let identifier: String?
    // The value we're displaying
    private let value: String?
    
    public var messageTitle: String {
        switch type {
        case .NewBest:
            return NSLocalizedString("Message.NewBest",
                                     comment: "").replacingOccurrences(of: "{0}", with:
                                        identifier!).replacingOccurrences(of: "{1}", with: value!)
        case .WorkoutComplete:
            return NSLocalizedString("Message.WorkoutComplete",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with:
                                        identifier!).replacingOccurrences(of: "{1}", with: value!)
        case .ExerciseComplete:
            return NSLocalizedString("Message.ExerciseComplete",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .SessionComplete:
            return NSLocalizedString("Message.SessionComplete", comment: "")
        case .ObjectSaved:
            return NSLocalizedString("Message.ObjectSaved",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .ObjectCreated:
            return NSLocalizedString("Message.ObjectCreated",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        }
    }
    
    init(type: MessageType, identifier: String?, value: String?) {
        self.type  = type
        self.identifier = identifier//String(identifier?.prefix(16) ?? "")
        self.value = value
    }
}
