//
//  ImageButton.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ImageButton : UIControl {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var imageView: UIImageView = UIImageView()
    var textLabel: UILabel = UILabel()

    
    var image: UIImage? = nil
    var activeImage: UIImage?
    var text: String?
    var textColor: UIColor?
    var activeColor: UIColor?
    var padding: CGFloat = 10
    var autoBounce: Bool = false
    private var check: Bool = false
    
    var select: Bool {
        get {
            return self.check
        }
        set {
            if newValue != self.check {
                if newValue {
                    if let activeImage = activeImage? {
                        imageView.image = activeImage
                    }
                    if let activeColor = activeColor? {
                        textLabel.textColor = activeColor
                    }
                }
                else {
                    textLabel.textColor = textColor
                    imageView.image = image
                }
                self.check = newValue
            }
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
    }
    
    
    
    
    init(frame: CGRect, image: UIImage, text: String, textColor: UIColor, vertical: Bool = true) {
        
        if vertical {
            let height = frame.size.height * 3 / 5
            imageView.frame = CGRectMake(0, 5, frame.size.width, height)
            textLabel.frame = CGRectMake(0, height, frame.size.width, frame.size.height - height)
        }
        else {
            let height = frame.size.height
            
            imageView.frame = CGRectMake(5, 0, image.size.width, height)
            textLabel.frame = CGRectMake(10 + image.size.width, 0, frame.size.width - image.size.width - 10, height)
        }
        imageView.contentMode = UIViewContentMode.Center
        
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.font = MAIN_BOTTON_FONT;
        textLabel.textColor = textColor
        
        imageView.image = image
        textLabel.text = text
        
        self.image = image
        self.text = text
        self.textColor = textColor
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(textLabel)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if (autoBounce) {
            self.select = true
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if (autoBounce) {
            self.select = false
        }
        if (self.select && !autoBounce) {
            return
        }
        if touches.anyObject().tapCount == 1 {
            self.select = !self.select
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func sendActionsForControlEvents(controlEvents: UIControlEvents) {
        for target in self.allTargets() {
            let actionForTarget = self.actionsForTarget(target, forControlEvent: controlEvents)
            for action in actionForTarget {
                let selector = NSSelectorFromString(action as String)
                self.sendAction(selector, to: target, forEvent: nil)
            }
        }
    }
    
    
}