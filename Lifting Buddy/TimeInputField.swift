//
//  TimeInputField.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class TimeInputField: UIView, InputViewHolder {
    
    // MARK: View properties
    
    // The input view for time
    private var timeInputView: BetterInputView
    // The hour field
    public var hourField: BetterTextField
    // The minute field
    public var minuteField: BetterTextField
    // The second field
    public var secondField: BetterTextField
    
    // A timerbutton that can be pressed to increase time
    private var timerButton: ToggleablePrettyButton
    // The timer for this view
    private var timer: DispatchSourceTimer?
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        self.timeInputView = BetterInputView(args: [("h", "0", true),
                                                    ("m", "0", true),
                                                    ("s", "0", true)], frame: .zero)
        
        let inputViews = timeInputView.getInputViews()
        hourField = inputViews[0]
        minuteField = inputViews[1]
        secondField = inputViews[2]
        
        self.timerButton = ToggleablePrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(self.timeInputView)
        self.addSubview(self.timerButton)
        
        self.minuteField.textfield.addTarget(self, action: #selector(checkMinuteField), for: .editingDidEnd)
        self.secondField.textfield.addTarget(self, action: #selector(checkSecondField), for: .editingDidEnd)
        self.timerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.createAndActivateTimerButtonConstraints()
        self.createAndActivateInputViewContainerConstraints()
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
    
    // MARK: InputViewHolder protocol
    
    // Returns our input views
    internal func getInputViews() -> [BetterTextField] {
        return self.timeInputView.getInputViews()
    }
    
    // Returns whether not we have a valid time format
    internal func areFieldsValid() -> Bool {
        return  checkIfFieldValid(field: secondField) &&
                checkIfFieldValid(field: minuteField) &&
                checkIfFieldValid(field: hourField)
    }
    
    // Helper for checking if fields are valid
    private func checkIfFieldValid(field: BetterTextField) -> Bool {
        let returnValue = field.text != nil
        
        if !returnValue {
            field.backgroundColor = UIColor.niceRed()
        }
        
        return returnValue
    }
    
    // Returns time as a function of seconds
    internal func getValue() -> String {
        // -1 indicates something went wrong
        var totalSeconds: Float = -1
        
        if self.areFieldsValid() {
            totalSeconds = 0
            
            totalSeconds += self.secondField.text!.floatValue!
            totalSeconds += 60 * self.minuteField.text!.floatValue!
            totalSeconds += 60 * 60 * self.minuteField.text!.floatValue!
        }
        
        return String(totalSeconds)
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
        self.timeInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.timeInputView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.timeInputView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.timeInputView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self.timerButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.timeInputView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
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
