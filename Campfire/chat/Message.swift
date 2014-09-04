//
//  Message.swift
//  Campfire
//
//  Created by GoldRatio on 8/21/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class Message
{
    let fromUserName: String
    let toUserName: String
    let type: Int
    let content: String
    let clientMsgId: Int64
    let createTime: Int
    
    init() {
        self.fromUserName = ""
        self.toUserName = ""
        self.type = 0
        self.content = ""
        self.clientMsgId = 0
        self.createTime = 0
    }
    
    init(fromUserName: String, toUserName: String, type: Int, content: String, clientMsgId: Int64, createTime: Int) {
        self.fromUserName = fromUserName
        self.toUserName = toUserName
        self.type = type
        self.content = content
        self.clientMsgId = clientMsgId
        self.createTime = createTime
    }
    
    func toJson() -> String {
        return "{\"fromUserName\": \"\(fromUserName)\", \"toUserName\": \"\(toUserName)\",\"type\": \(type),\"content\": \"\(content)\",\"clientMsgId\": \(clientMsgId)}"
    }
}