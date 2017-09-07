//
//  ChatService.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/24.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ChatService {

    static let shared = ChatService()

    /** 获取会话列表*/
    func loadConversationListFromDB() -> [Conversation] {
        let list = DBEngine.default.queryConversationList()
        if let list = list {
            return list
        }
        return [Conversation]()
    }
    
    /** 发送消息*/
    func send(_ text: String?  = nil, _ gif: String?  = nil, _ image: String? = nil) -> Observable<ChatItem> {
        let sendItem: ChatItem?
        if let sendText = text {
            /** 创建item*/
            sendItem = ChatItemFactory.createChatTextItem(text: sendText, userId: "222", userName: "陈琪")
        } else if let sendGif = gif {
            sendItem = ChatItemFactory.createChatTextItem(text: sendGif, userId: "222", userName: "陈琪")
        } else if let sendImage = image {
            sendItem = ChatItemFactory.createChatTextItem(text: sendImage, userId: "222", userName: "陈琪")
        } else {
            sendItem = nil
        }
        
        /** 添加到消息发送队列*/
        
        guard let item = sendItem else {
            return Observable.never()
        }
        return Observable.just(item)
    }
}
