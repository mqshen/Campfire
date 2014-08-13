//
//  ViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/8/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UITextFieldDelegate {
    
    let userNameField = UITextField(frame: CGRectMake(10, 5, 264, 40))
    let passwordField = UITextField(frame: CGRectMake(10, 55, 264, 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(0x1A8FF2)
        
        userNameField.delegate = self
        passwordField.delegate = self
        
        let loginContainer = UIView(frame: CGRectMake(18, 126, 284, 100))
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, 50, 284, 0.5)
        bottomBorder.backgroundColor = LINE_COLOR.CGColor
        loginContainer.layer.addSublayer(bottomBorder)
        
        loginContainer.layer.cornerRadius = RADIUS
        //loginContainer.layer.masksToBounds = true
        loginContainer.backgroundColor = UIColor.whiteColor()
        
        loginContainer.addSubview(userNameField)
        loginContainer.addSubview(passwordField)
        
        userNameField.placeholder = "用户名"
        passwordField.placeholder = "密码"
        
        let loginButton = UIButton(frame: CGRectMake(20, 245, 280, 45))
        loginButton.backgroundColor = UIColorFromRGB(0x1DA3FF)
        loginButton.layer.cornerRadius = RADIUS
        loginButton.addTarget(self, action: "doLogin:", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.setTitle("登录", forState: UIControlState.Normal)
        self.view.addSubview(loginButton)
        
        self.view.addSubview(loginContainer)
        // Do any additional setup after loading the view, typically from a nib.
        userNameField.text = "mqshen"
        passwordField.text = "111111"
    }

    func doLogin(sender:UIButton!){
        
        func handler(response: NSDictionary) {
            let session = Session.sharedInstance
            session.userName = response["name"]! as? String
            session.nickName = response["nickName"]! as? String
            
            let mainController = MainViewController()
            let mainNavigateController = UINavigationController(rootViewController: mainController)
            self.presentViewController(mainNavigateController, animated: true, completion: nil)
        }
        
        func failedHandler(response: NSDictionary) {
            
        }
        
        let userName = userNameField.text
        let password = passwordField.text
        sendAsyncHttpRequest("session",
            "post",
            ["login" : userName , "password" : password ],
            handler
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

