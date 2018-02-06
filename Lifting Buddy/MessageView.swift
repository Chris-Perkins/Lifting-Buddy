//
//  MessageView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 2/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    // MARK: View properties
    
    // Height that this view should be drawn as
    public static let height: CGFloat = 70
    private var titleLabelHeight: CGFloat {
        return MessageView.height - (message.messageDescription == nil ? 0.0 : 30.0)
    }
    private var descriptionLabelHeight: CGFloat {
        return MessageView.height - titleLabelHeight
    }
    
    // The message we should be displaying
    public let message: Message
    
    public let descriptionLabel: UILabel
    public let imageView: UIImageView
    public let titleLabel: UILabel
    
    // MARK: View inits
    
    init(withMessage message: Message) {
        imageView        = UIImageView()
        titleLabel       = UILabel()
        descriptionLabel = UILabel()
        
        self.message = message
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(imageView)
        
        createAndActivateTitleLabelConstraints()
        createAndActivateDescriptionLabelConstraints()
        createAndActivateImageViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder Init Set for UIView")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self
        backgroundColor = UIColor.niceBlue
        
        // Title label
        titleLabel.setDefaultProperties()
        titleLabel.textColor = .primaryBlackWhiteColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        titleLabel.text = message.messageTitle
        
        descriptionLabel.setDefaultProperties()
        descriptionLabel.textColor = .primaryBlackWhiteColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 18.0)
        descriptionLabel.text = message.messageDescription
    }
    
    // MARK: Constraints
    
    // Cling to left, top of self ; right to image view ; height of titlelabelheight
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: imageView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: titleLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: titleLabelHeight).isActive = true
    }
    
    // Cling to left, bottom of self ; right to image view ; height of descriptionlabelheight
    private func createAndActivateDescriptionLabelConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: descriptionLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 15).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: descriptionLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint(item: imageView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: descriptionLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: descriptionLabel,
                                                         height: descriptionLabelHeight).isActive = true
    }
    
    // Cling to right, bottom of self ; height of self ; width = height
    private func createAndActivateImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: imageView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: imageView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: imageView,
                                                         height: MessageView.height).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: imageView,
                                                        width: MessageView.height).isActive = true
    }
}
