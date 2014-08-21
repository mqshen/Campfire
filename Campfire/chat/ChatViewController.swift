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
    
    var mainViewController: UIViewController?
    
    var chats = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let frame = self.view.frame
        let searchView = UIView(frame: CGRectMake(0, 0, frame.size.width, 30))
        self.tableView.tableHeaderView = searchView
        
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: ContactViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ContactViewCell
        if (cell == nil) {
            cell = ContactViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell?.textLabel.text = self.chats[indexPath.row]
        return cell;
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 55
    }
    
    func receiveMessage(message: NSDictionary) {
        
    }
    
    func startChat(userName: String) {
        chats.append(userName)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let messageViewController = MessageViewController()
        if let mainViewController = self.mainViewController? {
            messageViewController.toUserName = chats[indexPath.row]
            mainViewController.navigationController.pushViewController(messageViewController, animated: true)
        }
    }
    
}