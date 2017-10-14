//
//  TimeInputField.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class TimeInputField: UIView {
    
    // MARK: View properties
    
    private var inputViewContainer: UIView
    private var hourField: BetterTextField
    private var minuteField: BetterTextField
    private var secondField: BetterTextField
    
    private var inputViews: [UIView]
    
    private var timerButton: ToggleablePrettyButton
    private var timer: DispatchSourceTimer?
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        self.inputViewContainer = UIView()
        self.hourField = BetterTextField(defaultString: "0", frame: .zero)
        self.minuteField = BetterTextField(defaultString: "0", frame: .zero)
        self.secondField = BetterTextField(defaultString: "0", frame: .zero)
        self.timerButton = ToggleablePrettyButton()
        
        self.inputViews = [UIView]()
        
        super.init(frame: frame)
        
        self.addSubview(inputViewContainer)
            self.inputViewContainer.addSubview(hourField)
            self.inputViewContainer.addSubview(minuteField)
            self.inputViewContainer.addSubview(secondField)
        self.addSubview(timerButton)
        
        self.inputViews.append(hourField)
        self.inputViews.append(minuteField)
        self.inputViews.append(secondField)
        
        self.minuteField.textfield.addTarget(self, action: #selector(checkMinuteField), for: .editingDidEnd)
        self.secondField.textfield.addTarget(self, action: #selector(checkSecondField), for: .editingDidEnd)
        self.timerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.createAndActivateTimerButtonConstraints()
        self.createAndActivateInputViewContainerConstraints()
        self.createAndActivateInputConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: view overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.hourField.setIsNumeric(isNumeric: true)
        self.hourField.setDefaultString(defaultString: "0")
        self.hourField.setLabelTitle(title: "h")
        
        self.minuteField.setIsNumeric(isNumeric: true)
        self.minuteField.setDefaultString(defaultString: "0")
        self.minuteField.setLabelTitle(title: "m")
        
        self.secondField.setIsNumeric(isNumeric: true)
        self.secondField.setDefaultString(defaultString: "0")
        self.secondField.setLabelTitle(title: "s")
        
        
        self.timerButton.setToggleViewColor(color: UIColor.niceGreen())
        self.timerButton.setDefaultViewColor(color: UIColor.niceBlue())
    }
    
    // MARK: Events functions
    
    @objc private func checkSecondField() {
        self.secondField.textfield.textfieldDeselected(sender: secondField.textfield)
        
        if self.secondField.textfield.text?.floatValue != nil {
            minuteField.textfield.text = String((minuteField.textfield.text!.floatValue ?? 0) +
                                                floor((secondField.textfield.text?.floatValue)! / 60))
            secondField.textfield.text = String(secondField.textfield.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
            
            self.checkMinuteField()
        }
    }
    
    @objc private func checkMinuteField() {
        self.minuteField.textfield.textfieldDeselected(sender: minuteField.textfield)
        
        if self.minuteField.textfield.text?.floatValue != nil {
            self.hourField.textfield.text = String((hourField.textfield.text!.floatValue ?? 0) +
                                                   floor((minuteField.textfield.text?.floatValue)! / 60))
            self.minuteField.textfield.text = String(minuteField.textfield.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
        }
    }
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case(timerButton):
            if timerButton.isToggled {
                startTimer()
            } else {
                stopTimer()
            }
            break
        default:
            fatalError("Button pressed that is not set up")
        }
    }
    
    // MARK: view constraints
    
    // cling to top, bottom, right. width of timer button's new height
    private func createAndActivateTimerButtonConstraints() {
        self.timerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.timerButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.timerButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.timerButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: self.timerButton,
                           attribute: .width,
                           multiplier: 4,
                           constant: 0).isActive = true
    }
    
    // Take up whatever the timer button isn't
    private func createAndActivateInputViewContainerConstraints() {
        inputViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.inputViewContainer,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.inputViewContainer,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.inputViewContainer,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self.timerButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.inputViewContainer,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Spread evenly across the inputView
    private func createAndActivateInputConstraints() {
        
        var prevView: UIView = self.inputViewContainer
        
        for view in inputViews {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: self.inputViewContainer,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self.inputViewContainer,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == self.inputViewContainer ? .left : .right,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self.inputViewContainer,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .width,
                               multiplier: CGFloat(inputViews.count),
                               constant: 0).isActive = true
            
            prevView = view
        }
    }
    
    // Timer functions
    
    private func startTimer() {
        //  Make all textfields non-editable (gray to indicate)
        self.secondField.textfield.isUserInteractionEnabled = false
        self.minuteField.textfield.isUserInteractionEnabled = false
        self.hourField.textfield.isUserInteractionEnabled = false
        
        let queue = DispatchQueue(label: "com.firm.app.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .never)
        
        timer?.setEventHandler { [weak self] in
            
            if self != nil {
                DispatchQueue.main.async {
                    if (self!.secondField.textfield.text) != nil {
                        self!.secondField.textfield.text = String((self!.secondField.textfield.text?.floatValue ?? 0) + 0.1)
                        self!.checkSecondField()
                    }
                }
            }
        }
        
        timer?.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
        
        // Make all textfields editable again (white to indicate)
        self.secondField.textfield.isUserInteractionEnabled = true
        self.minuteField.textfield.isUserInteractionEnabled = true
        self.hourField.textfield.isUserInteractionEnabled = true
    }
}
