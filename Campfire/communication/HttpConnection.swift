//
//  HttpConnection.swift
//  Campfire
//
//  Created by GoldRatio on 8/8/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

enum ResponseType {
    case JSON, XML, TEXT
}
func sendAsyncHttpRequest(url: String,
    httpMethod: String,
    reqParams: Dictionary<String, String>?,
    successHandler : (NSDictionary) -> Void,
    failedHandler : ((NSDictionary) -> Void)? = nil,
    operationQueue: NSOperationQueue = NSOperationQueue.mainQueue(),
    responseType: ResponseType = ResponseType.JSON
    )
{
    
    var urlRequestString = url
    let range = url.rangeOfString("https://")
    
    if (range == nil ) {
        urlRequestString = SERVER_ADD.stringByAppendingString(url)
    }
    
    let dataString = NSMutableString(string: "")
    
    if let params = reqParams? {
        for (key, value) in params {
            let keyAndValue = "\(key)=\(value)&"
            dataString.appendString(keyAndValue)
        }
    }
    
    if(httpMethod == "get" ) {
        urlRequestString = urlRequestString.stringByAppendingString("?").stringByAppendingString(dataString)
    }
    
    let reqURL = NSURL(string: urlRequestString)
    
    let request = NSMutableURLRequest(URL: reqURL,
        cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy,
        timeoutInterval: 60.0)
    
    
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    request.HTTPMethod = httpMethod
    
    if (httpMethod == "post") {
        if let params = reqParams? {
            let requestBodyData = dataString.dataUsingEncoding(NSUTF8StringEncoding);
            request.HTTPBody = requestBodyData;
        }
    }
    
    
    NSURLConnection.sendAsynchronousRequest(request,
        queue: operationQueue,
        completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error {
                print(error)
            }
            else {
                if let responseData = data? {
                    if responseType == ResponseType.JSON {
                        var e: NSError?
                        var responseDic = NSJSONSerialization.JSONObjectWithData( responseData,
                            options: NSJSONReadingOptions(0),
                            error: &e) as NSDictionary
                        if e != nil {
                            print(e)
                        }
                        else {
                            let returnCode = responseDic["ret"] as Int
                            if(returnCode == 0) {
//                                if let httpResponse = response as? NSHTTPURLResponse {
//                                    for (name, value) in httpResponse.allHeaderFields {
//                                        println("\(name) : \(value) ")
//                                        if name == "Set-Cookie" {
//                                            let sessionStr = value as String
//                                            let index: String.Index = advance(sessionStr.startIndex, 8)
//                                            let sessionId = sessionStr.substringFromIndex(index)
//                                            
//                                            Session.sharedInstance.cookie = sessionStr
//                                            Session.sharedInstance.sessionId = sessionId
//                                        }
//                                    }
//                                }
                                let response = responseDic["content"] as? Dictionary<String, AnyObject>
                                if let result = response? {
                                    successHandler(result)
                                }
                            }
                            else {
                                if let handler = failedHandler? {
                                    handler(responseDic)
                                }
                                else {
                                    let msg = responseDic["errMsg"] as String
                                    let alertView = UIAlertView(title: "提示", message: msg, delegate: nil, cancelButtonTitle: "确定")
                                    alertView.show()
                                }
                            }
                            
                        }
                    }
                    else {
                        let responseStr = NSString(data:responseData, encoding: NSUTF8StringEncoding)
                        successHandler(["response" : responseStr])
                    }
                }
                //println(NSString(data: responseData, encoding: NSUTF8StringEncoding))
            }
        })
    
}