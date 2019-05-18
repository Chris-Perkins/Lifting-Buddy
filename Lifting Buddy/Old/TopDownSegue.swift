//
//  TopDownSegue.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

// A segue that performs with the appearing view sliding down over the destination view.
// Slightly modified code from answer found here: https://stackoverflow.com/a/37899793

import Foundation

class TopDownSegue: UIStoryboardSegue {
    let duration: TimeInterval = 0.25
    let delay: TimeInterval = 0
    let animationOptions: UIView.AnimationOptions = [.curveEaseIn]
    
    override func perform() {
        // get views
        let sourceView = source.view
        let destinationView = destination.view
        
        // get screen height
        let screenHeight = UIScreen.main.bounds.size.height
        destinationView?.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
        
        // add destination view to view hierarchy
        UIApplication.shared.keyWindow?.insertSubview(destinationView!, aboveSubview: sourceView!)
        
        // animate
        UIView.animate(withDuration: duration, delay: delay, options: animationOptions, animations: {
            destinationView?.transform = .identity
        }) { (_) in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}
