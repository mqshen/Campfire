//
//  MessageCell.swift
//  Campfire
//
//  Created by GoldRatio on 8/21/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

func horizontallyFlippedImage(image: UIImage) -> UIImage {
    return UIImage(CGImage: image.CGImage, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
}

func bubbleImageView(color: UIColor, flipped: Bool) -> UIImageView {
    let bubble = UIImage(named: "bubble_min")
    var normalBubble = bubble.imageMasked(color)
    
    if flipped {
        normalBubble = horizontallyFlippedImage(normalBubble)
    }

    let center = CGPointMake(bubble.size.width / 2.0, bubble.size.height / 2.0)
    let capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x)
    
    normalBubble = normalBubble.resizableImageWithCapInsets(capInsets, resizingMode: UIImageResizingMode.Stretch)
    let imageView = UIImageView(image: normalBubble)
    return imageView
}

class MessageCell: UICollectionViewCell
{
    var timeLabel: UILabel?
    var _message: Message?
    var _showTime: Bool = false
    
    var avatarView: SWWebImageView?
    var messageBubbleContainerView: UIView?
    var messageBubbleImageView: UIImageView?
    var textView: MessageTextView?
    
    func setTime(show: Bool) {
        if _showTime == show {
            timeLabel?.text = _message?.fromUserName
            return
        }
        if show {
            if timeLabel == nil {
                timeLabel = UILabel(frame: CGRectMake(0, 0, 320, 20))
                timeLabel!.textAlignment = NSTextAlignment.Center
                timeLabel!.backgroundColor = UIColor.clearColor()
                timeLabel!.font = UIFont.systemFontOfSize(10)
                timeLabel!.textColor = UIColor.blueColor()
            }
            timeLabel?.text = _message?.fromUserName
            self.addSubview(timeLabel!)
        }
        else {
            if let timeLabel = self.timeLabel? {
                timeLabel.removeFromSuperview()
            }
        }
        _showTime = show
    }
    
    func calculateMessageFrame(boundingFrame: CGRect) -> CGRect {
        var frame = self.messageBubbleContainerView!.frame
        frame.size.width = boundingFrame.size.width + 25
        frame.size.height = boundingFrame.size.height + 16
        return frame
    }
    
    var message: Message? {
        get {
            return _message
        }
        set {
            _message = newValue
            avatarView?.setImage(NSURL(string: ""), placeholderImage: UIImage(named: "placeholder@2x.png"))
            let content = _message!.content
            textView?.text = content
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
            let maximumSize = CGSizeMake(220, CGFloat.max)
            
            // Need to cast stringValue to an NSString in order to call boundingRectWithSize(_:options:attributes:).
            let boundingFrame = content.boundingRectWithSize(maximumSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attributes,
                context: nil)
            
            self.messageBubbleContainerView?.frame = calculateMessageFrame(boundingFrame)
        }
    }
}

class IncomingMessageCell: MessageCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        avatarView = SWWebImageView(frame: CGRectMake(10, 0, 30, 30))
        messageBubbleImageView = bubbleImageView(UIColor.whiteColor(), false)
        
        messageBubbleContainerView = UIView(frame: CGRectMake(43, 0, 200, 30))
        textView = MessageTextView(frame: CGRectMake(10, 5, 200, 20))
        textView?.backgroundColor = UIColor.clearColor()
        textView?.font = UIFont.systemFontOfSize(14)
        messageBubbleContainerView?.addSubview(textView!)
        
        messageBubbleImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        textView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.insertSubview(self.messageBubbleImageView!, belowSubview: self.textView!)
        self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: -13))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
    }
    
    
}


class OutgoingMessageCell: MessageCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        avatarView = SWWebImageView(frame: CGRectMake(280, 0, 30, 30))
        messageBubbleImageView = bubbleImageView(UIColorFromRGB(0x97E34A), true)
        
        messageBubbleContainerView = UIView(frame: CGRectMake(77, 0, 200, 30))
        textView = MessageTextView(frame: CGRectMake(10, 5, 200, 20))
        textView?.backgroundColor = UIColor.clearColor()
        textView?.font = UIFont.systemFontOfSize(14)
        textView?.textColor = UIColor.whiteColor()
        messageBubbleContainerView?.addSubview(textView!)
        
        messageBubbleImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        textView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.insertSubview(self.messageBubbleImageView!, belowSubview: self.textView!)
        self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 10))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
    }
    
    override func calculateMessageFrame(boundingFrame: CGRect) -> CGRect {
        var frame = self.messageBubbleContainerView!.frame
        let width = boundingFrame.size.width + 25
        frame.origin.x = 320 - 43 - width;
        frame.size.width = width
        frame.size.height = boundingFrame.size.height + 16
        return frame
    }
}