//
//  MessagesInputToolbar.swift
//  Campfire
//
//  Created by GoldRatio on 8/20/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

protocol MessageInputViewDelegate: UITextViewDelegate
{
    func didSelectedMultipleMediaAction(change: Bool)
}

class MessagesInputToolbar: UIView
{
    let contentView: MessagesComposerTextView
    var inputDelegate: MessageInputViewDelegate?
    
    var delegate: MessageInputViewDelegate? {
        get {
            return self.inputDelegate
        }
        set {
            self.inputDelegate = newValue
            self.contentView.delegate = newValue
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        super.init(frame: frame)
        
        self.backgroundColor = UIColorFromRGB(0xDCDCDC)
        
        self.addSubview(self.contentView)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let left = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 9)
        self.addConstraint(left)
        
        let right = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: -97)
        self.addConstraint(right)
        
        
        let top = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 7)
        self.addConstraint(top)
        
        
        let bottom = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -7)
        self.addConstraint(bottom)
    }
    
}