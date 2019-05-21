//
//  NSLayoutConstraintCollectionExtension.swift
//  ClingConstraintsDemo
//
//  Created by Christopher Perkins on 6/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public extension Collection where Element == NSLayoutConstraint {

    /**
     Applies the provided multiplier value to all constraints in the collection.

     - Parameter multipliersValue: The multiplier that should be set for all constraints in the collection
     - Returns: The new, activated constraints
     */
    @discardableResult func withMultipliers(_ multipliersValue: CGFloat) -> [NSLayoutConstraint] {
        return map { $0.withMultiplier(multipliersValue) }
    }

    /**
     Applies to provided offset value to all constraints in this collection.

     - Parameter offsetsValue: The offset value that should be set for all constraints in the collection
     - Returns: The new, activated constraints
    */
    @discardableResult func withOffsets(_ offsetsValue: CGFloat) -> [NSLayoutConstraint] {
        return map { $0.withOffset(offsetsValue) }
    }

    /**
     Applies the new relation value to all constraints in the collection.

     - Parameter newRelation: The relation that should be set for tall constraints in the collection
     - Returns: The new, activated constraints
     */
    @discardableResult func withRelations(_ newRelations: NSLayoutConstraint.Relation) -> [NSLayoutConstraint] {
        return map { $0.withRelation(newRelations) }
    }

    /**
     Applies the input priority value to all constraints in this collection.

     - Parameter priority: The priority that should be set for all constraints in the collection
     - Returns: The new, activated constraints
     */
    @discardableResult func withPriorities( _ prioritiesValue: UILayoutPriority) -> [NSLayoutConstraint] {
        return map { $0.withPriority(prioritiesValue) }
    }

    /**
     Sets the `isActive` property for all constraints in this Collection to true.
     */
    func activateAllConstraints() {
        for constraint in self {
            constraint.isActive = true
        }
    }
    
    /**
     Sets the `isActive` property for all constraints in this Collection to false.
    */
    func deactivateAllConstraints() {
        for constraint in self {
            constraint.isActive = false
        }
    }
}
