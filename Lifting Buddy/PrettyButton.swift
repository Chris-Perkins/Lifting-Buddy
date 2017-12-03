//
//  PrettyButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// A button with animations. It looks pretty. Pretty Button.

import UIKit

@IBDesignable class PrettyButton: UIButton {
    
    // MARK: IBInspectables
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var shadowOpacity: Float = 0.2 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable private var overlayColor: UIColor = UIColor.white.withAlphaComponent(0.25)
    @IBInspectable public var animationTimeInSeconds: Double = 0.2
    
    // MARK: Properties
    
    // tag of overlay view
    private static let overlayViewTag: Int = 1337
    
    public enum Styles {
        case NONE
        case SLIDE
        case BLOOM
        case FADE
    }
    
    // Default style of button is none
    private var style: PrettyButton.Styles
    
    // MARK: Init Functions
    
    override init(frame: CGRect) {
        style = Styles.NONE
        
        super.init(frame: frame)
        
        // Set shadows for the button
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3.0
        
        // User selected button
        addTarget(self, action: #selector(startPress(sender:)), for: .touchDown)
        
        // User exited the button
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchDragExit)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchUpInside)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchUpOutside)
        addTarget(self, action: #selector(releasePress(sender:)), for: .touchCancel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        style = Styles.NONE
        
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch? = touches.first
        
        if touch?.view != self {
            removeOverlayView()
            layoutSubviews()
        }
    }
    
    // MARK: Event functions
    
    @objc func startPress(sender: PrettyButton) {
        switch style {
        case Styles.NONE:
            break
        case Styles.SLIDE:
            createSlideView()
            break
        case Styles.BLOOM:
            createBloomView()
            break
        case Styles.FADE:
            createFadeView()
            break
        }
    }
    
    @objc private func releasePress(sender: PrettyButton) {
        removeOverlayView()
    }
    
    // MARK: Custom view handling
    
    // Create overlay view with default properties
    private func createOverlayView(frame: CGRect) -> UIView {
        if let overlayView = viewWithTag(PrettyButton.overlayViewTag) {
            return overlayView
        } else {
            // Create view that slides to bottom right on press
            let overlayView: UIView = UIView.init(frame: frame)
            overlayView.layer.cornerRadius = cornerRadius
            overlayView.backgroundColor = overlayColor
            // Display behind the title
            overlayView.layer.zPosition = -1
            // Set tag to find this view later
            overlayView.tag = PrettyButton.overlayViewTag
            
            return overlayView
        }
    }
    
    // Creates the sliding effect on the button's background
    private func createSlideView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView(frame:
                CGRect(x: 0,
                       y: 0,
                       width: 1,
                       height: frame.height))
            addSubview(overlayView)
            
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: self.frame.width,
                                           height: self.frame.height)
            })
        }
    }
    
    // Bloom from inside
    private func createBloomView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView(frame:
                CGRect(x: frame.width / 2,
                       y: frame.height / 2,
                       width: 0,
                       height: 0))
            addSubview(overlayView)
            
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: self.frame.width,
                                           height: self.frame.height)
            })
        }
    }
    
    // Fades a view in
    private func createFadeView() {
        // If slide view does not currently exist, create it
        if viewWithTag(PrettyButton.overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = createOverlayView(frame: CGRect(x: 0,
                                                                      y: 0,
                                                                      width: frame.width,
                                                                      height: frame.height))
            // Fade view in
            overlayView.alpha = 0
            addSubview(overlayView)
            
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.alpha = 1
            })
        }
    }
    
    public func removeOverlayView() {
        // Delete slide view on release
        if let overlayView: UIView = viewWithTag(PrettyButton.overlayViewTag) {
            UIView.animate(withDuration: animationTimeInSeconds, animations: {
                overlayView.alpha = 0
            }, completion: { (finished: Bool) -> Void in
                overlayView.removeFromSuperview()
            })
        }
    }
    
    // MARK: Get / Set Methods
    
    public func setOverlayStyle(style: PrettyButton.Styles) {
        self.style = style
    }
    
    public func setOverlayColor(color: UIColor) {
        overlayColor = color
    }
}
