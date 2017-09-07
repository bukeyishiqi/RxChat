//
//  OYChatInputView+RxSwift.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/22.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


extension Reactive where Base: OYChatInputView {

//    var sendButtonTap: ControlEvent<String> {
//        
//        let source = base.shareEmotionView?.sendButton.rx.tap.withLatestFrom(base.chatInputTextView.rx.text).flatMapLatest { text -> Observable<String> in
//            
//            if let text = text, !text.isEmpty {
//                return .just(text)
//            } else {
//                return .empty()
//            }
//        }
//        .do(onNext: { [weak base = self.base] _ in
//            base?.chatInputTextView.text = nil
//        })
//     
//        return ControlEvent(events: source!)
//    }

    
    var delegate: DelegateProxy {
        return OYChatInputViewDelegateProxy.proxyForObject(base)
    }

    var didUpdateKeyboardShowHideInfo: Observable<KeyboardShowHideInfo> {
        return (delegate as! OYChatInputViewDelegateProxy).didUpdateInfoSubject.asObservable()
    }
    
    var didSendTextMsg: Observable<String> {
        return (delegate as! OYChatInputViewDelegateProxy).didSendTextMsgSubject
            .asObservable()
            .do(onNext: { [weak base = self.base] _ in
                base?.chatInputTextView.text = nil
            })
            .flatMapLatest { text -> Observable<String> in
                if !text.isEmpty {
                    return .just(text)
                } else {
                    return .empty()
                }
        }
    }
    
    var didSendGifMsg: Observable<String> {
        return (delegate as! OYChatInputViewDelegateProxy).didSendGifMsgSubject
                .asObservable()
                .filter {
                    $0.characters.count > 0
            }
    }
    
    var ShareTagTap: Observable<Int> {
        return (delegate as! OYChatInputViewDelegateProxy).didSelectShareTagSubject
            .asObservable()
    }
    
    var addPackageButtonTap: ControlEvent<Void> {
        let source = base.shareEmotionView?.plusButton.rx.tap
        return ControlEvent(events: source!)
    }

    
    
    
    
    
    
    
    
    
    
    
    
}
