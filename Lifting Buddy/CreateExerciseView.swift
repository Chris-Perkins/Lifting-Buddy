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
    private var progressionsTableView: ProgressionsTableView
    private var addProgressionMethodButton: PrettyButton
    private var createExerciseButton: PrettyButton
    private var prevCellCount = -1
    
    // MARK: Init overrides
    
    override init(frame: CGRect) {
        nameEntryLabel = UILabel()
        nameEntryField = UITextField()
        progressionsTableView = ProgressionsTableView()
        addProgressionMethodButton = PrettyButton()
        createExerciseButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(nameEntryLabel)
        self.addSubview(nameEntryField)
        self.addSubview(progressionsTableView)
        self.addSubview(addProgressionMethodButton)
        self.addSubview(createExerciseButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        if prevCellCount == -1 {
            self.backgroundColor = UIColor.niceGray()
            self.layer.zPosition = 100
            
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
            nameEntryLabel.text = "Name of New Exercise"
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
            nameEntryField.placeholder = "Name of New Exercise"
            textfieldDeselected(sender: nameEntryField)
            
            // MARK: Progressions Table View
            // MARK: Exercise Table View
            
            progressionsTableView = ProgressionsTableView(frame: CGRect(x: 10,
                                                                     y: 130,
                                                                     width: self.frame.width - 20,
                                                                     height: 0),
                                                                     style: .plain)
            progressionsTableView.appendDataToTableView(data: "test")
            // Prevent clipping as we can click and drag cells
            progressionsTableView.clipsToBounds = false
            progressionsTableView.isScrollEnabled = false
            progressionsTableView.backgroundColor = UIColor.clear
            
            self.addSubview(progressionsTableView)
            
            // MARK: Add progression method button
            addProgressionMethodButton.translatesAutoresizingMaskIntoConstraints = false
            
            addProgressionMethodButton.setDefaultProperties()
            addProgressionMethodButton.layer.cornerRadius = 5.0
            addProgressionMethodButton.setOverlayColor(color: UIColor.niceYellow())
            addProgressionMethodButton.setOverlayStyle(style: .FADE)
            addProgressionMethodButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            addProgressionMethodButton.setTitle("Add Progression Method", for: .normal)
            addProgressionMethodButton.setTitleColor(UIColor.niceBlue(), for: .normal)
            addProgressionMethodButton.setTitleColor(UIColor.white, for: .highlighted)
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: addProgressionMethodButton,
                                                            width: progressionsTableView.frame.width).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: addProgressionMethodButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below exerciseTableView
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: addProgressionMethodButton,
                                                             belowView: progressionsTableView,
                                                             withPadding: 0).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: addProgressionMethodButton,
                                                                            inView: self).isActive = true
            
            // MARK: Create exercise button
            createExerciseButton.translatesAutoresizingMaskIntoConstraints = false
            
            createExerciseButton.setTitle("Create Exercise", for: .normal)
            createExerciseButton.setDefaultProperties()
            
            /*
             * Create width and height for constraints
             */
            NSLayoutConstraint.createWidthConstraintForView(view: createExerciseButton,
                                                            width: self.frame.width - 50).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: createExerciseButton,
                                                             height: 50).isActive = true
            /*
             * Center on x axis,
             * position createWorkout Button below add exercise button
             */
            NSLayoutConstraint.createViewBelowViewConstraint(view: createExerciseButton,
                                                             belowView: addProgressionMethodButton,
                                                             withPadding: viewPadding * 2).isActive = true
            NSLayoutConstraint.createCenterViewHorizontallyInViewConstraint(view: createExerciseButton,
                                                                            inView: self).isActive = true
            
            prevCellCount = progressionsTableView.getData().count
        }
        // We call else if instead of just doing if so that when we come back to this view
        // Otherwise, contentSize does not get properly updated.
        else if prevCellCount != progressionsTableView.getData().count {
            prevCellCount = progressionsTableView.getData().count
            self.contentSize.height = createExerciseButton.frame.maxY + 50 + viewPadding
        }
    }
    
    // MARK: Events
    
    @objc func textfieldSelected(sender: UITextField) {
        sender.backgroundColor = UIColor.niceYellow()
        sender.textColor = UIColor.white
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        sender.backgroundColor = UIColor.white
        sender.textColor = UIColor.black
    }
}
