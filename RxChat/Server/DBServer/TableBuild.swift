//
//  tables.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/28.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

/*==============================================================*/
/* Table: virtual        虚表                               */
/*==============================================================*/

let dual_dummy = "DUMMY"

let table_dual = "dual"
let  table_dual_sql = "CREATE TABLE IF NOT EXISTS \(table_dual) （\(dual_dummy) TEXT(1,0))"



/*==============================================================*/
/* Table: Session        会话表                               */
/*==============================================================*/
/**
 字段名	类型	约束	备注
 sessionId	TEXT NOT NULL	PRIMARY KEY UNIQUE ON CONFLICT REPLACE	会话ID
 title  TEXT NOT NULL       标题
 headUrl  TEXT              头像
 sessionType  INTEGER DEFAULT 0     会话类型（单聊）
 lastMsgId    TEXT          最后显示消息ID
 lastUpdateTime INTEGER DEFAULT 0	 最后更新消息时间
 unreadCount	INTEGER DEFAULT 0		未读消息数量
 textDraft      TEXT        草稿
 */
let session_Id = "sessionId"
let session_title = "title"
let session_type = "sessionType"
let session_lastMsgId = "lasMsgId"
let session_lastUpdateTime = "lastUpdateTime"
let session_unreadCount = "unreadCount"
let session_textDraft = "textDraft"

let table_Session = "Session"
let table_Session_sql = "CREATE TABLE IF NOT EXISTS \(table_Session) (sessionId TEXT NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, title TEXT, headUrl TEXT, sessionType INTEGER DEFAULT 0,lastMsgId TEXT, lastUpdateTime INTEGER DEFAULT 0, unreadCount INTEGER DEFAULT 0, textDraft TEXT)"

/*==============================================================*/
/* Table: Chat_        消息表                               */
/*==============================================================*/
/**
 字段名	类型	约束	备注
 msgLocalId	INTEGER	PRIMARY KEY AUTOINCREMENT	消息本地ID
 msgSvrId   TEXT NOT NULL 消息id
 msgUserId  TEXT NOT NULL 
 msgUserName TEXT
 message	TEXT 		消息内容
 time	TEXT		创建时间
 msgStatus	INTEGER 	DEFAULT 0	消息状态（发送成功、失败等）
 fileStatus INTERGER DEFAUTL 0  文件状态
 type	INTEGER	DEFAULT 0	消息类型（文本、图片、语音等）
 des  INTEGER DEFAULT 0  消息描述（我发送的、接收的）
 */

let chat_msgLocalId = "msgLocalId"
let chat_msgSvrId = "msgSvrId"
let chat_msgUserId = "msgUserId"
let chat_msgUserName = "msgUserName"
let chat_message = "message"
let chat_time = "time"
let chat_msgStatus = "msgStatus"
let chat_fileStatus = "fileStatus"
let chat_msgType = "msgType"
let chat_des = "des"

let table_chat_perfix = "Chat_"
func table_chat_sql(name:String) -> String {
    return "CREATE TABLE IF NOT EXISTS \(name) (\(chat_msgLocalId) INTEGER PRIMARY KEY AUTOINCREMENT, \(chat_msgSvrId) TEXT DEFAULT NULL,\(chat_msgUserId) TEXT NOT NULL, \(chat_msgUserName) TEXT, \(chat_message) TEXT, \(chat_time) INTEGER DEFAULT 0, \(chat_msgStatus) INTEGER DEFAULT 0, \(chat_fileStatus) INTEGER DEFAULT 0, \(chat_msgType) INTEGER DEFAULT 0, \(chat_des) INTEGER DEFAULT 0)"
}

public class TableBuild {
    
    
    /** 创建所有数据库表*/

    class func allTables() -> [String] {
        
        return [table_dual, table_Session]
    }
    
    class func sqlByTable(_ tableName: String) -> String {
        if tableName == table_dual {
            return table_dual_sql
        } else if tableName == table_Session {
            return table_Session_sql
        } else if tableName.hasPrefix(table_chat_perfix) {
            return  table_chat_sql(name: tableName)
        }
        return ""
    }
    
  
    
    /** */
}








