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
    // The email url for assistance
    private static let emailURL = URL(string: "mailto:chris@chrisperkins.me")!
    // The height for github link view
    private static let linkHeights: CGFloat = 40
    // The link url for the github project
    private static let githubLinkURL = URL(string: "https://github.com/Chris-Perkins/Lifting-Buddy")!
    
    // The version label
    private let versionLabel: UILabel
    // The about description
    private let aboutDescription: UITextView
    // The link for reporting bugs
    private let supportLink: UITextView
    // The link to GitHub
    private let githubLink: UITextView
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        versionLabel = UILabel()
        aboutDescription = UITextView()
        supportLink = UITextView()
        githubLink = UITextView()
        
        super.init(frame: frame)
        
        addSubview(versionLabel)
        addSubview(aboutDescription)
        addSubview(supportLink)
        addSubview(githubLink)
        
        createAndActivateVersionLabelConstraints()
        createAndActivateAboutDescriptionConstraints()
        createAndActivateSupportLinkConstraints()
        createAndActivateGithubLinkConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Some basics
        let centerStyle = NSMutableParagraphStyle()
        centerStyle.alignment = .center
        
        let defaultAttributes: [NSAttributedStringKey : Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .paragraphStyle: centerStyle,
            .foregroundColor: UIColor.niceBlue
        ]

        
        // Version label
        
        versionLabel.setDefaultProperties()
        versionLabel.text = "v\(GBVersionTracking.currentVersion() ?? "?")"
        versionLabel.backgroundColor = .white
        
        // About description
        
//        let abtDesc = NSMutableAttributedString(string: "")
//        abtDesc.append(contactStr)
//        abtDesc.append(emailStr)
        aboutDescription.backgroundColor = .niceGray
        aboutDescription.isEditable = false
//        aboutDescription.attributedText = abtDesc
        
        // Email Link
        
        let contactStr = NSMutableAttributedString(string: "Support: ")
        contactStr.addAttributes(defaultAttributes,
                                 range: NSMakeRange(0, contactStr.length))
        
        let emailStr = NSMutableAttributedString(string: "chris@chrisperkins.me")
        emailStr.addAttributes([
            .link: AboutView.emailURL,
            .font: UIFont.boldSystemFont(ofSize: 15),
            .paragraphStyle: centerStyle
            ], range: NSMakeRange(0, emailStr.length))
        contactStr.append(emailStr)
        
        supportLink.delegate = self
        supportLink.isEditable = false
        supportLink.attributedText = contactStr
        
        // Github Link
        
        let gitStr = NSMutableAttributedString(string: "View code on GitHub")
        gitStr.addAttributes([
                .link: AboutView.githubLinkURL,
                .font: UIFont.boldSystemFont(ofSize: 18),
                .paragraphStyle: centerStyle
            ], range: NSMakeRange(0, gitStr.length))
        
        githubLink.delegate = self
        githubLink.isEditable = false
        githubLink.attributedText = gitStr
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
    
    // Cling to left, right ; Place below versionLabel ; place above contact link
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
    
    // Cling to left, right of this view ; place about githublink ; height of link height
    private func createAndActivateSupportLinkConstraints() {
        supportLink.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: supportLink,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: supportLink,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: supportLink,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: githubLink,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: supportLink,
                                                         height: AboutView.linkHeights).isActive = true
    }
    
    // Place between left, right, bottom margins. Height of linkheight
    private func createAndActivateGithubLinkConstraints() {
        githubLink.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: githubLink,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: githubLink,
                                                         height: AboutView.linkHeights
                                                        ).isActive = true
    }
}

extension AboutView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

