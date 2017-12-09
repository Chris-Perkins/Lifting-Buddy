//
//  AboutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/01/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import GBVersionTracking

// A simple 'about' page.

class AboutView: UIView {
    
    // MARK: View properties
    
    // Height for version label
    private static let versionLabelHeight: CGFloat = 40
    // The height for github link view
    private static let githubLinkViewHeight: CGFloat = 40
    // The link url for the github project
    private static let githubLinkURL = URL(string: "https://github.com/Chris-Perkins/Lifting-Buddy")!
    
    // The version label
    private let versionLabel: UILabel
    // The about description
    private let aboutDescription: UITextView
    // The link to GitHub
    private let githubLink: UITextView
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        versionLabel = UILabel()
        aboutDescription = UITextView()
        githubLink = UITextView()
        
        super.init(frame: frame)
        
        addSubview(versionLabel)
        addSubview(aboutDescription)
        addSubview(githubLink)
        
        createAndActivateVersionLabelConstraints()
        createAndActivateAboutDescriptionConstraints()
        createAndActivateGithubLinkConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Version label
        
        versionLabel.setDefaultProperties()
        versionLabel.text = "v\(GBVersionTracking.currentVersion() ?? "?")"
        versionLabel.backgroundColor = .white
        
        // About description
        aboutDescription.backgroundColor = .niceGray
        
        
        // Github Link
        
        let attStr = NSMutableAttributedString(string: "View code on GitHub")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        attStr.addAttributes([
            .link: AboutView.githubLinkURL,
            .font: UIFont.boldSystemFont(ofSize: 18),
            .paragraphStyle: paragraphStyle
        ], range: NSMakeRange(0, attStr.length))
        githubLink.delegate = self
        githubLink.attributedText = attStr
        githubLink.isEditable = false
    }
    
    // MARK: Constraint functions
    
    // cling to left, right, top of self ; height of 50
    private func createAndActivateVersionLabelConstraints() {
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: versionLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: versionLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: versionLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: versionLabel,
                                                         height: AboutView.versionLabelHeight
                                                        ).isActive = true
    }
    
    // Cling to left, right ; Place below versionLabel ; place about github link
    private func createAndActivateAboutDescriptionConstraints() {
        aboutDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutDescription,
                                                             withCopyView: self,
                                                             attribute: .leftMargin,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutDescription,
                                                             withCopyView: self,
                                                             attribute: .rightMargin,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: aboutDescription,
                                                         belowView: versionLabel).isActive = true
        NSLayoutConstraint(item: githubLink,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: aboutDescription,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Place between left, right, bottom margins. Height of githubviewheight
    private func createAndActivateGithubLinkConstraints() {
        githubLink.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .leftMargin).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .rightMargin).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .bottomMargin).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: githubLink,
                                                         height: AboutView.githubLinkViewHeight
                                                        ).isActive = true
    }
}

extension AboutView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

