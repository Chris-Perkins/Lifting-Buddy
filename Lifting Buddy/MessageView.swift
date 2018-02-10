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
    private let height: CGFloat
    
    // The message we should be displaying
    public let message: Message
    
    public let imageView: UIImageView
    public let titleLabel: UILabel
    
    // MARK: View inits
    
    init(withMessage message: Message, andHeight height: CGFloat) {
        imageView        = UIImageView()
        titleLabel       = UILabel()
        
        self.message = message
        self.height  = height
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(imageView)
        
        createAndActivateTitleLabelConstraints()
        createAndActivateImageViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder Init Set for UIView")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Title label
        titleLabel.setDefaultProperties()
        titleLabel.textColor = .primaryBlackWhiteColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        titleLabel.text = message.messageTitle
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
                                                             attribute: .top,
                                                             plusConstant: statusBarHeight).isActive = true
        NSLayoutConstraint(item: imageView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: titleLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: height - statusBarHeight).isActive = true
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
                                                         height: height).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: imageView,
                                                        width: height).isActive = true
    }
}
