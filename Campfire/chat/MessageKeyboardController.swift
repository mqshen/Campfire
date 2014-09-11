//
//  MessageKeyboardViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/21/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

typealias MessageAnimationCompletionHandler = (finished: Bool) -> Void

let kMessagesKeyboardControllerKeyValueObservingContext = UnsafeMutablePointer<Void>.alloc(1)

let MessagesKeyboardControllerNotificationKeyboardDidChangeFrame = "MessagesKeyboardControllerNotificationKeyboardDidChangeFrame"
let MessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = "MessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame"

protocol MessagesKeyboardControllerDelegate
{
    func keyboardDidChangeFrame(keyboardFrame: CGRect)
}

class MessageKeyboardController: NSObject
{
    let delegate: MessagesKeyboardControllerDelegate
    let textView: UITextView
    let contextView: UIView
    let panGestureRecognizer: UIPanGestureRecognizer
    
    var keyboardTriggerPoint: CGPoint
    var keyboardView: UIView?
    
    
    
    init(textView: UITextView, contextView: UIView, panGestureRecognizer: UIPanGestureRecognizer, delegate: MessagesKeyboardControllerDelegate) {
        self.textView = textView
        self.contextView = contextView
        self.panGestureRecognizer = panGestureRecognizer
        self.delegate = delegate
        self.keyboardTriggerPoint = CGPointZero
        
        super.init()
    }
    
    deinit {
        self.removeKeyboardFrameObserver()
        self.unregisterForNotifications()
    }
    
    
    func removeKeyboardFrameObserver() {
        self.keyboardView?.removeObserver(self,
            forKeyPath: "frame",
            context: kMessagesKeyboardControllerKeyValueObservingContext)
    }
    
    func registerForNotifications() {
        self.unregisterForNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveKeyboardDidShowNotification:",
            name: UIKeyboardDidShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveKeyboardWillChangeFrameNotification:",
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveKeyboardDidChangeFrameNotification:",
            name: UIKeyboardDidChangeFrameNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveKeyboardDidHideNotification:",
            name: UIKeyboardDidHideNotification,
            object: nil)
    }
    
    func unregisterForNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func didReceiveKeyboardDidShowNotification(notification: NSNotification) {
        self.keyboardView = self.textView.inputAccessoryView?.superview
        self.setKeyboardViewHidden(false)
        
        self.handleKeyboardNotification(notification, completion: { (finished: Bool) -> Void in
            self.panGestureRecognizer.addTarget(self, action: "handlePanGestureRecognizer:")
        })
    }
    
    func didReceiveKeyboardWillChangeFrameNotification(notification: NSNotification) {
        self.handleKeyboardNotification(notification, completion: nil)
    }
    
    func didReceiveKeyboardDidChangeFrameNotification(notification: NSNotification) {
        self.setKeyboardViewHidden(false)
        self.handleKeyboardNotification(notification, completion: nil)
    }
    
    func didReceiveKeyboardDidHideNotification(notification: NSNotification) {
        self.keyboardView = nil
        self.handleKeyboardNotification(notification, completion: { (finished: Bool) -> Void in
            self.panGestureRecognizer.removeTarget(self, action: nil)
        })
    }
    
    func setKeyboardViewHidden(hidden: Bool) {
        self.keyboardView?.hidden = hidden
        self.keyboardView?.userInteractionEnabled = !hidden
    }
    
    func handleKeyboardNotification(notification: NSNotification, completion: MessageAnimationCompletionHandler?) {
        if let userInfo = notification.userInfo? {
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            if (CGRectIsNull(keyboardEndFrame)) {
                return
            }
            
            let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue
            let temp = animationCurve << 16
            let animationCurveOption = UIViewAnimationOptions.fromRaw(UInt(temp))
            
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
           
            let keyboardEndFrameConverted = self.contextView.convertRect(keyboardEndFrame, fromView: nil)
            
            UIView.animateWithDuration(animationDuration,
                delay: 0.0,
                options: animationCurveOption!,
                animations: { () -> Void in
                    self.delegate.keyboardDidChangeFrame(keyboardEndFrameConverted)
                    self.postKeyboardFrameNotificationForFrame(keyboardEndFrameConverted)
                },
                completion: nil)
        }
    }
    
    func postKeyboardFrameNotificationForFrame(frame: CGRect) {
        NSValue(CGRect: frame)
        NSNotificationCenter.defaultCenter().postNotificationName(MessagesKeyboardControllerNotificationKeyboardDidChangeFrame,
            object: self,
            userInfo: [MessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame: NSValue(CGRect: frame)])
    }
    
    func beginListeningForKeyboard() {
        self.textView.inputAccessoryView = UIView()
        self.registerForNotifications()
    }
    
    func endListeningForKeyboard() {
        self.textView.inputAccessoryView = nil
        self.unregisterForNotifications()
        self.setKeyboardViewHidden(false)
        self.keyboardView = nil
    }
}