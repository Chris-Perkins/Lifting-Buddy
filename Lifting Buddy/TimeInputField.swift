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
    
    private var hourField: BetterTextField
    private var minuteField: BetterTextField
    private var secondField: BetterTextField
    
    private var views: [UIView]
    
    private var timerButton: ToggleablePrettyButton
    private var timer: DispatchSourceTimer?
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        self.hourField = BetterTextField(defaultString: "0", frame: .zero)
        self.minuteField = BetterTextField(defaultString: "0", frame: .zero)
        self.secondField = BetterTextField(defaultString: "0", frame: .zero)
        self.timerButton = ToggleablePrettyButton()
        
        self.views = [UIView]()
        
        super.init(frame: frame)
        
        self.addSubview(hourField)
        self.addSubview(minuteField)
        self.addSubview(secondField)
        self.addSubview(timerButton)
        
        self.views.append(hourField)
        self.views.append(minuteField)
        self.views.append(secondField)
        self.views.append(timerButton)
        
        self.minuteField.addTarget(self, action: #selector(checkMinuteField), for: .editingDidEnd)
        self.secondField.addTarget(self, action: #selector(checkSecondField), for: .editingDidEnd)
        self.timerButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: view overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hourField.setDefaultProperties()
        hourField.setIsNumeric(isNumeric: true)
        hourField.setLabelTitle(title: "h")
        
        minuteField.setDefaultProperties()
        minuteField.backgroundColor = UIColor.white
        minuteField.setIsNumeric(isNumeric: true)
        minuteField.setLabelTitle(title: "m")
        
        secondField.setDefaultProperties()
        secondField.setIsNumeric(isNumeric: true)
        secondField.setLabelTitle(title: "s")
        
        
        timerButton.setToggleViewColor(color: UIColor.niceGreen())
        timerButton.setDefaultViewColor(color: UIColor.niceBlue())
    }
    
    // MARK: Events functions
    
    @objc private func checkSecondField() {
        secondField.textfieldDeselected(sender: secondField)
        
        minuteField.text = String(minuteField.text!.floatValue! + floor((secondField.text?.floatValue)! / 60))
        secondField.text = String(secondField.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
        
        self.checkMinuteField()
    }
    
    @objc private func checkMinuteField() {
        minuteField.textfieldDeselected(sender: minuteField)
        
        hourField.text = String(hourField.text!.floatValue! + floor((minuteField.text?.floatValue)! / 60))
        minuteField.text = String(minuteField.text!.floatValue!.truncatingRemainder(dividingBy: 60.0))
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
    
    private func createConstraints() {
        var prevView: UIView = self
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: self,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == self ? .left : .right,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .width,
                               multiplier: 4,
                               constant: 0).isActive = true
            
            prevView = view
        }
    }
    
    // Timer functions
    
    private func startTimer() {
        let queue = DispatchQueue(label: "com.firm.app.timer", attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .never)
        
        timer?.setEventHandler { [weak self] in
            
            if self != nil {
                DispatchQueue.main.async {
                    if (self!.secondField.text) != nil {
                        self!.secondField.text = String((self!.secondField.text?.floatValue ?? 0) + 0.1)
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
    }
}
