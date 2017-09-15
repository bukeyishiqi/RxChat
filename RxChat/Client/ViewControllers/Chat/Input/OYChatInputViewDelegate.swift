//
//  OYChatInputViewDelegate.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/9.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


enum KeyboardType: Int {
    //系统默认键盘 ;  //表情输入键盘 ;//提供照片、视频等功能的Panel;//按住说话;//当前没有显示键盘
    case `default` = 0, emotion, panel, record, none
}

struct KeyboardShowHideInfo {
    var keyboardHeight: CGFloat        //键盘高度
        //当前显示的键盘类型
    var toKeyboardType: KeyboardType    //需要显示/隐藏的键盘类型
    //    var animated: bool             //是否需要动画效果
    var curve: UIViewAnimationOptions
    var duration: CGFloat
}


protocol ChatInputDelegate: NSObjectProtocol {
    
    func updateKeyboard(keyboardShowHideInfo: KeyboardShowHideInfo)

    func sendTextMessage(text: String)
    
    func sendGifMessage(item: EmotionItem)
    
     func didSelectShareTag(tag: Int)
    
    func addEmtionPackage()
}



extension OYChatInputView: OYChatEmotionViewDelegate {
    
    func emojiCellDidSelected(emotionItem: EmotionItem) {
        
        guard let text = emotionItem.text else {
            return
        }
        
        let selectRange = chatInputTextView.selectedRange
        let emotionStr = NSMutableString.init(string: chatInputTextView.text)
        emotionStr.insert("[\(text)]", at: selectRange.location)
        chatInputTextView.text = emotionStr as String!
        
        chatInputTextView.selectedRange = NSRange.init(location: selectRange.location + emotionStr.length, length: selectRange.length)
    }
    
    func emojiGifCellDidSelected(emotionItem: EmotionItem) {
        self.delegate?.sendGifMessage(item: emotionItem)
    }
    
    func sendButtonDidSelected() {
        self.delegate?.sendTextMessage(text: self.chatInputTextView.text)
    }
    
    func deleteCellDidSelected() {
        
    }
    
    func emotionBagAddButtonDidSelected() {
        
    }
}

extension OYChatInputView: OYChatShareInputViewDelegate {
    
    func shareInputViewDidSelectTag(tag: Int) {
        self.delegate?.didSelectShareTag(tag: tag)
    }
}


class OYChatInputViewDelegateProxy: DelegateProxy, ChatInputDelegate, DelegateProxyType {
    
    lazy var didUpdateInfoSubject = PublishSubject<KeyboardShowHideInfo>()
    lazy var didSendTextMsgSubject = PublishSubject<String>()
    lazy var didSendGifMsgSubject = PublishSubject<String>()
    lazy var didSelectShareTagSubject = PublishSubject<Int>()
    
    
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let chatInput: OYChatInputView  = object as! OYChatInputView
        return chatInput.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let chatInput: OYChatInputView  = object as! OYChatInputView
        if let delegate = delegate {
            chatInput.delegate = (delegate as! ChatInputDelegate)
        } else {
            chatInput.delegate = nil
        }
    }
    
    
    func updateKeyboard(keyboardShowHideInfo: KeyboardShowHideInfo) {
        didUpdateInfoSubject.onNext(keyboardShowHideInfo)
        (_forwardToDelegate as? ChatInputDelegate)?.updateKeyboard(keyboardShowHideInfo: keyboardShowHideInfo)
    }

    func sendTextMessage(text: String) {
        didSendTextMsgSubject.onNext(text)
        (_forwardToDelegate as? ChatInputDelegate)?.sendTextMessage(text: text)
    }
    
    func sendGifMessage(item: EmotionItem) {
        didSendGifMsgSubject.onNext(item.imageGIF ?? "")
        (_forwardToDelegate as? ChatInputDelegate)?.sendGifMessage(item: item)
    }
    
    func didSelectShareTag(tag: Int) {
        didSelectShareTagSubject.onNext(tag)
    }
    
    func addEmtionPackage() {
        
    }
    
    deinit {
        self.didUpdateInfoSubject.on(.completed)
        self.didSendTextMsgSubject.on(.completed)
        self.didSendGifMsgSubject.on(.completed)
        self.didSelectShareTagSubject.on(.completed)
    }
}

























