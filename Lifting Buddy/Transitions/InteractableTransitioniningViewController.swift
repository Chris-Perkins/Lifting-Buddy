//
//  InteractableTransitioniningViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 5/22/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

/// A UIViewController-bound protocol that specifies whether or not the View Controller can interactively transition.
public protocol InteractableTransitioniningViewController where Self: UIViewController {

    /// Updates the status of the View Controller and whether or not it can interactively transition via user-input.
    ///
    /// - Parameter canTransitionInteractively: Whether or not this UIViewController can interactively transition
    func updateInteractiveTransitioningStatus(to canTransitionInteractively: Bool)
}
