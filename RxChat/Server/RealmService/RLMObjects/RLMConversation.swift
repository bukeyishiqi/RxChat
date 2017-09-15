//
//  RLMConversation.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/15.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RealmSwift

class RLMConversation: Object {
    dynamic var userId: String = ""
    dynamic var userName: String = ""
    dynamic var nikename: String = ""

    let msgList = List<RLMChatMessage>()
    
    override class func primaryKey() -> String? {
        return "userId"
    }
    
    override class func indexedProperties() -> [String] {
        return ["userId"]
    }
}
