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

class MainViewController: UIViewController, UITextFieldDelegate, TabSelectDelegate, SocketIODelegate{
    
    var containerView: UIView?
    var contentView: UIView?
    
    let persistence = PersistenceProcessor()
    //var socketIO: SocketIO?
    let chatViewController: ChatViewController = ChatViewController()
    let contactsViewController: ContactsViewController = ContactsViewController()
    var tabBar: TabView?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatViewController.mainViewController = self
        
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        self.navigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        let frame = self.view.frame
        let height: CGFloat = 50
        
        tabBar = TabView(frame: CGRectMake(0, frame.size.height - height, frame.size.width, height),
            nameAndImages:[("聊天" , "tabbar_mainframe@2x.png", "tabbar_mainframeHL@2x.png"),
                ("通讯录", "tabbar_contacts@2x.png", "tabbar_contactsHL@2x.png"),
                ("我", "tabbar_me@2x.png", "tabbar_meHL@2x.png")
            ])
        tabBar!.delegate = self
        
        tabBar!.backgroundColor = UIColorFromRGB(0x22282D)
        self.view.addSubview(tabBar!)
        
        let session = Session.sharedInstance
        
        session.socketIO = SocketIO(url: "socket.io/1/", endpoint: "testendpoint")
        session.socketIO!.delegate = self
        session.socketIO!.connect()
        
        self.title = "聊天"
        
        let navigateBarHeight = self.navigationController.navigationBar.frame.size.height + 20
        containerView = UIView(frame: CGRectMake(0, navigateBarHeight, frame.size.width, frame.size.height - height - navigateBarHeight))
        containerView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(containerView!)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startChat:", name: StartChatNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func startChat(note: NSNotification) {
        if let userInfo = note.userInfo? {
            if let user: AnyObject = userInfo["user"]? {
                self.tabBar?.setSelect(0)
                self.chatViewController.startChat(user as User)
            }
        }
    }
    
    func showChat() -> UIView {
        return chatViewController.view
    }
    
    func showContacts() -> UIView {
        return contactsViewController.view
    }
    
    func showMe() -> UIView {
        return UIView()
    }
    
    func didSelect(index: Int) {
        contentView?.removeFromSuperview()
        if index == 0 {
            contentView = self.showChat()
            self.title = "聊天"
        }
        else if index == 1 {
            contentView = self.showContacts()
            self.title = "通讯录"
        }
        else if index == 2 {
            contentView = self.showMe()
            self.title = "我"
        }
        let frame:CGRect = containerView!.frame
        contentView?.frame = CGRectMake(0, 0 , frame.width, frame.height)
        containerView?.addSubview(contentView!)
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
                            clientMsgId: Int64(clientMsgId!))
                        
                        chatViewController.receiveMessage(message)
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
                                        persistence.addFriend(User(name: userName!, nickName: nickName!, avatar: avatar!))
                                    }
                                }
                            }
                            if let syncKey = operation["syncKey"].integer? {
                                lastSyncKey = syncKey
                            }
                        }
                    }
                    let users = persistence.getFriends()
                    persistence.updateSyncKey(lastSyncKey)
                    
                    contactsViewController.receiveContacts(users)
                    
                }
//                else {
//                    var users = [User]()
//                    if let contacts = responseDic["content"].array? {
//                        for contact in contacts {
//                            let userName = contact["name"].string
//                            let nickName = contact["nickName"].string
//                            let avatar = contact["avatar"].string
//                            if (userName != nil && nickName != nil && avatar != nil) {
//                                users.append( User(name: userName!, nickName: nickName!, avatar: avatar!))
//                            }
//                        }
//                    }
//                    contactsViewController.receiveContacts(users)
//                }
            }
        }
    }
    
    func socketIODidConnect() {
        let session = Session.sharedInstance
        let syncKey = persistence.getSyncKey()
        session.socketIO!.sendEvent("{\"name\":\"sync\", \"args\":[\(syncKey)]}")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}