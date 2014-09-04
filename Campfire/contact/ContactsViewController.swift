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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let frame = self.view.frame
        let searchView = UIView(frame: CGRectMake(0, 0, frame.size.width, 30))
        self.tableView.tableHeaderView = searchView
    }
    
    func receiveContacts(contacts: Array<User>) {
//        for user in contacts {
//            Session.sharedInstance.friends.append(user)
//        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return Session.sharedInstance.friends.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: ContactViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ContactViewCell
        if (cell == nil) {
            cell = ContactViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        let avatarUrl = Session.sharedInstance.friends[indexPath.row].avatar
        cell?.setAvatar(avatarUrl)
        
        cell?.textLabel.text = Session.sharedInstance.friends[indexPath.row].nickName
        return cell;
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var user = Session.sharedInstance.friends[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(StartChatNotification, object: nil, userInfo: ["user":user])
    }
}