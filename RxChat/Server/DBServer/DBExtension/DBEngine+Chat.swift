//
//  ChatTable.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/29.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

/** 
 *  chat 表相关操作
 */
extension DBEngine {
    
    private func tableName(chatId: String) -> String? {
        guard chatId.characters.count > 0 else {
            return nil
        }
        return table_chat_perfix.appending(OYUtils.md5String(str: chatId))
    }
    
    /** -----------------增加表数据----------------- */
    func insert(chatId:String, item: ChatItem) throws {
        let dbParams = item.convertToDBformat()
        
        guard let name = tableName(chatId: chatId) else {
            throw NSError.init(domain: "数据表名不存在！", code: 99)
        }
        guard createTable(name: name) else {
            throw NSError.init(domain: "数据表创建失败！", code: 99)
        }
        guard let _ = database?.insert(tableName: name, value: dbParams) else {
            throw NSError.init(domain: "消息插入数据库失败！", code: 99)
        }
    }
    
    /** -----------------删除表数据----------------- */
    /** 删除一条数据数据 */
    func delete(chatId: String, msgId: String) throws {
        guard let name = tableName(chatId: chatId) else {
            throw NSError.init(domain: "数据表名不存在！", code: 99)
        }
        guard let _ = database?.delete(tableName: name, filters: [chat_msgSvrId: msgId]) else {
            throw NSError.init(domain: "消息删除失败！", code: 99)
        }
    }
    
    /** 删除聊天消息表*/
    func dorpChatTable(chatId: String) throws {
        guard let name = tableName(chatId: chatId) else {
            throw NSError.init(domain: "数据表名不存在！", code: 99)
        }
       
        do {
            try database?.drop(tableName: name)
        } catch  {
            throw error
        }
    }
    
    
    /** -----------------查询表数据----------------- */

    /** 查询chat_表数据 时间排序
     * toId  根据toId 往上查询limit条
     * fromId  根据fromId 往下查询limit条
     * limit 查询条数
     * isRemote 是否查询为历史消息显示 Yes 需要过滤未发送和发送失败的消息
     * toId fromId  忽略limit参数 查询toId和fromId之间的数据
     * toId fromId  均为空 从最后一条消息往上查询limit条
     */
    func query(chatId: String, fromId: String? = nil, toId: String? = nil, limit: Int, isRemote: Bool = false) throws -> [[String: Any?]]?  {
        guard let name = tableName(chatId: chatId) else {
            throw NSError.init(domain: "数据表名不存在！", code: 99)
        }
        guard let _ = try database?.exsit(tableName: name) else {
            throw NSError.init(domain: "数据表不存在！", code: 99)
        }
        var sql = ""
        
        let filter1 = MsgStatus.success
        let filter2 = MsgStatus.sended
        
        if let fromId = fromId , let toId = toId {
            if isRemote {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(fromId) and a.\(chat_time) >= b.\(chat_time)) and exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(toId) and a.\(chat_time) < b.\(chat_time)) and (a.\(chat_msgStatus) = \(filter1)) or a.\(chat_msgStatus) = \(filter2)) order by a.\(chat_time) desc"
            } else {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(fromId) and a.\(chat_time) >= b.\(chat_time)) and exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(toId) and a.\(chat_time) < b.\(chat_time)) order by a.\(chat_time) desc"
            }
        } else if let fromId = fromId, toId == nil {
            if isRemote {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(fromId) and a.\(chat_time) > b.\(chat_time)) and (a.\(chat_msgStatus) = \(filter1) or a.\(chat_msgStatus) = \(filter2)) order by a.\(chat_time) desc limit \(limit)"
            } else {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(fromId) and a.\(chat_time) > b.\(chat_time)) order by a.\(chat_time) desc limit \(limit) "
            }
            
        } else if let toId = toId, fromId == nil {
            
            if isRemote {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(toId) and a.\(chat_time) < b.\(chat_time)) and (a.\(chat_msgStatus) = \(filter1) or a.\(chat_msgStatus) = \(filter2)) order by a.\(chat_time) desc limit \(limit)"
            } else {
                sql = "select from * \(name) a where exists (select 1 from \(name) b where b.\(chat_msgSvrId) = \(toId) and a.\(chat_time) < b.\(chat_time)) order by a.\(chat_time) desc limit \(limit) "
            }
            
        } else { // 二者都为空
            if isRemote {
                sql = "select from * \(name) a where a.\(chat_msgStatus) = \(filter1) or a.\(chat_msgStatus) = \(filter2) order by a.\(chat_time) desc limit \(limit)"
            } else {
                sql = "select from * \(name) order by \(chat_time) limit \(limit)"
            }
        }
        
        do {
           return try database?.excuteQuery(SQL: sql)
        } catch  {
            throw NSError.init(domain: "消息查询失败！", code: 99)
        }
    }
    
    /** 根据消息ID 查询一条消息记录*/
    func query(chatId: String, msgId: String) throws -> [[String: Any?]]? {
        let name = tableName(chatId: chatId)!
        guard let _ = try database?.exsit(tableName: name) else {
            throw NSError.init(domain: "数据表不存在！", code: 99)
        }
        
        return database?.query(tableName: name, filters: "\(chat_msgSvrId) = \(msgId)")
    }
    
    
    
    
    /** -----------------更新表数据----------------- */
    /** 更新消息状态 Or 文件状态 */
    func update(chatId: String, msgId: String, msgStatus: Int = 0, fileStatus: Int = 0) throws {
    
    }
}





















