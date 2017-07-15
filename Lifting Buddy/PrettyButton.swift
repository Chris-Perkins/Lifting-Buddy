//
//  PrettyButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

@IBDesignable class PrettyButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var shadowOpacity: Float = 1.0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var slideColor: UIColor = UIColor.white
    
    var slideViewTag: Int = 1337
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 3.0
        
        self.addTarget(self, action: #selector(touchInside), for: .touchDown)
        self.addTarget(self, action: #selector(releasePress), for: .touchUpInside)
        self.addTarget(self, action: #selector(releasePress), for: .touchUpOutside)
    }
    
    private func createSlideView() {
        // If slide view does not currently exist, create it
        if self.viewWithTag(slideViewTag) == nil {
            // Create view that slides to bottom right on press
            let overlayView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: self.frame.height))
            overlayView.layer.cornerRadius = cornerRadius
            overlayView.backgroundColor = slideColor
            overlayView.alpha = 0.25
            overlayView.layer.zPosition = -1
            overlayView.tag = slideViewTag
            self.addSubview(overlayView)
            
            UIView.animate(withDuration: 0.5, animations: {
                overlayView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            })
        }
    }
    
    private func removeSlideView() {
        // Delete slide view on release
        if let slideView: UIView = self.viewWithTag(slideViewTag) {
            UIView.animate(withDuration: 0.25, animations: {
                slideView.alpha = 0
            }, completion:
                {
                    (finished: Bool) -> Void in
                    slideView.removeFromSuperview()
            })
        }
    }
    
    @objc private func touchInside(sender: PrettyButton) {
        createSlideView()
    }
    
    @objc private func releasePress(sender: PrettyButton) {
        removeSlideView()
    }
}
