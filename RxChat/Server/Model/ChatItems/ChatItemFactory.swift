//
//  ChatItemFactory.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/4.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


protocol ChatItemFactoryEnable {
    
    /** 创建文本类型消息Item*/
    static func createChatTextItem(text: String, userId: String, userName: String) -> ChatItem
    
    
    /** 创建消息Item 根据info及类型*/
    static func createChatItem(info:[String: Any?]) -> ChatItem
}


public class ChatItemFactory: ChatItemFactoryEnable {
    /** 创建消息Item 根据info及类型*/
    static func createChatItem(info: [String : Any?]) -> ChatItem {
        return ChatItem.init(info: info)
    }

    /** 创建文本类型消息Item*/
    static func createChatTextItem(text: String, userId: String, userName: String) -> ChatItem {
        let msgId = ""
        let time = ""
        return ChatItem.init(msgId: msgId, userId: userId, userName: userName, msgdesType: .send, msgStatus: .delivering, msgtime: time, bodyType: .text(text: text))
    }

    


}
