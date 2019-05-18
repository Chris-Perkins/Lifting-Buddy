//
//  InitialViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public class InitialViewController: UIViewController {
    /**
     The label that should greet the user on app's opening.
     */
    @IBOutlet weak var welcomeLabel: UILabel!
    
    /**
     The identifier of the segue to go to the view controller with the application's contents.
     */
    private static let contentSegueIdentifier = "ContentSegue"
    /**
     The amount of time that the application should idle for after the view appears before
     performing animations.
     */
    private static let idleTimeBeforeZoomOut: CFTimeInterval = 0.3
    /**
     The amount of time it takes (in seconds) to zoom the welcomeTextLabel out.
     */
    private static let zoomOutTime: CFTimeInterval = 0.5
    
    /**
     Calls super viewDidAppear and hides zooms out from the label. Transitions after this completes.
     
     - Parameter animated: If true, the view was added to the window using an animation.
     */
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Give the view a little extra time to load in (didAppear != didFinishAppearing)
        Timer.scheduledTimer(withTimeInterval: InitialViewController.idleTimeBeforeZoomOut,
                             repeats: false) { (timer) in
            self.performZoomOutAnimations { (_) in
                self.performSegue(withIdentifier: InitialViewController.contentSegueIdentifier,
                                  sender: self)
            }
        }
    }
    
    /**
     "Zooms" the welcomeTextLabel out by setting the label's text transform to a scale of 0.
     
     - Parameter completionHandler: The completion handler called when the text label has been
     zoomed out
     */
    private func performZoomOutAnimations(completionHandler: ((Bool) -> ())?) {
        // Note that setting the scale to 0 messes up the animation. Put it just above 0. :)
        let destinationTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: InitialViewController.zoomOutTime, animations: {
            self.welcomeLabel.transform = destinationTransform
            self.welcomeLabel.layoutIfNeeded()
        }) {
            (isAnimationCompleted) in
            completionHandler?(isAnimationCompleted)
        }
    }
}
