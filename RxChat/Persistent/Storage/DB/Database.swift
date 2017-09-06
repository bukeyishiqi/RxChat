//
//  DBManager.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/9/14.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation

public final class Database {

    public var handle: OpaquePointer { return _handle! }
    
    private var _handle: OpaquePointer? = nil

    // MARK: 数据库初始建立连接 全路径
    public init(filePath: String) throws {
        let fileName = filePath.cString(using: String.Encoding.utf8)
        try check(resultCode: sqlite3_open(fileName!, &_handle))
        queue.setSpecific(key: Database.queueKey, value: queueContext)
    }

    deinit {
        sqlite3_close(handle)
        print("******数据库关闭*****")
    }
    
    private let queue = DispatchQueue.init(label: "dataBase.queue", attributes: [])// 串行队列
    private static let queueKey = DispatchSpecificKey<Int>() // 队列key
    private lazy var queueContext : Int = unsafeBitCast(self, to: Int.self)
    
    // MARK: 操作执行接口（完整的SQL语句）
    public func executeUpdate(SQL: String) throws {
        try sync(block: {
            try self.check(resultCode: sqlite3_exec(self.handle, SQL, nil, nil, nil))
        })
    }
    
    public func excuteQuery(SQL: String) throws -> [[String: Any?]]? {
          return  try Statement.init(self, SQL).query(nil)
    }
    
    public func excuteUpdate(statement: String, _ arguments: Any?...) throws {
        try Statement(self, statement).modify(arguments)
    }
    public func excuteUpdate(statement: String, _ arguments: [Any?]) throws {
        try Statement(self, statement).modify(arguments)
    }
    public func excuteUpdate(statement: String, _ arguments: [String: Any?]) throws {
        try Statement(self, statement).modify(arguments)
    }

    
    public func excuteQuery(statement: String, _ arguments: Any?...) throws -> [[String: Any?]]?{
        return try Statement(self, statement).query(arguments)
    }
    public func excuteQuery(statement: String, _ arguments: [Any?]) throws -> [[String: Any?]]? {
        return try Statement(self, statement).query(arguments)
    }
    public func excuteQuery(statement: String, _ arguments: [String: Any?]) throws -> [[String: Any?]]? {
        return try Statement(self, statement).query(arguments)
    }
    
    // MARK: 错误统一处理
    @discardableResult
    func sync<T>(block: @escaping () throws -> T) rethrows -> T {
        var success: T?
        var failure: Error?
        
        let box:() -> Void = {
            do {
                success = try block()
            } catch {
                failure = error
            }
        }
        
        /** 在当前队列下*/
        if DispatchQueue.getSpecific(key: Database.queueKey) == queueContext {
            box()
        } else {
            queue.sync(execute: box)
        }
        
        if let failure = failure {
            try { () -> Void in throw failure }()
        }
        
        return success!
    }
    
    /** 数据库执行返回值检测*/
    @discardableResult
    func check(resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        guard let error = DBResult(errorCode: resultCode, db: self, statement: statement) else {
            return resultCode
        }
        throw error
    }
}

public enum DBResult: Error {
    /** 成功状态*/
    private static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]
    
    case  Error(message: String, code: Int32, statement:Statement?)
    
    init?(errorCode: Int32, db: Database, statement: Statement? = nil) {
        /** 不为成功状态*/
        guard !DBResult.successCodes.contains(errorCode) else { return nil}
     
        let message = String.init(cString: sqlite3_errmsg(db.handle))
        
        self = .Error(message:message, code: errorCode, statement: statement)
    }
}

// MARK: 获取错误状态描述信息
extension DBResult: CustomStringConvertible {
    public var description: String {
        switch self{
        case let .Error(message, _, statement):
            guard let statement = statement else { return message }
            return "\(message) (\(statement))"
        }
    }
}









