//
//  MessageViewController.swift
//  Campfire
//
//  Created by GoldRatio on 8/20/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

let IncomingMessage = "IncomingMessage"
let OutgoingMessage = "OutgoingMessage"
let TOOLBAR_HEIGHT: CGFloat = 44
let kMessagesKeyValueObservingContext = UnsafeMutablePointer<Void>.alloc(1)

class MessageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MessagesKeyboardControllerDelegate, MessageInputViewDelegate
{
    var collectionView: MessgeCollectionView?
    var inputToolbar: MessagesInputToolbar?
    var toolbarBottomLayoutGuide: NSLayoutConstraint?
    var toolbarHeightConstraint: NSLayoutConstraint?
    var keyboardController: MessageKeyboardController?
    var messages = [Message]()
    
    var toUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let frame = self.view.bounds
        
        self.collectionView = MessgeCollectionView(frame: frame, collectionViewLayout: layout)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = UIColor.redColor()
        self.view.addSubview(self.collectionView!)
        
        let left = NSLayoutConstraint(item: self.collectionView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(left)
        
        let right = NSLayoutConstraint(item: self.collectionView,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(right)
        
        
        let top = NSLayoutConstraint(item: self.collectionView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(top)
        
        
        let bottom = NSLayoutConstraint(item: self.collectionView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(bottom)
        
        
        self.collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.collectionView?.registerClass(IncomingMessageCell.self, forCellWithReuseIdentifier: IncomingMessage)
        self.collectionView?.registerClass(OutgoingMessageCell.self, forCellWithReuseIdentifier: OutgoingMessage)
        
        
        let height = frame.size.height - TOOLBAR_HEIGHT
        self.inputToolbar = MessagesInputToolbar(frame: CGRectMake(0, height, frame.size.width, TOOLBAR_HEIGHT))
        self.inputToolbar?.delegate = self
        self.view.addSubview(self.inputToolbar!)
        
        
        self.toolbarBottomLayoutGuide = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.inputToolbar,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        self.view.addConstraint(self.toolbarBottomLayoutGuide!)
        
        
        let panGestureRecognizer = self.collectionView!.panGestureRecognizer
        let contentView = self.inputToolbar!.contentView
        self.keyboardController = MessageKeyboardController(textView: contentView,
            contextView: self.view,
            panGestureRecognizer: panGestureRecognizer,
            delegate: self)
        
        
        let toolbarLeft = NSLayoutConstraint(item: self.inputToolbar,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(toolbarLeft)
        
        
        let toolbarRight = NSLayoutConstraint(item: self.inputToolbar,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(toolbarRight)
        
        self.toolbarHeightConstraint = NSLayoutConstraint(item: self.inputToolbar,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: TOOLBAR_HEIGHT)
        
        self.inputToolbar?.addConstraint(self.toolbarHeightConstraint!)
    }
    
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        var height:CGFloat = 20
        let message = self.messages[indexPath.row]
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
        let maximumSize = CGSizeMake(220, CGFloat.max)
        
        // Need to cast stringValue to an NSString in order to call boundingRectWithSize(_:options:attributes:).
        let boundingSize = message.content.boundingRectWithSize(maximumSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil)
        
        height += boundingSize.size.height
        
        return CGSizeMake(320, height)
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let message = self.messages[indexPath.row]
        let myName = Session.sharedInstance.userName
        let cellIdentify = myName! == message.fromUserName ? OutgoingMessage : IncomingMessage
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentify, forIndexPath: indexPath) as MessageCell
        cell.message = self.messages[indexPath.row]
        return cell
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardController?.beginListeningForKeyboard()
        self.addContentSizeObserver()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeContentSizeObserver()
        self.keyboardController?.endListeningForKeyboard()
        
    }
    
    
    //layout
    
    func addContentSizeObserver() {
        //self.removeContentSizeObserver()
        self.inputToolbar?.contentView.addObserver(self,
            forKeyPath: "contentSize",
            options: NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New,
            context: kMessagesKeyValueObservingContext)
    }
    
    func removeContentSizeObserver() {
        self.inputToolbar?.contentView.removeObserver(self, forKeyPath: "contentSize", context: kMessagesKeyValueObservingContext)
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if context == kMessagesKeyValueObservingContext {
            if object as? MessagesComposerTextView == self.inputToolbar?.contentView && keyPath == "contentSize" {
                let oldContentSize = change[NSKeyValueChangeOldKey]?.CGSizeValue()
                let newContentSize = change[NSKeyValueChangeNewKey]?.CGSizeValue()
                let dy = newContentSize!.height - oldContentSize!.height
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
                self.updateCollectionViewInsets()
                self.scrollToBottomAnimated(false)
            }
        }
    }
    
    func updateCollectionViewInsets() {
        let collectionViewFrame = self.collectionView!.frame
        let frame = self.inputToolbar!.frame
        let height = CGRectGetMinY(frame)
        self.setCollectionViewInsets(self.topLayoutGuide.length, bottom: CGRectGetHeight(collectionViewFrame) - height)
        
    }
    
    func scrollToBottomAnimated(animated: Bool) {
        if self.collectionView!.numberOfSections() == 0 {
            return
        }
        let size = self.collectionView!.numberOfItemsInSection(0)
        if size > 0 {
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: size - 1, inSection: 0),
                atScrollPosition: UICollectionViewScrollPosition.Top,
                animated: animated)
        }
    }
    
    func setCollectionViewInsets(top: CGFloat, bottom: CGFloat) {
        let insets = UIEdgeInsetsMake(top, 0.0, bottom, 0.0)
        self.collectionView!.contentInset = insets
        self.collectionView!.scrollIndicatorInsets = insets
    }
    
    func adjustInputToolbarForComposerTextViewContentSizeChange(dy: CGFloat) {
        var contentSizeIsIncreasing = dy > 0
        if self.inputToolbarHasReachedMaximumHeight() {
            let contentOffsetIsPositive = self.inputToolbar!.contentView.contentOffset.y > 0
            if contentSizeIsIncreasing || contentOffsetIsPositive {
                self.scrollComposerTextViewToBottomAnimated(true)
                return
            }
        }
        let toolbarOriginY = CGRectGetMinY(self.inputToolbar!.frame);
        let newToolbarOriginY = toolbarOriginY - dy;
        
        var interval = dy
        //  attempted to increase origin.Y above topLayoutGuide
        if (newToolbarOriginY <= self.topLayoutGuide.length) {
            interval = toolbarOriginY - self.topLayoutGuide.length;
            self.scrollComposerTextViewToBottomAnimated(true)
        }
        
        self.adjustInputToolbarHeightConstraintByDelta(interval)
        
        self.updateKeyboardTriggerPoint()
        
        if (interval < 0) {
            self.scrollComposerTextViewToBottomAnimated(false)
        }
    
    }
    
    func updateKeyboardTriggerPoint() {
        
    }
    
    func inputToolbarHasReachedMaximumHeight() -> Bool {
        return CGRectGetMinY(self.inputToolbar!.frame) == self.topLayoutGuide.length
    }
    
    func adjustInputToolbarHeightConstraintByDelta(dy: CGFloat) {
        self.toolbarHeightConstraint!.constant += dy
        if (self.toolbarHeightConstraint!.constant < TOOLBAR_HEIGHT) {
            self.toolbarHeightConstraint!.constant = TOOLBAR_HEIGHT
        }
    
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func scrollComposerTextViewToBottomAnimated(animated: Bool) {
        let textView = self.inputToolbar!.contentView
        let contentOffsetToShowLastLine = CGPointMake(0.0, textView.contentSize.height - CGRectGetHeight(textView.bounds))
        if (!animated) {
            textView.contentOffset = contentOffsetToShowLastLine
            return
        }
        
        UIView.animateWithDuration(0.01,
            delay: 0.01,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                textView.contentOffset = contentOffsetToShowLastLine
            },
            completion: nil)
    }
    
    //keyboard
    func keyboardDidChangeFrame(keyboardFrame: CGRect){
        let collectFrame = self.collectionView!.frame
        let heightFromBottom = CGRectGetHeight(collectFrame) - CGRectGetMinY(keyboardFrame)
        
        self.setToolbarBottomLayoutGuideConstant(heightFromBottom)
    }
    
    func setToolbarBottomLayoutGuideConstant(constant: CGFloat) {
        self.toolbarBottomLayoutGuide!.constant = constant
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
        self.updateCollectionViewInsets()
    }
    
    
    //message
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        if text == "\n" {
            let content:String = textView.text
            if countElements(content) == 0 {
                return false
            }
            let session = Session.sharedInstance
            let message = Message(fromUserName: session.userName!,
                toUserName: self.toUser!.name,
                type: 1,
                content: content,
                clientMsgId: 1)
            
            self.messages.append(message)
            session.socketIO?.sendEvent("{\"name\": \"chat\", \"args\":[\(message.toJson())]}")
            
            textView.text = ""
            self.finishSendingOrReceivingMessage()
            return false
        }
        return true
    }
    
    func didSelectedMultipleMediaAction(change: Bool) {
        
    }
    
    func textViewDidBeginEditing(textView: UITextView!) {
        textView.becomeFirstResponder()
        //_processInputBar = NO;
        self.scrollToBottomAnimated(true)
    }
    
    func finishSendingOrReceivingMessage() {
        self.collectionView?.reloadData()
        self.scrollToBottomAnimated(true)
    }
    
}