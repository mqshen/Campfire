//
//  util.swift
//  Campfire
//
//  Created by GoldRatio on 8/8/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let RADIUS: CGFloat = 4

let LINE_COLOR = UIColor.lightGrayColor()

let SERVER_ADD = "http://localhost:8080/"
let WEBSOCKET_SERVER_ADD = "ws://localhost:8080/"


let MAIN_BOTTON_FONT = UIFont.systemFontOfSize(9)


extension String {
	func positionOf(sub:String)->Int {
		var pos = -1
		if let range = self.rangeOfString(sub) {
			if !range.isEmpty {
				pos = distance(self.startIndex, range.startIndex)
			}
		}
		return pos
	}
	
	func subStringFrom(pos:Int)->String {
		var substr = ""
		let start = advance(self.startIndex, pos)
		let end = self.endIndex
//		println("String: \(self), start:\(start), end: \(end)")
		let range = start..<end
		substr = self[range]
//		println("Substring: \(substr)")
		return substr
	}
	
	func subStringTo(pos:Int)->String {
		var substr = ""
		let end = advance(self.startIndex, pos-1)
		let range = self.startIndex...end
		substr = self[range]
		return substr
	}
}