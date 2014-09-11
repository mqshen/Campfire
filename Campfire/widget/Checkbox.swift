//
//  Checkbox.swift
//  Campfire
//
//  Created by GoldRatio on 9/7/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

protocol CheckBoxTappedProtocol
{
    func checkBoxTapped(sender: UIControl, event: UIEvent)
}

class Checkbox : UIControl
{
    var _checked: Bool = false
    var checked: Bool {
        get {
            return _checked
        }
        set {
            self._checked = newValue
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let size = min(self.bounds.size.width, self.bounds.size.height)
        
        var transform = CGAffineTransformIdentity
        
        if (self.bounds.size.width < self.bounds.size.height) {
            // Vertical Center
            transform = CGAffineTransformMakeTranslation(0, (self.bounds.size.height - size)/2);
        }
        else if (self.bounds.size.width > self.bounds.size.height) {
            // Horizontal Center
            transform = CGAffineTransformMakeTranslation((self.bounds.size.width - size)/2, 0);
        }
        
        
        if (self._checked) {
            if ((self.tintColor) != nil) {
                CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
                CGContextFillRect(context, self.bounds)
            }
            func P(point: CGFloat) -> CGFloat{
                return point * size
            }
            
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor);
            
            CGContextConcatCTM(context, transform);
            
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, P(0.267), P(0.5))
            CGContextAddLineToPoint(context, P(0.417), P(0.65))
            CGContextAddLineToPoint(context, P(0.717), P(0.367))
            CGContextAddLineToPoint(context, P(0.667), P(0.317))
            CGContextAddLineToPoint(context, P(0.417), P(0.55))
            CGContextAddLineToPoint(context, P(0.333), P(0.467))
            
            CGContextClosePath(context)
            
            CGContextFillPath(context)
        }
    }
    

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if touches.anyObject()?.tapCount == 1 {
            self.checked = !self.checked
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged, event: event)
        }
    }
    
    func sendActionsForControlEvents(controlEvents: UIControlEvents, event: UIEvent) {
        for target in self.allTargets() {
            let actionsForTarget = self.actionsForTarget(target, forControlEvent: controlEvents)
            for action in actionsForTarget! {
                let selector = NSSelectorFromString(action as String)
                self.sendAction(selector, to: target, forEvent: event)
            }
        }
    }
}