//
//  Session.swift
//  Campfire
//
//  Created by GoldRatio on 8/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation


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
    
}