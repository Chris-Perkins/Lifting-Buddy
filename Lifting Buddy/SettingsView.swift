//
//  SettingsView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/5/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class SettingsView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /* Test Label */
        let testLabel: UILabel = UILabel(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: self.frame.width,
                                                       height: self.frame.height))
        testLabel.text = "TEST"
        self.addSubview(testLabel)
    }
}
