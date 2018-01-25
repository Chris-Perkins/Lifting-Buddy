//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/24/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    public static let heightPerProgressionMethodInput: CGFloat = 40.0
    
    private var historyEntry: ExerciseHistoryEntry?
    
    // MARK: View functions
    
    public static func getHeight(forExercise exercise: Exercise) -> CGFloat {
        let pgmHeights = CGFloat(exercise.getProgressionMethods().count) *
                            heightPerProgressionMethodInput
        let baseHeight = UITableViewCell.defaultHeight
        
        return pgmHeights + baseHeight
    }
    
    // MARK: View functions
    
    public func setColor() {
        self.backgroundColor = .lightestBlackWhiteColor
    }
}
