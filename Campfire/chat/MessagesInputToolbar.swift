//
//  MessagesInputToolbar.swift
//  Campfire
//
//  Created by GoldRatio on 8/20/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol MessageInputViewDelegate: UITextViewDelegate
{
    func didSelectedMultipleMediaAction(change: Bool)
    func didSelectedVoice(change: Bool)
}

class MessagesInputToolbar: UIView, AVAudioRecorderDelegate
{
    let contentView: MessagesComposerTextView
    let voiceInputButton: UIButton
    let voiceButton: UIButton
    var inputDelegate: MessageInputViewDelegate?
    var recorder: AVAudioRecorder?
    
    var textInput: Bool = true
    
    var delegate: MessageInputViewDelegate? {
        get {
            return self.inputDelegate
        }
        set {
            self.inputDelegate = newValue
            self.contentView.delegate = newValue
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        self.voiceInputButton = UIButton(frame: CGRectMake(233, 8, 25, 25))
        self.voiceButton = UIButton(frame: CGRectMake(9, 7, 214, 30))
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        self.voiceButton = UIButton(frame: CGRectMake(9, 7, 214, 30))
        self.voiceButton.setTitle("按住 说话", forState: UIControlState.Normal)
        self.voiceButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.voiceButton.layer.borderWidth = 0.5
        self.voiceInputButton = UIButton(frame: CGRectMake(233, 8, 25, 25))
        self.voiceInputButton.setImage(UIImage(named: "micro_small.png"), forState: UIControlState.Normal)
        
        super.init(frame: frame)
        self.voiceInputButton.addTarget(self, action: "voiceInput", forControlEvents: UIControlEvents.TouchUpInside)
        self.voiceButton.addTarget(self, action: "voiceInputStart", forControlEvents: UIControlEvents.TouchDown)
        self.voiceButton.addTarget(self, action: "voiceInputStop", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.backgroundColor = UIColorFromRGB(0xDCDCDC)
        
        self.addSubview(self.contentView)
        self.addSubview(self.voiceInputButton)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let left = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 9)
        self.addConstraint(left)
        
        let right = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: -97)
        self.addConstraint(right)
        
        
        let top = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 7)
        self.addConstraint(top)
        
        
        let bottom = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -7)
        self.addConstraint(bottom)
    }
    
    func voiceInput() {
        if (self.textInput) {
            self.contentView.resignFirstResponder()
            self.contentView.removeFromSuperview()
            self.addSubview(self.voiceButton)
            self.textInput = false
        }
        else {
            self.voiceButton.removeFromSuperview()
            self.addSubview(self.contentView)
            self.contentView.becomeFirstResponder()
            self.textInput = true
        }
        self.delegate?.didSelectedVoice(true)
    }
    
    func voiceInputStart() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryRecord, error: nil)
        audioSession.setActive(true, error: nil)
        
        let url = NSURL.fileURLWithPathComponents([NSTemporaryDirectory(),"record.caf"])
        self.recorder = AVAudioRecorder(URL:url, settings:[AVFormatIDKey:kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2], error:nil)
        self.recorder?.delegate = self
        self.recorder?.meteringEnabled = true
        self.recorder?.prepareToRecord()
        self.recorder?.record()
        
        NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "levelTimerCallback:", userInfo: nil, repeats: true)
    }
    
    func voiceInputStop() {
        self.recorder?.stop()
    }
    
    func levelTimerCallback(timer:NSTimer) {
        if let recorder = self.recorder? {
            if recorder.recording {
                recorder.updateMeters()
            }
            timer.invalidate()
        } else {
            timer.invalidate()
        }
    }
    
}