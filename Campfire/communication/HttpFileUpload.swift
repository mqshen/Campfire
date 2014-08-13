//
//  HttpFileUpload.swift
//  Campfire
//
//  Created by GoldRatio on 8/12/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

//extension String {
    
func digest(original: String, algorithm: HMACAlgorithm, key: String) -> String! {
    let str = original.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = UInt(original.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = algorithm.digestLength()
    let result = UnsafeMutablePointer<CUnsignedChar>(digestLen)
    let keyStr = key.cStringUsingEncoding(NSUTF8StringEncoding)
    let keyLen = UInt(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    CCHmac(algorithm.toCCEnum(), keyStr!, keyLen, str!, strLen, result)
    
    var hash = NSMutableString()
    for i in 0..<digestLen {
        hash.appendFormat("%02x", result[i])
    }
    
    return String(format: hash)
}

//}

func uploadHttpFile(url: String,
    fileName: String,
    reqParams: Dictionary<String, String>?,
    data: NSData,
    successHandler : (Dictionary<String, AnyObject>) -> Void)
{
    let secretKey = "_vajoiKTqA1UWK8sss-jBgicJ6343pecYYbLZNrh"
    let putPolicy = "{\"scope\":\"mqshen:\(fileName)\",\"deadline\":1451491200,\"returnBody\":\"{\\\"name\\\":$(fname),\\\"size\\\":$(fsize),\\\"w\\\":$(imageInfo.width),\\\"h\\\":$(imageInfo.height),\\\"hash\\\":$(etag)}\"}"
    
    let utf8str = putPolicy.dataUsingEncoding(NSUTF8StringEncoding)
    let encodedPutPolicy = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
    
    var urlRequestString = SERVER_ADD.stringByAppendingString(url)
    
    var result = NSMutableData()
    
    var dataString = NSMutableString()
    if let params = reqParams? {
        for (key, value) in params {
            let keyAndValue = "\(key)=\(value)&"
            dataString.appendString(keyAndValue)
        
            result.appendData(key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
            result.appendData(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
            result.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        }
    }
    let reqURL = NSURL(string: urlRequestString)
    let request = NSMutableURLRequest(URL: reqURL,
        cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy,
        timeoutInterval: 60.0)
    
    request.HTTPMethod = "post"
    
    if let params = reqParams? {
        let requestBodyData = dataString.dataUsingEncoding(NSUTF8StringEncoding);
        request.HTTPBody = requestBodyData;
    }
    
    NSURLConnection.sendAsynchronousRequest(request,
        queue: NSOperationQueue.mainQueue(),
        completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error {
                print(error)
            }
            else {
                if let responseData = data? {
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
                            let response = responseDic["content"] as? Dictionary<String, AnyObject>
                            if let result = response? {
                                successHandler(result)
                            }
                        }
                        else {
                            let msg = responseDic["errMsg"] as String
                            let alertView = UIAlertView(title: "提示", message: msg, delegate: nil, cancelButtonTitle: "确定")
                            alertView.show()
                        }
                        
                    }
                }
            }
        })
}