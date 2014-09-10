//
//  MainViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//


import Foundation
import UIKit

let StartChatNotification = "StartChatNotification"

class MainViewController: UITabBarController, UITextFieldDelegate, SocketIODelegate, UITabBarControllerDelegate {
    
    //var socketIO: SocketIO?
    let chatViewController: ChatViewController = ChatViewController()
    let contactsViewController: ContactsViewController = ContactsViewController()
    
    var lastViewController: UIViewController?
    var searchController: UISearchDisplayController?
    var contactSearchController: UISearchDisplayController?
    
    var toolView: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        chatViewController.mainViewController = self
        
        self.viewControllers = [chatViewController, contactsViewController]
        
        let frame = self.view.frame
        
        self.view.backgroundColor = UIColor.whiteColor()

        self.tabBar.barTintColor = UIColorFromRGB(0x22282D)
        self.selectedIndex = 0
     
        let session = Session.sharedInstance
        
        session.socketIO = SocketIO(url: "socket.io/1/", endpoint: "testendpoint")
        session.socketIO!.delegate = self
        session.socketIO!.connect()
        
        self.hidesBottomBarWhenPushed = true
        self.title = "聊天"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startChat:", name: StartChatNotification, object: nil)
        self.searchController = UISearchDisplayController(searchBar: self.chatViewController.searchBar, contentsController: self)
        
        
        self.navigationController?.navigationBar?.translucent = false
        
        let chatButton = UIBarButtonItem(image: UIImage(named: "add@2x.png"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "showAddChat")
        
        self.navigationItem.rightBarButtonItem = chatButton
        
        self.tabBar.translucent = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startChat(note: NSNotification) {
        if let userInfo = note.userInfo? {
            if let object: AnyObject = userInfo["user"]? {
                self.selectedIndex = 0
                let user = object as User
                self.chatViewController.startChat(user.name)
                PersistenceProcessor.sharedInstance.createChatTable(user.name)
            }
        }
    }
    
    func socketIODidReceiveMessage(message: String) {
        println(message)
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding)? {
            let responseDic = JSONValue(data: data )
            if let name = responseDic["name"].string? {
                if name == "chat" {
                    let obj = responseDic["content"]
                    let fromUserName = obj["fromUserName"].string
                    let toUserName = obj["toUserName"].string
                    let type = obj["type"].integer
                    let content = obj["content"].string
                    let clientMsgId = obj["clientMsgId"].integer
                    if fromUserName != nil && toUserName != nil && type != nil && content != nil && clientMsgId != nil {
                        let message = Message(fromUserName: fromUserName!,
                            toUserName: toUserName!,
                            type: type!,
                            content: content!,
                            clientMsgId: Int64(clientMsgId!),
                            createTime: 1405163553)
                        
                        chatViewController.receiveMessage(message)
                        PersistenceProcessor.sharedInstance.addMessage(message)
                    }
                }
                else if name == "sync" {
                    var lastSyncKey = 0
                    if let operations = responseDic["content"].array? {
                        for operation in operations {
                            let syncType = operation["syncType"].string
                            if syncType == "user" {
                                let operationType = operation["operation"].string
                                if operationType == "add" {
                                    let content = operation["content"]
                                    let userName = content["userName"].string
                                    let nickName = content["nickName"].string
                                    let avatar = content["avatar"].string
                                    if (userName != nil && nickName != nil && avatar != nil) {
                                        PersistenceProcessor.sharedInstance.addFriend(User(name: userName!, nickName: nickName!, avatar: avatar!))
                                    }
                                }
                            }
                            if let syncKey = operation["syncKey"].integer? {
                                lastSyncKey = syncKey
                            }
                        }
                    }
                    PersistenceProcessor.sharedInstance.updateSyncKey(lastSyncKey)
                    
                    Session.sharedInstance.refrestUser()
                    
                    self.chatViewController.refresh()
                    
                }
                else if name == "room" {
                    let content = responseDic["content"]
                    let roomName = content["name"].string
                    if roomName == nil {
                        return
                    }
                    var usersString = NSMutableString()
                    if let users = content["users"].array? {
                        for userName in users {
                            usersString.appendString(userName.string!)
                            usersString.appendString("、")
                        }
                        usersString.deleteCharactersInRange(NSRange(location:usersString.length - 1 ,length: 1))
                    }
                    let user = User(name: roomName!, nickName: usersString, avatar: "", userType: UserType.Room)
                    PersistenceProcessor.sharedInstance.addFriend(user)
                    PersistenceProcessor.sharedInstance.createChatTable(roomName!)
                    Session.sharedInstance.friends.append(user)
                    
                    self.chatViewController.startChat(roomName!)
                }

            }
        }
    }
    
    func socketIODidConnect() {
        let session = Session.sharedInstance
        let syncKey = PersistenceProcessor.sharedInstance.getSyncKey()
        session.socketIO!.sendEvent("{\"name\":\"sync\", \"args\":[\(syncKey)]}")
    }
    
    
    func doSearch() {
        let searchViewController = SearchViewController()
        searchViewController.delegate = self.navigationController
        self.view.addSubview(searchViewController.view)
    }
    
    func showAddChat() {
        let imageButton = ImageButton(frame: CGRectMake(15, 10, 120, 40),
            image: UIImage(named: "tabbar_mainframe@2x.png"), text: "发起群聊", textColor:  UIColor.whiteColor(), vertical: false)
        imageButton.textLabel.font = UIFont.systemFontOfSize(14)
        imageButton.addTarget(self, action: "doAddGroupChat", forControlEvents:UIControlEvents.ValueChanged)
        self.toolView = PopupView(frame: CGRectMake(230, 20, 150, 100))
        self.toolView?.addSubview(imageButton)
        self.toolView?.popup()
    }
    
    func doAddGroupChat() {
        self.toolView?.hide()
        
        let vc = UserSelectViewController()
        let navVC = UINavigationController(rootViewController: vc)
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    func tabBarController(tabBarController: UITabBarController!, didSelectViewController viewController: UIViewController!) {
        if viewController == self.contactsViewController {
            if self.contactSearchController == nil {
                self.contactSearchController = UISearchDisplayController(searchBar: self.contactsViewController.searchBar, contentsController: self)
            }
        }
    }
    
}