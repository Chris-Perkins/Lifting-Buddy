//
//  Message.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

public enum MessageType {
    case newBest
    case workoutComplete
    case exerciseComplete
    case sessionComplete
    case objectSaved
    case objectCreated
    case objectDeleted
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
        case .newBest:
            return NSLocalizedString("Message.NewBest",
                                     comment: "").replacingOccurrences(of: "{0}", with:
                                        identifier!).replacingOccurrences(of: "{1}", with: value!)
        case .workoutComplete:
            return NSLocalizedString("Message.WorkoutComplete",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with:
                                        identifier!).replacingOccurrences(of: "{1}", with: value!).replacingOccurrences(of: "{2}", with: value! == "1" ? "" : "s")
        case .exerciseComplete:
            return NSLocalizedString("Message.ExerciseComplete",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .sessionComplete:
            return NSLocalizedString("Message.SessionComplete", comment: "")
        case .objectSaved:
            return NSLocalizedString("Message.ObjectSaved",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .objectCreated:
            return NSLocalizedString("Message.ObjectCreated",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .objectDeleted:
            return NSLocalizedString("Message.ObjectDeleted",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        }
    }
    
    init(type: MessageType, identifier: String?, value: String?) {
        self.type  = type
        self.identifier = identifier//String(identifier?.prefix(16) ?? "")
        self.value = value
    }
}
