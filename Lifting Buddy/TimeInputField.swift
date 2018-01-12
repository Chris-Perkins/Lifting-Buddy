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
        self.timeInputView = BetterInputView(args: [(NSLocalizedString("Time.Hour.Char", comment: ""),
                                                     "0", true),
                                                    (NSLocalizedString("Time.Minute.Char", comment: ""), "0", true),
                                                    (NSLocalizedString("Time.Second.Char", comment: ""), "0", true)], frame: .zero)
        
        let inputViews = timeInputView.getInputViews()
        hourField = inputViews[0]
        minuteField = inputViews[1]
        secondField = inputViews[2]
        
        self.timerButton = ToggleablePrettyButton()
        
        super.init(frame: frame)
        
        addSubview(self.timeInputView)
        addSubview(self.timerButton)
        
        minuteField.textfield.addTarget(self,
                                        action: #selector(checkField(sender:)),
                                        for: .editingDidEnd)
        secondField.textfield.addTarget(self,
                                        action: #selector(checkField(sender:)),
                                        for: .editingDidEnd)
        hourField.textfield.addTarget(self,
                                      action: #selector(checkField(sender:)),
                                      for: .editingDidEnd)
        
        timerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        createAndActivateTimerButtonConstraints()
        createAndActivateInputViewContainerConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: view overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        timerButton.setToggleTextColor(color: .white)
        timerButton.setDefaultTextColor(color: .white)
        timerButton.setDefaultText(text: NSLocalizedString("Timer.Start", comment: ""))
        timerButton.setToggleText( text: NSLocalizedString("Timer.Stop", comment: ""))
        timerButton.setToggleViewColor(color: .niceYellow)
        timerButton.setDefaultViewColor(color: .niceBlue)
    }
    
    // MARK: View functions
    
    // Sets the placeholder of all views to be empty.
    // Done to let the user enter values without text becoming full string
    public func clearTimeFieldPlaceholders() {
        secondField.setDefaultString(defaultString: "0")
        minuteField.setDefaultString(defaultString: "0")
        hourField.setDefaultString(  defaultString: "0")
    }
    
    // MARK: Events functions
    
    @objc internal func checkField(sender: UITextField) {
        sender.textfieldDeselected(sender: sender)
        // Clear time fields for view cleanliness
        clearTimeFieldPlaceholders()
        
        switch (sender) {
        case secondField.textfield: // Make sure entered time < 60, otherwise send the rest to the minute field
            if let seconds = secondField.textfield.text?.floatValue, seconds >= 60.0 {
                minuteField.textfield.text = String((minuteField.textfield.text!.floatValue ?? 0) +
                    floor((secondField.textfield.text?.floatValue)! / 60))
                secondField.textfield.text = String(secondField.textfield.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
                
                // Now we need to check if the minutes are still < 60
                self.checkField(sender: minuteField.textfield)
            }
        case minuteField.textfield: // Make sure entered time < 60, otherwise send the rest to hour field
            if let minutes = minuteField.textfield.text?.floatValue, minutes >= 60 {
                hourField.textfield.text = String((hourField.textfield.text!.floatValue ?? 0) +
                    floor((minuteField.textfield.text?.floatValue)! / 60))
                minuteField.textfield.text = String(minuteField.textfield.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
            }
        case hourField.textfield: // We don't need to check the hour field.
            break
        default:
            fatalError("Textfield sent editing did end for timeinputfield, but was not set up.")
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
    
    // MARK: View constraints
    
    // cling to top, bottom, right. width of timer button's new height
    private func createAndActivateTimerButtonConstraints() {
        self.timerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timerButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timerButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timerButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timerButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.25).isActive = true
    }
    
    // Take up whatever the timer button isn't
    private func createAndActivateInputViewContainerConstraints() {
        timeInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeInputView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeInputView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeInputView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint(item: timerButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: timeInputView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    /// MARK: Timer functions
    
    private func startTimer() {
        //  Make all textfields non-editable (gray to indicate)
        secondField.textfield.isUserInteractionEnabled = false
        minuteField.textfield.isUserInteractionEnabled = false
        hourField.textfield.isUserInteractionEnabled   = false
        
        let queue = DispatchQueue(label: "com.firm.app.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .never)
        
        timer?.setEventHandler { [weak self] in
            
            if self != nil {
                DispatchQueue.main.async {
                    if (self!.secondField.textfield.text) != nil {
                        self!.secondField.textfield.text = String((self!.secondField.textfield.text?.floatValue ?? 0) + 0.1)
                        self!.checkField(sender: self!.secondField.textfield)
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
        secondField.textfield.isUserInteractionEnabled = true
        minuteField.textfield.isUserInteractionEnabled = true
        hourField.textfield.isUserInteractionEnabled = true
    }
}

extension TimeInputField: InputViewHolder {
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
            field.backgroundColor = .niceRed
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
            totalSeconds += 60 * 60 * self.hourField.text!.floatValue!
        }
        
        return String(totalSeconds)
    }
    
    // Sets the value of the second/minute/hour fields using the given number of seconds
    internal func setDefaultValue(_ value: String?) {
        if let secondsString = value, let seconds = secondsString.floatValue {
            // We separate the values out using division in case of negative numbers.
            // modulo operator wouldn't play out very well with those negatives.
            let totalSeconds = mod(x: seconds, m: 60.0)
            let totalMinutes = mod(x: (seconds - totalSeconds) / 60, m: 60.0)
            let totalHours   = (seconds - totalSeconds - totalMinutes * 60) / (60 * 60)
            
            
            secondField.setDefaultString(defaultString: String(format: "%.1f", totalSeconds))
            minuteField.setDefaultString(defaultString: String(format: "%.1f", totalMinutes))
            hourField.setDefaultString(defaultString:   String(format: "%.1f", totalHours))
        }
    }
    
    internal func clearFields() {
        secondField.textfield.text = nil
        minuteField.textfield.text = nil
        hourField.textfield.text = nil
    }
}
