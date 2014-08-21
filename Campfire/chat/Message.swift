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
    
    init(fromUserName: String, toUserName: String, type: Int, content: String, clientMsgId: Int64) {
        self.fromUserName = fromUserName
        self.toUserName = toUserName
        self.type = type
        self.content = content
        self.clientMsgId = clientMsgId
    }
    
    func toJson() -> String {
        return "{\"fromUserName\": \"\(fromUserName)\", \"toUserName\": \"\(toUserName)\",\"type\": \(type),\"content\": \"\(content)\",\"clientMsgId\": \(clientMsgId)}"
    }
}