//
//  ProgressionsMethodTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionMethodTableViewCell: UITableViewCell {
    
    private var curSelect = -1
    
    // MARK: View properties
    private var loaded: Bool
    private var chosen: Bool
    var nameEntryField: UITextField
    var pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.nameEntryField = UITextField()
        self.pickUnitButton = PrettyButton()
        self.loaded = false
        self.chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
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
            
            self.nameEntryField = UITextField(frame: CGRect(x: 5,
                                                                  y: 5,
                                                                  width: quarterView * 2 - 7.5,
                                                                  height: self.frame.height - 10))
            self.nameEntryField.setDefaultProperties()
            self.nameEntryField.placeholder = "Required: Name"
            self.addSubview(nameEntryField)
            
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
        curSelect = (curSelect + 1) % ProgressionMethod.unitList.count
        
        pickUnitButton.setTitle(ProgressionMethod.unitList[curSelect], for: .normal)
        
        if nameEntryField.text == nil || nameEntryField.text == nil {
            nameEntryField.text = ProgressionMethod.unitList[curSelect]
        }
    }
}
