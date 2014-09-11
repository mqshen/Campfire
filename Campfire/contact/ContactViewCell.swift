//
//  ContactViewCell.swift
//  Campfire
//
//  Created by GoldRatio on 8/20/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ContactViewCell: UITableViewCell
{
    let swImageView: SWWebImageView
    
    required init(coder aDecoder: NSCoder) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        super.init(coder: aDecoder)
        self.addSubview(swImageView)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(swImageView)
    }
    
    func setAvatar(url: String) {
       self.swImageView.setImage(NSURL(string: url), placeholderImage: UIImage(named: "placeholder@2x.png"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        self.textLabel?.frame = CGRectMake(53, 0, 200, frame.size.height)
        self.swImageView.frame = CGRectMake(10, 10, 35, 35)
    }
}