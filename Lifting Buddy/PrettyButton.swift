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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 5.0
    }
    
    func buttonPressed() {
        let view: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = cornerRadius
        view.alpha = 0.25
        self.addSubview(view)
        UIView.animate(withDuration: 0.5, animations: {
            view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        })
    }
}
