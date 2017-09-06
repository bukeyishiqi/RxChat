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
    func sendText(text: String) -> Observable<ChatItem> {
        /** 创建item*/
        let item = ChatItemFactory.createChatTextItem(text: text, userId: "222", userName: "陈琪")
        /** 添加到消息发送队列*/
        
        
        return Observable.just(item)
    }
}
