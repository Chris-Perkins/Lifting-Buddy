//
//  CreateExerciseView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift

class CreateExerciseView: UIScrollView {
    
    // MARK: View properties
    let viewPadding: CGFloat = 20.0
    private var nameEntryLabel: UILabel
    private var nameEntryField: UITextField
    
    // MARK: Init overrides
    
    override init(frame: CGRect) {
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryLabel)
        self.addSubview(nameEntryField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        // MARK: Name Entry Label
        nameEntryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryLabel,
                                                         height: 20).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: nameEntryLabel,
                                                        width: self.frame.width - 40).isActive = true
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryLabel,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryLabel,
                                                            belowView: self,
                                                            withPadding: viewPadding).isActive = true
        nameEntryLabel.text = "Name of New Workout"
        nameEntryLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        nameEntryLabel.textAlignment = .center
        nameEntryLabel.textColor = UIColor.niceBlue()
        
        // MARK: Name Entry Field
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        /*
         * Center in view, place below the above frame, and give height/width of 40
         */
        NSLayoutConstraint.createHeightConstraintForView(view: nameEntryField,
                                                         height: 40).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: nameEntryField,
                                                        width: self.frame.width - 80).isActive = true
        NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: nameEntryField,
                                                                        inView: self).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: nameEntryField,
                                                         belowView: nameEntryLabel,
                                                         withPadding: viewPadding / 2).isActive = true
        
        // View select / deselect events
        nameEntryField.addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
        nameEntryField.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        
        // View prettiness
        nameEntryField.layer.cornerRadius = 5.0
        nameEntryField.textAlignment = .center
        nameEntryField.placeholder = "Name of New Workout"
        textfieldDeselected(sender: nameEntryField)
    }
    
    @objc func textfieldSelected(sender: UITextField) {
        sender.backgroundColor = UIColor.niceYellow()
        sender.textColor = UIColor.white
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        sender.backgroundColor = UIColor.white
        sender.textColor = UIColor.black
    }
}
