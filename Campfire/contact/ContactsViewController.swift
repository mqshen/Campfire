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
    
    var contacts = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func receiveContacts(contacts: NSArray) {
        self.contacts.addObjectsFromArray(contacts)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell?.textLabel.text = self.contacts[indexPath.row].objectForKey("nickName") as String
        return cell;
    }
}