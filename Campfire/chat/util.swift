//
//  util.swift
//  Campfire
//
//  Created by GoldRatio on 8/21/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit


extension UIImage
{
    func imageMasked(maskColor: UIColor) -> UIImage {
        let imageRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
    
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
    
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -(imageRect.size.height))
    
        CGContextClipToMask(context, imageRect, self.CGImage)
        CGContextSetFillColorWithColor(context, maskColor.CGColor)
        CGContextFillRect(context, imageRect)
    
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return newImage
    }
}

extension UIView
{
    func pinSubview(view: UIView, attribute: NSLayoutAttribute) {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }

    func pinAllEdgesOf(view: UIView) {
        self.pinSubview(view, attribute: NSLayoutAttribute.Bottom)
        self.pinSubview(view, attribute: NSLayoutAttribute.Top)
        self.pinSubview(view, attribute: NSLayoutAttribute.Leading)
        self.pinSubview(view, attribute: NSLayoutAttribute.Trailing)
    }
}