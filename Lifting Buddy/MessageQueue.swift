//
//  MessageQueueHandler.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/9/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

public class MessageQueue {
    
    private static var activeInstance: MessageQueue?
    
    // Returns or creates and returns the shared instance
    public static var shared: MessageQueue {
        if let instance = activeInstance {
            return instance
        } else {
            activeInstance = MessageQueue()
            return activeInstance!
        }
    }
    
    public let messageDisplayTime: Double = 5.0
    
    private var messageQueue = [Message]()
    private var queueTimer: Timer?
    private var messageDisplayer: MessageDisplayer? {
        return (UIApplication.shared.delegate as? AppDelegate)?.mainViewController
    }
    
    public func append(_ message: Message) {
        messageQueue.append(message)
        
        if queueTimer == nil {
            messageDisplayer?.messageQueueStarted?()
            
            queueTimer = Timer.scheduledTimer(withTimeInterval: messageDisplayTime, repeats: true) { (timer) in
                if let md = self.messageDisplayer {
                    
                    if self.messageQueue.count == 0 {
                        self.queueTimer?.invalidate()
                        self.queueTimer = nil
                        md.messageQueueEnded?()
                        return
                    }
                    
                    md.displayMessage(self.messageQueue[0])
                    self.messageQueue.remove(at: 0)
                }
            }
            
            queueTimer?.fire()
        }
    }
}
