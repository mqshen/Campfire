//
//  Session.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class User {
    let name: String
    let nickName: String
    let avatar: String
    
    init(name: String, nickName: String, avatar: String) {
        self.name = name
        self.nickName = nickName
        self.avatar = avatar
    }
}

class Session {
    class var sharedInstance: Session {
        struct Singleton {
            static let instance = Session()
        }
        return Singleton.instance
    }
    
    var userName: String?
    var nickName: String?
    var sessionId: String?
    var socketIO: SocketIO?
    
    var friends = Array<User>()
    
    func getUser(userName: String) -> User? {
        for user in friends {
            if user.name == userName {
                return user
            }
        }
        return nil
    }
    
}