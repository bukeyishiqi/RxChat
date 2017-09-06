//
//  ConversationModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/21.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


/**
 * 最后消息单元
 */
struct ConversationLastMsgUnit {
    /** 消息内容*/
    var msgBody: String
    /** 消息ID*/
    var msgId: String
    /** 消息时间*/
    var msgDate: String
    /** 消息状态*/
    var msgStatus: MsgStatus
    /** @我游标位置*/
    var sayToMeIndex: Int?
    
    init(chatItem: ChatItem) {
        self.msgId = chatItem.msgId
        self.msgDate = chatItem.msgTime
        self.msgStatus = chatItem.msgStatus
        self.msgBody = chatItem.msgBodyType.titleValue
    }
    
    mutating func updateLastMsgUnit(msgId: String, msgBody: String, msgDate: String, msgStatus: MsgStatus) {
        self.msgId = msgId
        self.msgBody = msgBody
        self.msgDate = msgDate
        self.msgStatus = msgStatus
    }
    
}



struct Conversation {

    var conversationId: String
    var title: String
    
    /** 草稿*/
    var draft: String?
    /** 未读条数*/
    var unReadMsgNumber: Int
    /** 会话类型*/
    var type: ConversationType
    
    var lastMsgUnit: ConversationLastMsgUnit?
    

    init(conversationId: String, title: String, type: ConversationType = .singleChat, lastMsgUnit: ConversationLastMsgUnit? = nil) {
        self.conversationId = conversationId
        self.title = title
        self.type = type
        self.unReadMsgNumber = 0 // 默认为0
        self.lastMsgUnit = lastMsgUnit
    }
    
    /** 更新最后消息单元*/
    mutating func updateLastMsgUnit(unit: ConversationLastMsgUnit) {
        self.lastMsgUnit = unit
    }
}


extension Conversation: CustomDBFormatConvertible {
    typealias T = Conversation

    /** 数据转对象*/
    static func convertDBdataToObj(dbData: [String : Any?]) -> Conversation {
        return Conversation.init(info: dbData)
    }

    func convertToDBformat() -> [String : Any] {
        var formatDic = [String: Any]()

        formatDic[session_Id] = self.conversationId
        formatDic[session_title] = self.title
        formatDic[session_type] = self.type.rawValue
        if self.draft != nil {
            formatDic[session_textDraft] = self.draft
        }
        formatDic[session_unreadCount] = self.unReadMsgNumber
        
        guard let unit = self.lastMsgUnit else {
            return formatDic
        }
        
        formatDic[session_lastMsgId] = unit.msgId
        formatDic[session_lastUpdateTime] = unit.msgDate
        
        return formatDic
    }
    
    init(info: [String: Any?]) {
        let id = info[session_Id] as! String
        let title = info[session_title] as! String
        let type = info[session_type] as! Int
        let unreadNumber = info[session_unreadCount] as! Int
        let draft = info[session_textDraft] as! String
        
        self.init(conversationId: id, title: title, type: ConversationType(rawValue: type)!)
        self.unReadMsgNumber = unreadNumber
        self.draft = draft
    }
}






















