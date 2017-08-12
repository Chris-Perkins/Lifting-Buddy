//
//  CreateWorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/11/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class CreateWorkoutView: UIView {
    
    // View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.niceYellow()
        let lbl: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        lbl.text = "Preliminary work"
        lbl.textColor = UIColor.niceBlue()
        self.addSubview(lbl)
    }
}
