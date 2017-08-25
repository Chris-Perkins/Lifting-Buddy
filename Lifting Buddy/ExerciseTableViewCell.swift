//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    private var loaded: Bool
    private var chosen: Bool
    private var pickNewButton: PrettyButton
    private var pickExistingButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.pickNewButton = PrettyButton()
        self.pickExistingButton = PrettyButton()
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
        
        if !self.loaded && !self.chosen {
            pickNewButton = PrettyButton(frame: CGRect(x: 5,
                                                       y: 5,
                                                       width: (self.frame.width - 20) / 2,
                                                       height: self.frame.height - 10))
            pickNewButton.setDefaultProperties()
            pickNewButton.setOverlayStyle(style: .NONE)
            pickNewButton.addTarget(self, action: #selector(createNewExercise(sender:)), for: .touchUpInside)
            pickNewButton.setTitle("Create new exercise", for: .normal)
            self.addSubview(pickNewButton)
            
            pickExistingButton = PrettyButton(frame: CGRect(x: self.frame.width / 2 + 5,
                                                            y: 5,
                                                            width: (self.frame.width - 20) / 2,
                                                            height: self.frame.height - 10))
            pickExistingButton.setDefaultProperties()
            
            self.addSubview(pickExistingButton)
            
            chosen = true
        } else if !self.loaded && self.chosen {
            loaded = true
        }
    }
    
    // MARK: Event functions
    
    @objc private func createNewExercise(sender: PrettyButton) {
        print("test")
    }
}
