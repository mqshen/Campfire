//
//  ChatViewCell.swift
//  Campfire
//
//  Created by GoldRatio on 9/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

class ChatViewCell: UITableViewCell
{
    let swImageView: SWWebImageView
    let recentLabel: UILabel
    let timeLabel: UILabel
    
    required init(coder aDecoder: NSCoder) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        recentLabel = UILabel(frame: CGRectMake(60, 32, 200, 15))
        timeLabel = UILabel(frame: CGRectMake(250, 3, 200, 14))
        super.init(coder: aDecoder)
        self.addSubview(swImageView)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        
        recentLabel = UILabel(frame: CGRectMake(60, 32, 200, 15))
        recentLabel.textColor = UIColorFromRGB(0x979797)
        
        recentLabel.font = UIFont.systemFontOfSize(14)
        
        timeLabel = UILabel(frame: CGRectMake(230, 3, 70, 14))
        timeLabel.textColor = UIColorFromRGB(0x979797)
        timeLabel.font = UIFont.systemFontOfSize(12)
        timeLabel.textAlignment = NSTextAlignment.Right
        
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = UIColor.blackColor()
        self.textLabel?.font = UIFont.systemFontOfSize(15)
        self.addSubview(swImageView)
        self.addSubview(recentLabel)
        self.addSubview(timeLabel)
    }
    
    func setAvatar(url: String) {
        self.swImageView.setImage(NSURL(string: url), placeholderImage: UIImage(named: "placeholder@2x.png"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        self.textLabel?.frame = CGRectMake(60, 3, 200, 18)
        self.swImageView.frame = CGRectMake(10, 5, 45, 45)
    }
}