//
//  MessageQueueHandler.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/9/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

public class MessageQueue {
    public static let messageDisplayTime: Double = 5.0
    
    private static var messageQueue = [Message]()
    private static var queueTimer: Timer?
    private static var md: MessageDisplayer? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? MessageDisplayer
    }
    
    public static func append(_ message: Message) {
        messageQueue.append(message)
        
        if queueTimer == nil {
            md?.messageQueueStarted?()
            
            queueTimer = Timer.scheduledTimer(withTimeInterval: messageDisplayTime, repeats: true) { (timer) in
                if let md = md {
                    
                    if messageQueue.count == 0 {
                        queueTimer?.invalidate()
                        queueTimer = nil
                        md.messageQueueEnded?()
                        return
                    }
                    
                    md.displayMessage(messageQueue[0])
                    messageQueue.remove(at: 0)
                }
            }
            
            queueTimer?.fire()
        }
    }
}
