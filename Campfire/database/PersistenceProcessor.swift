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
}