//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionsTableViewCell: UITableViewCell {
    
    // MARK: View properties
    private var loaded: Bool
    private var chosen: Bool
    private var progressionLabel: UILabel
    private var progressionTextfield: UITextField
    private var pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.progressionLabel = UILabel()
        self.progressionTextfield = UITextField()
        self.pickUnitButton = PrettyButton()
        self.loaded = false
        self.chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.loaded {
            // MARK: Progression Label
            let quarterView = (self.frame.width - 10) / 4
            
            // Create a label that's 1/4 of the view, sub an additional 5 for padding reasons.
            self.progressionLabel = UILabel(frame: CGRect(x: 5,
                                                          y: 5,
                                                          width: quarterView - 5,
                                                          height: self.frame.height - 10))
            self.progressionLabel.text = "Name"
            self.progressionLabel.textAlignment = .center
            self.progressionLabel.textColor = UIColor.niceBlue()
            self.addSubview(self.progressionLabel)
            
            // MARK: Progression Textfield
            self.progressionTextfield = UITextField(frame: CGRect(x: quarterView,
                                                                  y: 5,
                                                                  width: self.frame.width * 0.75 - quarterView,
                                                                  height: self.frame.height - 10))
            self.progressionTextfield.setDefaultProperties()
            self.addSubview(progressionTextfield)
            
            self.loaded = true
        }
    }
    
    // MARK: Event functions
    
    @objc private func createNewExercise(sender: PrettyButton) {
        print("test")
    }
}
