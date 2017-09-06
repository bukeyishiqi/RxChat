//
//  ConversationTable.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/24.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


/** 
 *  Conversation表操作
 */
extension DBEngine {

    /** 查询会话列表*/
    func queryConversationList() -> [Conversation]? {
        
        var conversationList = [Conversation]()

        database?.query(tableName: table_Session,orderBy: "\(session_lastUpdateTime) DESC", callback: { (list) in
            /** 解析list*/
            guard let list = list else { return}
            
            for sessionInfo in list {
                var conversation = Conversation.init(info: sessionInfo)
                /** 查询最后一条消息*/
                let chatItemInfos = try? DBEngine.default.query(chatId: conversation.conversationId, msgId: sessionInfo[session_lastMsgId] as! String)
                
                if let info = chatItemInfos??[0] {
                    let chatItem = ChatItem.init(info: info)

                    conversation.updateLastMsgUnit(unit: ConversationLastMsgUnit.init(chatItem: chatItem))
                }
                conversationList.append(conversation)
            }
         })
        return conversationList
    }
    
}





















