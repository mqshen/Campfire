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

class MainViewController: UITabBarController, UITextFieldDelegate, SocketIODelegate{
    
    //var socketIO: SocketIO?
    let chatViewController: ChatViewController = ChatViewController()
    let contactsViewController: ContactsViewController = ContactsViewController()
    
    var lastViewController: UIViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [UINavigationController(rootViewController: chatViewController),
            UINavigationController(rootViewController: contactsViewController)]
        
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        let frame = self.view.frame
        
        self.view.backgroundColor = UIColor.whiteColor()

        self.tabBar.barTintColor = UIColorFromRGB(0x22282D)
        self.selectedIndex = 0
     
        let session = Session.sharedInstance
        
        session.socketIO = SocketIO(url: "socket.io/1/", endpoint: "testendpoint")
        session.socketIO!.delegate = self
        session.socketIO!.connect()
        
        self.title = "聊天"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startChat:", name: StartChatNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startChat(note: NSNotification) {
        if let userInfo = note.userInfo? {
            if let object: AnyObject = userInfo["user"]? {
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
                    let users = PersistenceProcessor.sharedInstance.getFriends()
                    PersistenceProcessor.sharedInstance.updateSyncKey(lastSyncKey)
                    
                    Session.sharedInstance.friends = users
                    self.chatViewController.refresh()
                    
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
}