//
//  RLMChatMessage.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/15.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RealmSwift

class RLMChatMessage: Object {
    /** 消息ID*/
    dynamic var msgSvrId = ""
    /** 消息文本内容*/
    dynamic var message = ""
    /** 消息类型*/
    dynamic var msgType = ""
    /** 消息时间*/
    dynamic var time = ""
    /** 消息状态*/
    dynamic var msgStatus = ""
    /** 文件类型消息状态*/
    dynamic var fileStatus = ""
    /** 消息来源（0 我；1 对方）*/
    dynamic var des = 0
    
    override class func primaryKey() -> String? {
        return "msgSvrId"
    }
    
    override class func indexedProperties() -> [String] {
        return ["msgSvrId"]
    }
    
    
}
