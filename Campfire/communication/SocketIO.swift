//
//  SocketIO.swift
//  Campfire
//
//  Created by GoldRatio on 8/13/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

protocol SocketIODelegate {
    func socketIODidConnect()
    func socketIODidReceiveMessage(message: String)
}

enum PacketType: Int {
    case Disconnect, Connect, Heartbeat, Message, Json, Event, Ack, Erro, Noop
}

class Packet {
    let type: PacketType
    let endpoint: String
    let data: String
    
    init(type: PacketType, endpoint: String = "", data: String = "") {
        self.type = type
        self.endpoint = endpoint
        self.data = data
    }
}

class SocketIO: WebsocketDelegate
{
    let url: String
    let endpoint: String
    var webSocket: Websocket?
    var closeTimeout: Int = 60
    var heartbeatTimeout: Int = 60
    var sessionId: String?
    var delegate: SocketIODelegate?
    var open: Bool = false
    var connected: Bool = false
    
    
    
    init(url: String, endpoint: String) {
        self.url = url
        self.endpoint = endpoint
    }
    
    func connect() {
        func handler(response: NSDictionary) {
            let sessionStr = response["response"] as String
            let sessionArray: Array<String> = sessionStr.componentsSeparatedByString(":")
            if sessionArray.count > 3 {
                let transports = sessionArray[3]
                if transports.rangeOfString("websocket") != nil {
                    self.sessionId = sessionArray[0]
                    self.closeTimeout = sessionArray[1].toInt()!
                    self.heartbeatTimeout = sessionArray[2].toInt()!
                    
                    self.open = true
                    let url = "\(WEBSOCKET_SERVER_ADD)\(self.url)websocket/\(self.sessionId!)"
                    webSocket = Websocket(url: NSURL.URLWithString(url))
                    webSocket!.delegate = self
                    webSocket!.connect()
                }
            }
        }
        
        
        sendAsyncHttpRequest(url,
            "get",
            ["t" : "1407894173651"],
            handler,
            responseType: ResponseType.TEXT
        )
    }
    
    
    func websocketDidConnect() {
        println("websocket is connected")
    }
    
    func websocketDidDisconnect(error: NSError?) {
        println("websocket is disconnected: ")
    }
    
    func websocketDidWriteError(error: NSError?) {
        println("we got an error from the websocket: \(error!.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(data: NSData) {
        let message = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(message)
        
        let array = self.getMatchesFrom(message, regex: "^([^:]+):([0-9]+)?(\\+)?:([^:]+)?:?(.*)?$")
        let type:Int? = array[1].toInt()
        if let packetType = PacketType.fromRaw(type!)? {
            let packet = Packet(type: packetType, endpoint: array[4], data: array[5])
            if(packet.type == PacketType.Heartbeat) {
                self.onHeartbeat()
            }
            else if(packet.type == PacketType.Connect && packet.endpoint == "") {
                self.onConnect()
            }
            else if(packet.type == PacketType.Erro && packet.data == "reconnect") {
                open = false
            }
            else {
                self.onPacket(packet)
            }
        }

    }
    
    func websocketDidReceiveData(data: NSData) {
        println("got some data: \(data.length)")
        //self.socket.writeData(data) //example on how to write binary data to the socket
    }
    
    
    func getMatchesFrom(data: NSString, regex: NSString) -> Array<String> {
        var error: NSError?
        let internalExpression = NSRegularExpression(pattern: regex, options: .CaseInsensitive, error: &error)
        let matches = internalExpression.matchesInString(data, options: nil, range:NSMakeRange(0, data.length))
        var arr = Array<String>()
        for match in matches {
            let size = match.numberOfRanges!
            for i in (0..<size) {
                let range = match.rangeAtIndex(i)
                if (range.location != NSNotFound && NSMaxRange(range) <= data.length) {
                   arr.append(data.substringWithRange(range))
                }
                else {
                    arr.append("")
                }
            }
        }
        return arr
    }
    
    func onHeartbeat() {
        self.sendPacket(Packet(type: PacketType.Heartbeat))
    }
    
    func onConnect() {
        self.sendPacket(Packet(type: PacketType.Connect, endpoint: self.endpoint))
    }
    
    func onPacket(packet: Packet) {
        if packet.type == PacketType.Connect {
            connected = true
            delegate?.socketIODidConnect()
        }
        else {
            delegate?.socketIODidReceiveMessage(packet.data)
        }
    }
    
    func sendPacket(packet: Packet) {
        var message: String
        if packet.endpoint == "" {
            message = "\(packet.type.toRaw())::"
        }
        else if packet.data == "" {
            message = "\(packet.type.toRaw())::/\(packet.endpoint)"
        }
        else {
            message = "\(packet.type.toRaw())::/\(packet.endpoint):\(packet.data)"
        }
        webSocket?.writeString(message)
    }
    
    func sendEvent(message: String) {
        self.sendPacket(Packet(type: PacketType.Event, endpoint: self.endpoint, data: message))
    }
}