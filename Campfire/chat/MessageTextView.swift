//
//  MessageTextView.swift
//  Campfire
//
//  Created by GoldRatio on 9/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class MessageTextView: UIView
{
    var _text: String = ""
    var text: String {
        get {
            return _text
        }
        set {
            _text = newValue
            self.setNeedsDisplay()
            
        }
    }
    var textColor: UIColor = UIColor.blackColor()
    var font: UIFont = UIFont.systemFontOfSize(14)
    
    override func drawRect(rect: CGRect) {
        let attributedString = NSAttributedString(string: self.text,
            attributes: [NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor])
        
        attributedString.drawInRect(rect)
    }
}