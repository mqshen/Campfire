//
//  PopupView.swift
//  Campfire
//
//  Created by GoldRatio on 9/6/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

let POPUP_ROOT_SIZE = CGSizeMake(20, 10)

class TouchPeekView: UIView
{
    var delegate: PopupView?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let view = self.delegate? {
            view.hide()
        }
    }
}

class PopupView: UIView
{

    var horizontalOffset: CGFloat
    
    var peekView: TouchPeekView?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        horizontalOffset = -frame.origin.x
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    //var popupRect:CGRect = CGRectMake(0, 0, 100, 100)
    var pointToBeShown: CGPoint = CGPointZero
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.8)
        
        CGContextSetShadowWithColor (context, CGSizeMake(0, 2), 2, UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).CGColor)
        
        self.makePathCircleCornerRect(rect, radius: 4, popPoint: pointToBeShown)
        
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
//        CGContextSaveGState(context)
//        self.makePathCircleCornerRect(popupRect, radius: 4, popPoint: pointToBeShown)
//        
//        
//        CGContextDrawLinearGradient(context,
//            gradient,
//            CGPointMake(0, popupRect.origin.y),
//            CGPointMake(0, popupRect.origin.y + (popupRect.size.height-POPUP_ROOT_SIZE.height)/2), 0)
//        
//        CGContextDrawLinearGradient(context,
//            gradient2,
//            CGPointMake(0, popupRect.origin.y + (popupRect.size.height-POPUP_ROOT_SIZE.height)/2),
//            CGPointMake(0, popupRect.origin.y + popupRect.size.height-POPUP_ROOT_SIZE.height), 0)
//        CGContextRestoreGState(context)
        
    }
    
    func makePathCircleCornerRect(viewRect: CGRect, radius: CGFloat, popPoint: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        var rect = viewRect
        rect.size.height -= POPUP_ROOT_SIZE.height
        
        let minx = CGRectGetMinX( rect )
        let maxx = CGRectGetMaxX( rect )
        
        let miny = CGRectGetMinY( rect ) + POPUP_ROOT_SIZE.height
        let maxy = CGRectGetMaxY( rect )
        
//        let popRightEdgeX = popPoint.x + POPUP_ROOT_SIZE.width / 2
//        let popRightEdgeY = maxy
//        
//        let popLeftEdgeX = popPoint.x - POPUP_ROOT_SIZE.width / 2
//        let popLeftEdgeY = maxy
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, minx, miny + radius)
        
        CGContextAddArc(context, minx + radius, miny + radius, radius, CGFloat(M_PI), CGFloat(M_PI_2 * 3), 0)
        CGContextAddLineToPoint(context, maxx - radius - 10 - POPUP_ROOT_SIZE.width, miny)
        CGContextAddLineToPoint(context, maxx - radius - 10 - (POPUP_ROOT_SIZE.width / 2), miny - POPUP_ROOT_SIZE.height)
        CGContextAddLineToPoint(context, maxx - radius - 10 , miny)
        CGContextAddLineToPoint(context, maxx - radius, miny)
        
        
        CGContextAddArc(context, maxx - radius, miny + radius, radius, CGFloat(M_PI_2 * 3), CGFloat(M_PI * 2), 0)
        CGContextAddLineToPoint(context, maxx, maxy - radius)
        
        
        CGContextAddArc(context, maxx - radius, maxy - radius, radius, 0, CGFloat(M_PI_2), 0)
        CGContextAddLineToPoint(context, minx + radius, maxy )
        
        CGContextAddArc(context, minx + radius, maxy - radius, radius, CGFloat(M_PI_2), CGFloat(M_PI), 0)
        
        
//        CGContextAddArcToPoint(context, minx, miny, midx, miny, radius)
//        CGContextAddLineToPoint(context, popRightEdgeX, popRightEdgeY)
//        
//        CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius)
//        CGContextAddArcToPoint(context, maxx, maxy, popRightEdgeX, popRightEdgeY, radius)
//        
//        CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius)
//        CGContextAddLineToPoint(context, popPoint.x, popPoint.y)
//        
//        CGContextAddLineToPoint(context, popLeftEdgeX, popLeftEdgeY)
//        CGContextAddLineToPoint(context, minx, midy)
        CGContextClosePath(context)
        
    }
    
    
    func showAtPoint(point: CGPoint, inView:UIView, animated:Bool) {
        
        let pointToBeShown = point
        
    }
    
    func popup() {
        
        self.createAndAttachTouchPeekView()
        
        let positionAnimation = self.getPositionAnimationForPopup()
        let alphaAnimation = self.getAlphaAnimationForPopup()
        let group = CAAnimationGroup()
        group.animations = [positionAnimation, alphaAnimation]
        group.duration = 0.2
        group.removedOnCompletion = true
        group.fillMode = kCAFillModeForwards
        
        let frame = self.frame
        let maxx = CGRectGetMaxX( frame )
        let midy = CGRectGetMinY( frame )
        
        let anchorPoint = self.layer.anchorPoint
        self.layer.anchorPoint = CGPointMake(1.0, 0)
        
        self.layer.addAnimation(group, forKey: "hoge")
        self.peekView?.addSubview(self)
    }
    
    func getPositionAnimationForPopup() -> CAKeyframeAnimation {
        let r1:CGFloat = 0.9
        let r2:CGFloat = 0.6
        let r3:CGFloat = 0.1
        let r4:CGFloat = -0.2
        let r5:CGFloat = 0
    
        let positionAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        let tm1 = CATransform3DScale(CATransform3DIdentity, 1 - r1, 1 - r1, 0)
        let tm2 = CATransform3DScale(CATransform3DIdentity, 1 - r2, 1 - r2, 0)
        let tm3 = CATransform3DScale(CATransform3DIdentity, 1 - r3, 1 - r3, 0)
        let tm4 = CATransform3DScale(CATransform3DIdentity, 1 - r4, 1 - r4, 0)
        let tm5 = CATransform3DScale(CATransform3DIdentity, 1 - r5, 1 - r5, 0)
        
        
        positionAnimation.values = [NSValue(CATransform3D:tm1),
            NSValue(CATransform3D:tm2),
            NSValue(CATransform3D:tm3),
            NSValue(CATransform3D:tm4),
            NSValue(CATransform3D:tm5)]
        
        positionAnimation.keyTimes = [0.0, 0.2, 0.4, 0.7, 1.0]
        return positionAnimation
    }
    
    func getAlphaAnimationForPopup() -> CAKeyframeAnimation {
        let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        alphaAnimation.removedOnCompletion = false
        alphaAnimation.values = [0, 0.7, 1]
        alphaAnimation.keyTimes = [0, 0.1, 1]
        return alphaAnimation
    }
    
    
    
    func getPositionAnimationForHide() -> CAKeyframeAnimation {
        let r1:CGFloat = 0.1
        let r2:CGFloat = 0.4
        let r3:CGFloat = 0.6
        let r4:CGFloat = 0.9
        let r5:CGFloat = 1
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        let tm1 = CATransform3DScale(CATransform3DIdentity, 1 - r1, 1 - r1, 0)
        let tm2 = CATransform3DScale(CATransform3DIdentity, 1 - r2, 1 - r2, 0)
        let tm3 = CATransform3DScale(CATransform3DIdentity, 1 - r3, 1 - r3, 0)
        let tm4 = CATransform3DScale(CATransform3DIdentity, 1 - r4, 1 - r4, 0)
        let tm5 = CATransform3DScale(CATransform3DIdentity, 1 - r5, 1 - r5, 0)
        
        
        positionAnimation.values = [NSValue(CATransform3D:tm1),
            NSValue(CATransform3D:tm2),
            NSValue(CATransform3D:tm3),
            NSValue(CATransform3D:tm4),
            NSValue(CATransform3D:tm5)]
        
        positionAnimation.keyTimes = [0.0, 0.2, 0.4, 0.7, 1.0]
        return positionAnimation
    }
    
    func getAlphaAnimationForHide() -> CAKeyframeAnimation {
        let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        alphaAnimation.removedOnCompletion = false
        alphaAnimation.values = [1, 0.7, 0]
        alphaAnimation.keyTimes = [0, 0.1, 1]
        return alphaAnimation
    }
    
    func createAndAttachTouchPeekView() {
        if let peekView = self.peekView? {
            peekView.removeFromSuperview()
        }
        let window = UIApplication.sharedApplication().keyWindow
        self.peekView = TouchPeekView(frame: window.frame)
        self.peekView?.delegate = self
        window.addSubview(self.peekView!)
        
    }
    
    func hide() {
        
        let positionAnimation = self.getPositionAnimationForHide()
        let alphaAnimation = self.getAlphaAnimationForHide()
        let group = CAAnimationGroup()
        group.animations = [positionAnimation, alphaAnimation]
        group.duration = 0.2
        group.removedOnCompletion = true
        group.fillMode = kCAFillModeForwards
        
        let frame = self.frame
        let maxx = CGRectGetMaxX( frame )
        let midy = CGRectGetMinY( frame )
        
        let anchorPoint = self.layer.anchorPoint
        self.layer.anchorPoint = CGPointMake(1.0, 0)
        
        group.delegate = self
        self.layer.addAnimation(group, forKey: "hoge")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished : Bool) {
        if finished {
            self.peekView?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}