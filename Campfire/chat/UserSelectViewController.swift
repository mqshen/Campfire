//
//  UserSelectViewController.swift
//  Campfire
//
//  Created by GoldRatio on 9/7/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage



class ContactSelectViewCell: UITableViewCell
{
    let swImageView: SWWebImageView
    let checkbox: Checkbox
    
    required init(coder aDecoder: NSCoder) {
        swImageView = SWWebImageView(frame: CGRectMake(50, 10, 35, 35))
        checkbox = Checkbox(frame: CGRectMake(10, 10, 35, 35))
        super.init(coder: aDecoder)
        self.addSubview(swImageView)
        self.addSubview(checkbox)
        checkbox.backgroundColor = UIColor.clearColor()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        swImageView = SWWebImageView(frame: CGRectMake(50, 10, 35, 35))
        checkbox = Checkbox(frame: CGRectMake(10, 10, 35, 35))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(swImageView)
        self.addSubview(checkbox)
        checkbox.backgroundColor = UIColor.clearColor()
        checkbox.tintColor = UIColorFromRGB(0x2FB143)
        checkbox.userInteractionEnabled = false
        //checkbox.addTarget(self, action: "doSelect", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func setAvatar(url: String) {
        self.swImageView.setImage(NSURL(string: url), placeholderImage: UIImage(named: "placeholder@2x.png"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        let checkboxSize = frame.size.height - 30
        checkbox.frame = CGRectMake(10, 15, checkboxSize, checkboxSize)
        checkbox.layer.cornerRadius = checkboxSize / 2
        checkbox.layer.borderColor = UIColor.lightGrayColor().CGColor
        checkbox.layer.borderWidth = 1
        checkbox.layer.masksToBounds = true
        
        
        self.swImageView.frame = CGRectMake(20 + checkboxSize, 10, 35, 35)
        self.textLabel?.frame = CGRectMake(63 + checkboxSize, 0, 200, frame.size.height)
    }
}

class UserSelectViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate
{
    
    var users = [String]()
    var friends = [User]()
    
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
        
        self.title = "发起群聊"
        
        self.friends = Session.sharedInstance.friends.filter({ $0.userType != UserType.Room })
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
//        self.automaticallyAdjustsScrollViewInsets = false
        
        
//        if let layoutGuide = self.topLayoutGuide {
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let menuButton = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "doAddChatRoom")
        menuButton.enabled = false
        //[self.view addSubview:menuButton];
        self.navigationItem.rightBarButtonItem = menuButton;
        
        
        let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "doCancel")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doAddChatRoom() {
        let session = Session.sharedInstance
        if let roomUser = NSJSONSerialization.dataWithJSONObject(self.users, options: NSJSONWritingOptions.allZeros, error: nil)? {
            let jsonString = NSString(data:roomUser, encoding: NSUTF8StringEncoding)
            let messages = "{\"name\":\"create\", \"args\":\(jsonString)}"
            println(messages)
            session.socketIO!.sendEvent(messages)
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func receiveContacts(contacts: Array<User>) {
        self.tableView.reloadData()
    }
    
    func doCancel() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ContactSelectViewCell? = tableView.dequeueReusableCellWithIdentifier( "userCell" ) as? ContactSelectViewCell
        if (cell == nil) {
            cell = ContactSelectViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "userCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None;
        }
        let avatarUrl = self.friends[indexPath.row].avatar
        cell?.setAvatar(avatarUrl)
        
        cell?.textLabel?.text = self.friends[indexPath.row].nickName
        return cell!;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: ContactSelectViewCell? = tableView.cellForRowAtIndexPath(indexPath) as? ContactSelectViewCell
        cell!.checkbox.checked = !cell!.checkbox.checked
        let user = Session.sharedInstance.friends[indexPath.row]
        if cell!.checkbox.checked {
            self.users.append(user.name)
        }
        else {
            self.users = self.users.filter({$0 != user.name })
        }
        if self.users.count == 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
}