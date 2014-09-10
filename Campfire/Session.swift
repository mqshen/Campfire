//
//  Session.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

enum UserType: Int {
    case User, Room
}

class User {
    let name: String
    let nickName: String
    let avatar: String
    let userType: UserType
    
    init(name: String, nickName: String, avatar: String, userType: UserType = UserType.User) {
        self.name = name
        self.nickName = nickName
        self.avatar = avatar
        self.userType = userType
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
    
    
    func refrestUser() {
        let users = PersistenceProcessor.sharedInstance.getFriends()
        self.friends = users
    }
    
}