//
//  SectionView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class SectionView: UIView {
    override func layoutSubviews() {
        let width: CGFloat = self.frame.width / 4
        
        // Today Button
        let todayButton: UIButton = UIButton(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: width,
                                                           height: self.frame.height))
        todayButton.setTitle("today", for: .normal)
        todayButton.titleLabel?.textAlignment = .center
        todayButton.titleLabel?.textColor = .white
        self.addSubview(todayButton)
        
        // Workouts Button
        let workoutsButton: UIButton = UIButton(frame: CGRect(x: width,
                                                              y: 0,
                                                              width: width,
                                                              height: self.frame.height))
        workoutsButton.setTitle("workouts", for: .normal)
        workoutsButton.titleLabel?.textAlignment = .center
        workoutsButton.titleLabel?.textColor = .white
        self.addSubview(workoutsButton)
        
        
        // Statistics Button
        let statsButton: UIButton = UIButton(frame: CGRect(x: width * 2,
                                                           y: 0,
                                                           width: width,
                                                           height: self.frame.height))
        statsButton.setTitle("stats", for: .normal)
        statsButton.titleLabel?.textAlignment = .center
        statsButton.titleLabel?.textColor = .white
        self.addSubview(statsButton)
        
        // Settings Button
        let settingsButton: UIButton = UIButton(frame: CGRect(x: width * 3,
                                                              y: 0,
                                                              width: width,
                                                              height: self.frame.height))
        settingsButton.setTitle("settings", for: .normal)
        settingsButton.titleLabel?.textAlignment = .center
        settingsButton.titleLabel?.textColor = .white
        self.addSubview(settingsButton)
        
        super.layoutSubviews()
    }
}
