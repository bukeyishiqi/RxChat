//
//  ChatBaseCellViewModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/28.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ChatBaseCellViewModel {
    
    var cellHeight: CGFloat = 0
    
    // MARK: output
    var headUrl: Observable<String>
    var isFromMe: Observable<Bool>
    
    fileprivate var item: ChatItem
    
    internal required init(_ messageItem: ChatItem) {
        item = messageItem
        isFromMe = Observable.just(messageItem.msgDesType).map {
            switch $0 {
            case .send: return true
            default: return false
            }
        }
        headUrl = Observable.just("icon_avatar")
    }
    
    class func createCellViewModel<T:ChatBaseCellViewModel>(messageItem: ChatItem) -> T {
        switch messageItem.msgBodyType {
        case .text(text: _):
            return ChatTextViewModel.init(messageItem) as! T
        default:
            return ChatTextViewModel.init(messageItem) as! T
        }
    }
}

// MARK: TextViewModel
final class ChatTextViewModel: ChatBaseCellViewModel {

    var rxTextMsg: Driver<String>
    
    required init(_ messageItem: ChatItem) {
      
        rxTextMsg = Observable.just(messageItem.msgBodyType.storeValue).filter {
            $0.characters.count > 0
        }.asDriver(onErrorJustReturn: "")
        super.init(messageItem)
    }
}

// MARK: extension CustomStringConvertible
extension ChatBaseCellViewModel: CustomStringConvertible {

    var description: String {
        switch item.msgBodyType {
        case .text(text: _):
            return NSStringFromClass(ChatTextCell.self)
        case .image(item: _):
            return "ChatImageCell"
        case .video(item: _):
            return "ChatVideoCell"
        case .voice(item: _):
            return "ChatVoiceCell"
        case .file(item: _):
            return "ChatFileCell"
        case .time(time: _):
            return "ChatTimeCell"
        default:
            return ""
        }
    }


}
