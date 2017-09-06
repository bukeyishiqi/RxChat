//
//  ChatViewModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/8/24.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


let testList = [
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息sfsfsfsdfsdfdsfsdfsdfwerfgdfgdfgsdsdfsfsfsdsdfsfsfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsfsfsdfsdfds")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息sfsfsfsdfsdfdsfsdfsdfwerfgdfgdfgsdsdfsfsfsdsdfsfsfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsfsfsdfsdfds")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .receive, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息")),
    ChatItem.init(msgId: "1", userId: "100", userName: "chenqi", msgdesType: .send, msgStatus: .success, msgtime: "2017-8-29", bodyType: .text(text: "聊天消息"))
]

class ChatViewModel: ViewModelType {
    
    struct Input {
//        var refreshCommand: ControlEvent<Void>
//        var startMessageId = Variable<String>("") // 查询id不存在则从表最底部往上查询limit条记录
        var sendTextMsg: Observable<String>

        init(sendText: Observable<String>) {
//            refreshCommand = refresh
            sendTextMsg = sendText
        }
    }
    
    
    // MARK: output
    struct Output {
        /** 界面消息列表数据*/
        var list: Driver<[ChatBaseCellViewModel]>
        /** 界面滚动位置*/
//        var scrollOfIndex = Driver<IndexPath>(0)
        
        /** 刷新*/
//        let refreshTrigger: Driver<Bool>
        /** 消息发送*/
        let sendMsgTrigger: Driver<Int>
        
    }
    
    func transform(_ input: Input) -> Output {
        
//        let refreshTrigger = input.refreshCommand
//            .flatMap({input.startMessageId.asObservable()})
//            .flatMapLatest({_ -> Observable<Bool> in 
//                /** 获取下拉刷新数据加载到output.section中*/
//                let viewModels = testList.map({ (item) -> ChatBaseCellViewModel in
//                    return ChatBaseCellViewModel.createCellViewModel(messageItem: item)
//                })
//                self._chatList.value += viewModels
//                return Observable.of(true)
//            })
        
        let sendMsgTrigger = input.sendTextMsg.flatMap({
            ChatService.shared.sendText(text: $0)
        })
        .flatMap({ (element) -> Observable<Int> in
          let value = ChatBaseCellViewModel.createCellViewModel(messageItem: element)
            self._chatList.value.append(value)
            return Observable.create { observer in
                observer.on(.next(self._chatList.value.count))
                observer.on(.completed)
                return Disposables.create()
            }
        })
        .asDriver(onErrorJustReturn: (0))
        
        return Output(list: _chatList.asDriver(), sendMsgTrigger: sendMsgTrigger)
    }
    
    
    let provider: ServiceProviderType
    fileprivate let _chatList: Variable<[ChatBaseCellViewModel]>
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        _chatList = Variable(testList.map({ (item) -> ChatBaseCellViewModel in
            return ChatBaseCellViewModel.createCellViewModel(messageItem: item)
        }))
    }
}
