//
//  MessagesComposerTextView.swift
//  Campfire
//
//  Created by GoldRatio on 8/20/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit


class MessagesComposerTextView: UITextView
{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame, textContainer:nil)
        
        let cornerRadius: CGFloat = 4
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.cornerRadius = cornerRadius
        
        self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0, cornerRadius, 0.0)
        
        self.contentInset = UIEdgeInsetsMake(2.0, 0.0, 2.0, 0.0)
        
        self.scrollEnabled = true
        self.scrollsToTop = false
        self.userInteractionEnabled = true
        
        self.font = UIFont.systemFontOfSize(16)
        self.textColor = UIColor.blackColor()
        self.textAlignment = NSTextAlignment.Left
        
        self.contentMode = UIViewContentMode.Redraw
        self.dataDetectorTypes = UIDataDetectorTypes.None
        self.keyboardAppearance = UIKeyboardAppearance.Default
        self.keyboardType = UIKeyboardType.Default
        self.returnKeyType = UIReturnKeyType.Default
        
        self.addTextViewNotificationObservers()
    }
    
    func addTextViewNotificationObservers() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveTextViewNotification:",
            name: UITextViewTextDidChangeNotification,
            object: self)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveTextViewNotification:",
            name: UITextViewTextDidBeginEditingNotification,
            object: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveTextViewNotification:",
            name: UITextViewTextDidEndEditingNotification,
            object: self)
    }
    
    
    func removeTextViewNotificationObservers() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextViewTextDidChangeNotification,
            object: self)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextViewTextDidBeginEditingNotification,
            object: self)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UITextViewTextDidEndEditingNotification,
            object: self)
    }
    
    func didReceiveTextViewNotification(notification: NSNotification) {
        self.setNeedsDisplay()
    }
}