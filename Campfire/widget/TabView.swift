//
//  Tab.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
protocol TabSelectDelegate {
    
     func didSelect(index: Int)
    
}

class TabView: UIView {
    
    var selectedIndex: Int = 0
    var delegate: TabSelectDelegate?
    let buttons: Array<ImageButton> = []
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, nameAndImages: Array<(String, String, String)>) {
        let count = nameAndImages.count
        let width = frame.size.width / CGFloat(count)
        
        super.init(frame: frame)
        
        for (index, (name, image, activeImage)) in enumerate(nameAndImages) {
            let left = width * CGFloat(index)
            let image = UIImage(named: image)
            let activeImage = UIImage(named: activeImage)
            let imageButton = ImageButton(frame: CGRectMake(left, 0, 100, 50),
                image: image, text: name, textColor: UIColorFromRGB(0x898989))
            imageButton.activeColor = UIColor.whiteColor()
            imageButton.activeImage = activeImage
            imageButton.tag = index
            imageButton.addTarget(self, action: "doSelect:", forControlEvents: UIControlEvents.ValueChanged)
            self.addSubview(imageButton)
            buttons.append( imageButton)
            if index == 0 {
                imageButton.select = true
            }
        }
        
    }
    
    func doSelect(button: ImageButton) {
        let index = button.tag
        if index != selectedIndex {
            let lastSelectedButton = buttons[selectedIndex]
            lastSelectedButton.select = false
            if let delegate = delegate? {
                selectedIndex = index
                delegate.didSelect(selectedIndex)
            }
        }
    }
    
    
    
}