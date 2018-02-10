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
    private static var mvc: MainViewController? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? MainViewController
    }
    
    public static func append(_ message: Message) {
        messageQueue.append(message)
        
        if queueTimer == nil {
            mvc?.messageQueueStarted()
            
            queueTimer = Timer.scheduledTimer(withTimeInterval: messageDisplayTime, repeats: true) { (timer) in
                
                if let mvc =
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? MainViewController {
                    
                    if messageQueue.count == 0 {
                        queueTimer?.invalidate()
                        queueTimer = nil
                        mvc.messageQueueEnded()
                        return
                    }
                    
                    mvc.displayMessage(messageQueue[0])
                    messageQueue.remove(at: 0)
                }
            }
            
            queueTimer?.fire()
        }
    }
}
