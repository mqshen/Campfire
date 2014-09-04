//
//  PersistenceProcessor.swift
//  Campfire
//
//  Created by GoldRatio on 9/3/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class PersistenceProcessor
{
    
    class var sharedInstance: PersistenceProcessor {
        struct Singleton {
            static let instance = PersistenceProcessor()
        }
        return Singleton.instance
    }
    
    let database: SQLiteDB
    init() {
        database = SQLiteDB(name: "campfire") { (db: COpaquePointer) -> Void in
            let sql_stmt = "CREATE TABLE IF NOT EXISTS FRIEND (UserName TEXT PRIMARY KEY, NickName TEXT, Avatar TEXT)"
            if sqlite3_exec(db, sql_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table success")
            }
            let session_stmt = "CREATE TABLE IF NOT EXISTS Session (Type TEXT PRIMARY KEY, Value TEXT)"
            if sqlite3_exec(db, session_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table success")
            }
            let insert_sql = "INSERT INTO Session(Type, Value) VALUES ('syncKey',  '0')"
            if sqlite3_exec(db, insert_sql, nil, nil, nil) != SQLITE_OK {
                println("insert ")
            }
        }
    }
    
    func addFriend(friend: User) {
        database.execute("INSERT INTO FRIEND(UserName, NickName, Avatar) VALUES ('\(friend.name)',  '\(friend.nickName)', '\(friend.avatar)')")
    }
    
    func deleteFriend(friend: User) {
        
    }
    
    func getFriends() -> Array<User> {
        let data = database.query("SELECT UserName, NickName, Avatar FROM FRIEND")
        
        var users = [User]()
        for row in data {
            let userName = row["UserName"]?.asString()
            let nickName = row["NickName"]?.asString()
            let avatar = row["Avatar"]?.asString()
            users.append( User(name: userName!, nickName: nickName!, avatar: avatar!))
        }
        return users
    }
    
    func getSyncKey() -> String {
        let data = database.query("SELECT Value FROM Session WHERE Type = 'syncKey'")
        if let row = data.first? {
            if let syncKey = row["Value"]?.asString() {
                return syncKey
            }
        }
        return "0"
    }
    
    func updateSyncKey(syncKey: Int) {
        database.execute("UPDATE Session SET Value = '\(syncKey)' WHERE Type = 'syncKey'")
    }
    
    func createChatTable(userName: String) {
        database.execute("CREATE TABLE IF NOT EXISTS Chat_\(userName) (Id INTEGER PRIMARY KEY AUTOINCREMENT, ServerId INTEGER, CreateTime INTEGER, Message TEXT, Status INTEGER)")
    }
    
    func addMessage(message: Message) {
        database.execute("INSERT INTO Chat_\(message.fromUserName) (ServerId, CreateTime, Message, Status) VALUES ('\(message.clientMsgId)', '\(message.createTime)', '\(message.content)', '4')")
    }
    
    func sendMessage(message: Message) {
        database.execute("INSERT INTO Chat_\(message.toUserName) (ServerId, CreateTime, Message, Status) VALUES ('\(message.clientMsgId)', '\(message.createTime)', '\(message.content)', '2')")
    }
    
    func getRecentChats() -> Array<(String, Message)> {
        let data = database.query("SELECT name FROM sqlite_master WHERE type='table' and name like 'Chat_%'")
        
        var chats = Array<(String, Message)>()
        for row in data {
            if let name = row["name"]?.asString() {
                let userName = name.subStringFrom(5)
                let data = database.query("SELECT ServerId, CreateTime, Message, Status FROM \(name) ORDER BY Id DESC LIMIT 1")
                if let row = data.first? {
                    let serverId = row["ServerId"]?.asInt()
                    let createTime = row["CreateTime"]?.asInt()
                    let content = row["Message"]?.asString()
                    let status = row["Status"]?.asInt()
                    let message = Message(fromUserName: userName, toUserName: "", type: 0, content: content!, clientMsgId: Int64(serverId!), createTime: createTime!)
                    chats.append((userName, message))
                }
            }
        }
        return chats
    }
    
    func getRecentMessages(userName: String, page: Int, size: Int = 20) -> Array<Message> {
        let skip = page * size
        let data = database.query("SELECT ServerId, CreateTime, Message, Status FROM Chat_\(userName) ORDER BY Id DESC LIMIT \(skip), \(size)")
        var messages = [Message]()
        for row in data {
            let serverId = row["ServerId"]?.asInt()
            let createTime = row["CreateTime"]?.asInt()
            let content = row["Message"]?.asString()
            let status = row["Status"]?.asInt()
            var fromUserName = userName
            var toUsername = Session.sharedInstance.userName!
            if status == 2 {
                fromUserName = toUsername
                toUsername = userName
            }
            let message = Message(fromUserName: fromUserName, toUserName: toUsername, type: 0, content: content!, clientMsgId: Int64(serverId!), createTime: createTime!)
            messages.append(message)
        }
        return messages.reverse()
    }
}