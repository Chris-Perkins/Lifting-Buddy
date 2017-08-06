//
//  SectionView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Sections shown on the bottom of the header view

import UIKit

class SectionView: UIView {
    // MARK: View properties
    
    // Required view for modifying sectionContentView
    var mainViewController: MainViewController?
    // Our sections
    var todayButton: PrettyButton?
    var workoutsButton: PrettyButton?
    var statsButton: PrettyButton?
    var settingsButton: PrettyButton?
    
    var selectedView: PrettyButton?
    
    
    // MARK: Enums
    
    public enum contentViews {
        case TODAY
        case WORKOUTS
        case STATS
        case SETTINGS
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainViewController = (self.next?.next?.next as! MainViewController)
        
        let width: CGFloat = self.frame.width / 4
        
        // Today Button
        todayButton =
            PrettyButton(frame: CGRect(x: 0,
                                       y: 0,
                                    width: width,
                                    height: self.frame.height))
        
        todayButton?.setTitle("today", for: .normal)
        todayButton?.titleLabel?.textColor = .white
        todayButton?.setOverlayStyle(style: .BLOOM)
        todayButton?.addTarget(self, action: #selector(self.showTodayView), for: .touchUpInside)
        self.addSubview(todayButton!)
        
        // Workouts Button
        workoutsButton =
            PrettyButton(frame: CGRect(x: width,
                                       y: 0,
                                       width: width,
                                       height: self.frame.height))
        
        workoutsButton?.setTitle("workouts", for: .normal)
        workoutsButton?.titleLabel?.textColor = .white
        workoutsButton?.setOverlayStyle(style: .BLOOM)
        workoutsButton?.addTarget(self, action: #selector(self.showWorkoutView), for: .touchUpInside)
        self.addSubview(workoutsButton!)
        
        
        // Statistics Button
        statsButton =
            PrettyButton(frame: CGRect(x: width * 2,
                                       y: 0,
                                       width: width,
                                       height: self.frame.height))
        
        statsButton?.setTitle("stats", for: .normal)
        statsButton?.titleLabel?.textColor = .white
        statsButton?.setOverlayStyle(style: .BLOOM)
        statsButton?.addTarget(self, action: #selector(self.showStatsView), for: .touchUpInside)
        self.addSubview(statsButton!)
        
        // Settings Button
        settingsButton =
            PrettyButton(frame: CGRect(x: width * 3,
                                       y: 0,
                                       width: width,
                                       height: self.frame.height))
        
        settingsButton?.setTitle("settings", for: .normal)
        settingsButton?.titleLabel?.textColor = .white
        settingsButton?.setOverlayStyle(style: .BLOOM)
        settingsButton?.addTarget(self, action: #selector(self.showSettingsView), for: .touchUpInside)
        self.addSubview(settingsButton!)
    }
    
    
    // MARK: Private functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    private func showContentView(viewType: SectionView.contentViews) {
        mainViewController?.showContentView(viewType: viewType)
    }
    
    
    // MARK: Event functions
    
    // TODO: Handle this in a better way...
    
    @objc private func showTodayView() {
        if selectedView != nil {
            selectedView?.backgroundColor = nil
        }
        todayButton?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectedView = todayButton
        
        self.showContentView(viewType: SectionView.contentViews.TODAY)
    }
    
    @objc private func showWorkoutView() {
        if selectedView != nil {
            selectedView?.backgroundColor = nil
        }
        workoutsButton?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectedView = workoutsButton
        
        self.showContentView(viewType: SectionView.contentViews.WORKOUTS)
    }
    
    @objc private func showStatsView() {
        if selectedView != nil {
            selectedView?.backgroundColor = nil
        }
        statsButton?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectedView = statsButton
        
        self.showContentView(viewType: SectionView.contentViews.STATS)
    }
    
    @objc private func showSettingsView() {
        if selectedView != nil {
            selectedView?.backgroundColor = nil
        }
        settingsButton?.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        selectedView = settingsButton
        
        self.showContentView(viewType: SectionView.contentViews.SETTINGS)
    }
}
