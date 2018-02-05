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
}

public struct Message {
    private let type: MessageType
    public let identifier: String?
    private let value: String?
    
    public var getMessageTitle: String {
        switch type {
        case .NewBest:
            return NSLocalizedString("Message.NewBest.Title", comment: "")
        case .WorkoutComplete:
            return NSLocalizedString("Message.WorkoutComplete.Title",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .ExerciseComplete:
            return NSLocalizedString("Message.ExerciseComplete.Title",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: identifier!)
        case .SessionComplete:
            return NSLocalizedString("Message.SessionComplete.Title", comment: "")
        }
    }
    
    public var getMessageDescription: String? {
        switch type {
        case .NewBest:
            return NSLocalizedString("Message.NewBest.Desc",
                                     comment: "{0}: {1}").replacingOccurrences(of: "{0}", with: identifier!).replacingOccurrences(of: "{1}", with: value!)
        case .WorkoutComplete:
            return NSLocalizedString("Message.WorkoutComplete.Desc",
                                     comment: "{0}").replacingOccurrences(of: "{0}", with: value!)
        default:
            return nil
        }
    }
    
    init(type: MessageType, identifier: String?, value: String?) {
        self.type  = type
        self.identifier = String(identifier?.prefix(12) ?? "")
        self.value = value
    }
}
