//
//  ChatViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/12/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit


class ChatViewController: UITableViewController
{
    
    var searchBar: UISearchBar?
    
    var mainViewController: MainViewController?
    
    var chats = [(String, Message)]()
    var currentUserName: String? = nil
    var messageViewController: MessageViewController?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "聊天",
            image:  UIImage(named: "tabbar_mainframe@2x.png"),
            selectedImage: UIImage(named: "tabbar_mainframeHL@2x.png"))
    }
    
    override init(style: UITableViewStyle = UITableViewStyle.Plain) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(title: "聊天",
            image:  UIImage(named: "tabbar_mainframe@2x.png"),
            selectedImage: UIImage(named: "tabbar_mainframeHL@2x.png"))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar = UISearchBar()
        self.searchBar?.sizeToFit()
        self.tableView.tableHeaderView = self.searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController.navigationBar.translucent = false
    }
    
    func refresh() {
        chats = PersistenceProcessor.sharedInstance.getRecentChats()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: ChatViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ChatViewCell
        if (cell == nil) {
            cell = ChatViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        let userName = self.chats[indexPath.row].0
        if let user = Session.sharedInstance.getUser(userName)? {
            if user.userType == UserType.User {
                cell?.setAvatar(user.avatar)
            }
            else {
                cell?.swImageView.image = UIImage(named: "room@2x.png")
            }
            cell?.textLabel.text = user.nickName
            
            let message = self.chats[indexPath.row].1
            cell?.recentLabel.text = message.content
            let createTime = NSDate(timeIntervalSince1970: Double(message.createTime))
            cell?.timeLabel.text = createTime.timeAgo()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 55
    }
    
    func receiveMessage(message: Message) {
        if let userName = self.currentUserName? {
            if userName == message.fromUserName {
                self.messageViewController?.receiveMessage(message)
            }
        }
    }
    
    func startChat(userName: String) {
        for chat in chats {
            if userName == chat.0 {
                self.pushViewController(userName)
                return
            }
        }
        chats.append((userName, Message()))
        self.tableView.reloadData()
        self.pushViewController(userName)
    }
    
//    func addChat(user: User, message: Message) {
//        chats.append(user)
//    }
    
    func pushViewController(userName: String) {
        if let user = Session.sharedInstance.getUser(userName)? {
            let messageViewController = MessageViewController()
            messageViewController.toUser = user
            self.currentUserName = userName
            self.mainViewController?.navigationController?.pushViewController(messageViewController, animated: true)
            self.messageViewController = messageViewController
        }
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let userName = self.chats[indexPath.row].0
        self.pushViewController(userName)
    }
    
}