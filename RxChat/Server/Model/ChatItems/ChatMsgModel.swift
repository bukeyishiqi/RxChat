//
//  ChatMsgModel.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/29.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


struct ImageItem {
    
}

struct VideoItem {
    
}

struct LocationItem {
    
}

struct VoiceItem {
    
}

struct FileItem {
    
}


struct ChatItem {
    
    var msgId: String
    var userId: String
    var userName: String
    var userHeadUrl: String? = ""

    var msgDesType: MsgDesType
    var msgTime: String
    var msgBodyType: MsgBodyType
    var msgStatus: MsgStatus
    
    init(msgId: String, userId: String, userName: String, userHeadUrl: String? = nil, msgdesType: MsgDesType, msgStatus: MsgStatus, msgtime: String, bodyType: MsgBodyType) {
        self.msgId = msgId
        self.userId = userId
        self.userName = userName
        self.userHeadUrl = userHeadUrl
        self.msgDesType = msgdesType
        self.msgStatus = msgStatus
        self.msgTime = msgtime
        self.msgBodyType = bodyType
    }
}


extension ChatItem : CustomDBFormatConvertible {
    typealias T = ChatItem
    
    /** 数据转对象*/
    static func convertDBdataToObj(dbData: [String: Any?]) -> ChatItem {
        return ChatItem.init(info: dbData)
    }
    
    func convertToDBformat() -> [String : Any] {
        var formatDic = [String: Any]()
        
        formatDic[chat_msgSvrId] = msgId
        formatDic[chat_msgUserId] = userId
        formatDic[chat_msgUserName] = userName
        formatDic[chat_des] = msgDesType
        formatDic[chat_msgStatus] = msgStatus
        formatDic[chat_time] = msgTime
        formatDic[chat_msgType] = msgBodyType.intValue
        formatDic[chat_message] = msgBodyType.storeValue
        
        formatDic[chat_fileStatus] = 0
        return formatDic
    }
    
    init(info: [String: Any?]) {
        
        let msgId = info[chat_msgSvrId] as! String
        let userId = info[chat_msgUserId] as! String
        let userName = info[chat_msgUserName] as! String
        let des = info[chat_des] as! MsgDesType
        
        let msgStatus = info[chat_msgStatus] as! MsgStatus
        let time = info[chat_time] as! String
        
        self.init(msgId: msgId, userId: userId, userName: userName, userHeadUrl: nil, msgdesType: des, msgStatus: msgStatus, msgtime: time, bodyType: .text(text: ""))
    }
}











