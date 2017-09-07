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
import RxDataSources


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

/**
 *  聊天消息界面滚动位置
 */
enum ScorllPosition {
    case top
    case middle(index: Int)
    case bottom
}

class ChatViewModel: ViewModelType {
    
    struct Input {
//        var refreshCommand: ControlEvent<Void>
//        var startMessageId = Variable<String>("") // 查询id不存在则从表最底部往上查询limit条记录
        var sendTextMsg: Observable<String>
        var sendGifMsg: Observable<String>
        
        init(sendText: Observable<String>, sendGif: Observable<String>) {
            sendTextMsg = sendText
            sendGifMsg = sendGif
        }
    }
    
    
    // MARK: output
    struct Output {
        /** 界面消息列表数据*/
        let list: Driver<[ChatSectionModel]>
        /** 消息发送*/
        var didSendMsg: Driver<Bool>?
        /** 界面滚动位置*/
        let scrollPosition = BehaviorSubject<ScorllPosition>(value: .bottom)

        init(list: Driver<[ChatBaseCellViewModel]>) {
            self.list = list.map({ (list) -> [ChatSectionModel] in
                var section = [ChatSectionModel]()
                section.append(ChatSectionModel.init(data: list))
                return section
            })
        }
    }
    
    func transform(_ input: Input) -> Output {
        var output = Output(list: _chatList.asDriver())
        
        /** 消息发送转换*/
        output.didSendMsg = Observable.merge(input.sendTextMsg, input.sendGifMsg)
            .flatMap({
            ChatService.shared.send($0)
        })
        .flatMap({ (element) -> Observable<Bool> in
            let value = ChatBaseCellViewModel.createCellViewModel(messageItem: element)
            self._chatList.value.append(value)
            output.scrollPosition.onNext(.bottom)
            return Observable.create { observer in
                observer.on(.next(false))
                observer.on(.completed)
                return Disposables.create()
            }
        })
        .asDriver(onErrorJustReturn: (false))
        
        return output
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


struct ChatSectionModel {
    
    var data: [ChatBaseCellViewModel]
}

extension ChatSectionModel: SectionModelType {
    typealias Item  = ChatBaseCellViewModel
    var items: [Item] { return self.data }
    
    init(original: ChatSectionModel, items: [Item]) {
        self = original
        self.data = items
    }
}

























