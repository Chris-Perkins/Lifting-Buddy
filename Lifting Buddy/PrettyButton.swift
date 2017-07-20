//
//  PrettyButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

@IBDesignable class PrettyButton: UIButton {
    
    // MARK: IBInspectables
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var shadowOpacity: Float = 0.2 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable private var overlayColor: UIColor = UIColor.white
    
    // MARK: Properties
    
    public enum Styles {
        case SLIDE
        case BLOOM
    }
    
    // Current style of this button
    private var style: PrettyButton.Styles
    // tag of overlay view
    var overlayViewTag: Int = 1337
    
    // MARK: Init Functions
    
    override init(frame: CGRect) {
        self.style = Styles.SLIDE
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.style = Styles.SLIDE
        
        super.init(coder: aDecoder)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 3.0
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addTarget(self, action: #selector(touchInside), for: .touchDown)
        self.addTarget(self, action: #selector(releasePress), for: .touchUpInside)
        self.addTarget(self, action: #selector(releasePress), for: .touchUpOutside)
    }
    
    // MARK: Custom view handling
    
    public func setOverlayStyle(style: PrettyButton.Styles) {
        self.style = style
    }
    
    public func setOverlayColor(color: UIColor) {
        self.overlayColor = color
    }
    
    // Creates the sliding effect on the button's background
    private func createSlideView() {
        // If slide view does not currently exist, create it
        if self.viewWithTag(overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = UIView.init(frame: CGRect(x: 0,
                                                                y: 0,
                                                                width: 1,
                                                                height: self.frame.height))
            overlayView.layer.cornerRadius = cornerRadius
            overlayView.backgroundColor = self.overlayColor
            overlayView.alpha = 0.25
            overlayView.layer.zPosition = -1
            overlayView.tag = self.overlayViewTag
            self.addSubview(overlayView)
            
            UIView.animate(withDuration: 0.5, animations: {
                overlayView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            })
        }
    }
    
    // Bloom from inside
    private func createBloomView() {
        // If slide view does not currently exist, create it
        if self.viewWithTag(overlayViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = UIView.init(frame: CGRect(x: self.frame.width / 2,
                                                                y: self.frame.height / 2,
                                                                width: 0,
                                                                height: 0))
            overlayView.layer.cornerRadius = cornerRadius
            overlayColor.withAlphaComponent(0.5)
            overlayView.backgroundColor = self.overlayColor
            // Start alpha low, then buff opacity during animation
            overlayView.alpha = 0.05
            overlayView.layer.zPosition = -1
            overlayView.tag = self.overlayViewTag
            self.addSubview(overlayView)
            
            UIView.animate(withDuration: 0.5, animations: {
                overlayView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                overlayView.alpha = 0.25
            })
        }
    }
    
    private func removeOverlayView() {
        // Delete slide view on release
        if let slideView: UIView = self.viewWithTag(self.overlayViewTag) {
            UIView.animate(withDuration: 0.25, animations: {
                slideView.alpha = 0
            }, completion:
                {
                    (finished: Bool) -> Void in
                    slideView.removeFromSuperview()
                    // Set overlay color alpha to 1.0 for premature animation end
                    self.overlayColor.withAlphaComponent(1.0)
            })
        }
    }
    
    // MARK: Action functions
    
    @objc private func touchInside(sender: PrettyButton) {
        switch self.style {
        case Styles.SLIDE:
            createSlideView()
            break
        case Styles.BLOOM:
            createBloomView()
            break
        }
    }
    
    @objc private func releasePress(sender: PrettyButton) {
        removeOverlayView()
    }
}
