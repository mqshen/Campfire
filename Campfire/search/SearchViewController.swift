//
//  SearchViewController.swift
//  Campfire
//
//  Created by GoldRatio on 9/5/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController
{
    var searchContainer: UIView?
    var delegate: UINavigationController?
    
    override func viewDidLoad() {
        
        let frame = self.view.frame
        let searchView = UIView(frame: CGRectMake(0, 0, frame.size.width, 30))
        
        self.searchContainer = UIView(frame: CGRectMake(0, 0, frame.size.width, 40))
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, 40, frame.size.width, 0.5)
        bottomBorder.backgroundColor = LINE_COLOR.CGColor
        self.searchContainer?.layer.addSublayer(bottomBorder)
        
        let search = UIView(frame: CGRectMake(6, 6, frame.size.width - 12, 27))
        search.layer.cornerRadius = 4
        search.layer.borderColor = LINE_COLOR.CGColor
        search.layer.borderWidth = 0.5
        
        self.searchContainer?.addSubview(search)
        
        self.view.addSubview(self.searchContainer!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animateWithDuration(1.0,
//            delay: 0.0,
//            options: UIViewAnimationOptions.CurveLinear,
//            animations: { () -> Void in
//                self.searchContainer?.frame = CGRectMake(0, 0, 320, 30)
//            },
//            completion: nil)
        if let navigationController = self.delegate? {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                var frame = self.searchContainer!.frame
                frame.origin.y = 0
                self.searchContainer?.frame = frame
            },
            completion: nil)
    }
}