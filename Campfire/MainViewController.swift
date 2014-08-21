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
            if let userName: AnyObject = userInfo["userName"]? {
                self.tabBar?.setSelect(0)
                self.chatViewController.startChat(userName as String)
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
            var e: NSError?
            var responseDic = NSJSONSerialization.JSONObjectWithData( data,
                options: NSJSONReadingOptions(0),
                error: &e) as NSDictionary
            if e != nil {
                print(e)
            }
            else {
                let name = responseDic["name"] as String
                if name == "chat" {
                    chatViewController.receiveMessage(responseDic["content"] as NSDictionary)
                }
                else {
                    contactsViewController.receiveContacts(responseDic["content"] as NSArray)
                }
            }
        }
    }
    
    func socketIODidConnect() {
        let session = Session.sharedInstance
        session.socketIO!.sendEvent("{\"name\":\"contacts\"}")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}