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
        var refreshCommand: ControlEvent<Void>
        var startMessageId = Variable<String>("") // 查询id不存在则从表最底部往上查询limit条记录
//        var sendTextMsg: Driver<String>
//        var sendGifMsg: Driver<EmotionItem>
        init(refresh: ControlEvent<Void>) {
            refreshCommand = refresh
        }
    }
    
    
    // MARK: output
    struct Output {
        var list: Driver<[ChatBaseCellViewModel]>
        let refreshTrigger: Driver<Bool>
        let sendMsgSubject = PublishSubject<ChatItem>()
    }
    
    func transform(_ input: Input) -> Output {
//        let output = Output.init(chatSection: _chatList.asDriver())
        
        let refreshTrigger = input.refreshCommand
            .flatMap({input.startMessageId.asObservable()})
            .flatMapLatest({_ -> Observable<Bool> in 
                /** 获取下拉刷新数据加载到output.section中*/
                let viewModels = testList.map({ (item) -> ChatBaseCellViewModel in
                    return ChatBaseCellViewModel.createCellViewModel(messageItem: item)
                })
                self._chatList.value += viewModels
                return Observable.of(true)
            })
        
        return Output(list: _chatList.asDriver(), refreshTrigger: refreshTrigger.asDriver(onErrorJustReturn: true))
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
