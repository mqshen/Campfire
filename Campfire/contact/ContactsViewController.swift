//
//  ContactViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/12/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ContactsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate
{
    var searchBar: UISearchBar?
    
    
    override init(style: UITableViewStyle = UITableViewStyle.Plain) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(title: "通讯录",
            image:  UIImage(named: "tabbar_contacts@2x.png"),
            selectedImage: UIImage(named: "tabbar_contactsHL@2x.png"))
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "通讯录",
            image:  UIImage(named: "tabbar_contacts@2x.png"),
            selectedImage: UIImage(named: "tabbar_contactsHL@2x.png"))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        
        self.navigationController?.navigationBar.translucent = false
//        if let layoutGuide = self.topLayoutGuide? {
//            let currentInsets = self.tableView.contentInset
//            let insets = UIEdgeInsetsMake(
//                64,
//                currentInsets.bottom,
//                currentInsets.left,
//                currentInsets.right
//            )
//            self.tableView.contentInset = insets
//            self.tableView.scrollIndicatorInsets = insets
//        }
//
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar = UISearchBar()
        self.searchBar?.sizeToFit()
        self.tableView.tableHeaderView = self.searchBar
//        let searchView = UIView(frame: CGRectMake(0, 0, frame.size.width, 30))
//        self.tableView.tableHeaderView = searchView
    }
    
    func receiveContacts(contacts: Array<User>) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Session.sharedInstance.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ContactViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ContactViewCell
        if (cell == nil) {
            cell = ContactViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        let user = Session.sharedInstance.friends[indexPath.row]
        if user.userType == UserType.User {
            cell?.setAvatar(user.avatar)
        }
        else {
            cell?.swImageView.image = UIImage(named: "room@2x.png")
        }
        
        cell?.textLabel?.text = user.nickName
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var user = Session.sharedInstance.friends[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(StartChatNotification, object: nil, userInfo: ["user":user])
    }
}