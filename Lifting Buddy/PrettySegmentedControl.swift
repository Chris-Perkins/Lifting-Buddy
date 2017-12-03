//
//  PrettySegmentedControl.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/22/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//
// A custom implementation of a segmented view.
// Keeps all data and selections in app

import UIKit

class PrettySegmentedControl: UIView {
    
    // MARK: View properties
    
    // delegate that's called whenever we select an index
    public var delegate: PrettySegmentedControlDelegate?
    
    // The buttons for our
    private var buttons: [PrettyButton]
    // The currently selected index
    private var selectedIndex: Int
    
    // MARK: View inits
    
    init(labelStrings: [String], frame: CGRect, defaultIndex: Int = 0) {
        buttons = [PrettyButton]()
        selectedIndex = defaultIndex
        
        // Create a button for each labelString we have
        // Each button's tag is associated with the index it can be found at
        for (index, labelString) in labelStrings.enumerated() {
            let button = PrettyButton()
            button.setDefaultProperties()
            button.setTitle(labelString.lowercased(), for: .normal)
            button.tag = index
            
            buttons.append(button)
        }
        
        super.init(frame: frame)
        
        for button in buttons {
            button.addTarget(self,
                             action: #selector(buttonPress(sender:)),
                             for: .touchUpInside)
            addSubview(button)
        }
        
        // Simulate a button press if we can...
        if buttons.count >= 0 {
            buttonPress(sender: buttons[0])
        }
        
        createAndActivateButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public functions
    
    public func getSelectedIndex() -> Int {
        return selectedIndex
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: PrettyButton) {
        buttons[selectedIndex].backgroundColor = .niceBlue
        
        // tag = index of this button in buttons array
        buttons[sender.tag].backgroundColor = .niceYellow
        selectedIndex = sender.tag
        
        delegate?.segmentSelectionChanged(index: selectedIndex)
    }
    
    // MARK: View constraints
    
    private func createAndActivateButtonConstraints() {
        var lastView: UIView = self
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: lastView,
                               attribute: lastView == self ? .left : .right,
                               relatedBy: .equal,
                               toItem: button,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .top).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .bottom).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .width,
                                                                 multiplier: 1/CGFloat(buttons.count)
                ).isActive = true
            
            lastView = button
        }
    }
    
}

protocol PrettySegmentedControlDelegate {
    func segmentSelectionChanged(index: Int)
}
