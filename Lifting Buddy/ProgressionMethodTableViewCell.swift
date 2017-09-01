//
//  ExerciseTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionMethodTableViewCell: UITableViewCell {
    
    // MARK: View properties
    private var loaded: Bool
    private var chosen: Bool
    var titleEntryField: UITextField
    var pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.titleEntryField = UITextField()
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
            
            let quarterView = (self.frame.width) / 4
            
            // MARK: Progression Textfield
            
            self.titleEntryField = UITextField(frame: CGRect(x: 5,
                                                                  y: 5,
                                                                  width: quarterView * 2 - 7.5,
                                                                  height: self.frame.height - 10))
            self.titleEntryField.setDefaultProperties()
            self.titleEntryField.placeholder = "Required: Name"
            self.addSubview(titleEntryField)
            
            // MARK: Pick Unit button
            
            self.pickUnitButton = PrettyButton(frame: CGRect(x: quarterView * 2 + 2.5,
                                                             y: 5,
                                                             width: quarterView * 2 - 7.5,
                                                             height: self.frame.height - 10))
            self.pickUnitButton.setDefaultProperties()
            self.pickUnitButton.setTitle("Required: Unit", for: .normal)
            self.pickUnitButton.addTarget(self, action: #selector(pickUnitButtonPress(sender:)), for: .touchUpInside)
            self.addSubview(pickUnitButton)
            
            self.loaded = true
        }
    }
    
    // MARK: Event functions
    
    @objc func pickUnitButtonPress(sender: UIButton) {
        self.pickUnitButton.setTitle(ProgressionMethod.Unit.DISTANCE.rawValue, for: .normal)
    }
}
