//
//  Statement.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/9/14.
//  Copyright © 2016年 carisok. All rights reserved.
//


import Foundation

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

//! sqlite 执行操作对象
public final class Statement {
    
    // stmt* 指针
    public var handle: OpaquePointer? = nil

    private let db: Database

    init(_ db: Database,_ SQL: String) throws {
        self.db = db
        try db.check( resultCode: sqlite3_prepare_v2(db.handle, SQL, -1, &handle, nil))
    }
    
    deinit {
        sqlite3_finalize(handle)
    }
    
    // MARK: 值绑定
    public func bind(_ values: Any?...) {
        return bind(values)
    }
    
    //! 通过数组绑定
    public func bind(_ values: [Any?]) {
        if values.isEmpty {
            return
        }
        reset()
        
        guard values.count == Int(sqlite3_bind_parameter_count(handle)) else {
            fatalError("\(sqlite3_bind_parameter_count(handle)) values expected, \(values.count) passed")
        }
        
        for index in 1...values.count {
            bind(value: values[index - 1]!, atIndex: index)
        }
    }
    
    //! 通过字典绑定
    public func bind(_ values: [String: Any?]) {
        reset()
        for (name, value) in values {
            let index = sqlite3_bind_parameter_index(handle, name)
            guard index > 0 else {
                fatalError("parameter not found: \(name)")
            }
            bind(value: value, atIndex: Int(index))
        }
    }
    
    
    private func bind(value: Any?, atIndex index: Int) {
        
        if value == nil {
            sqlite3_bind_null(handle, CInt(index))
        } else if let text = value as? String {
            sqlite3_bind_text(handle, Int32(index), text, -1, SQLITE_TRANSIENT)
        } else if let data = value as? NSData {
            sqlite3_bind_blob(handle, Int32(index), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
        } else if let double = value as? Double {
            sqlite3_bind_double(handle, Int32(index), double)
        } else if let int = value as? Int {
            sqlite3_bind_int64(handle, Int32(index), Int64(int))
        } else if let int = value as? Int64 {
            sqlite3_bind_int64(handle, Int32(index), int)
        }else if let bool = value as? Bool {
            let value: Int64 = bool ? 1 : 0
            sqlite3_bind_int64(handle, Int32(index), value)
        }else if let value = value {
            fatalError("tried to bind unexpected value \(value)")
        }
    }
    
    // MARK: 修改数据库值（增、删、改）
    public func modify(_ values: Any?...) throws {
        guard values.isEmpty else {
            try modify(values)
            return
        }
        reset(clearBindings: false)
        repeat {} while try step()
    }
    
    public func modify(_ vaules: [Any?]) throws {
        bind(vaules)
        try self.modify()
    }
    
    public func modify(_ values: [String: Any?]) throws {
        /** 先绑定参数值，在执行*/
        bind(values)
        try self.modify()
    }
    
    // MARK: 获取数据库值（查）
    public func query(_ values: Any?...) throws -> [[String: Any?]]? {
        /** 先绑定值，在执行*/
        guard values.isEmpty else {
            try query(values)
            return nil
        }
        
        var rows = [[String:Any?]]()

        while try step() {
            rows.append(ResultSet(statemnet: self).resultInfo!)
        }
        return rows
    }
    
    @discardableResult
    public func query(_ values: [Any?]) throws -> [[String: Any?]]? {
        bind(values)
       return try query()
    }
    
    public func query(_ values: [String: Any?]) throws -> [[String: Any?]]? {
        bind(values)
        return try query()
    }
    
    
    public func step() throws -> Bool {
        return try db.sync { try self.db.check(resultCode: sqlite3_step(self.handle)) == SQLITE_ROW }
    }
    
    private func reset(clearBindings shouldClear: Bool = true) {
        sqlite3_reset(handle)
        if (shouldClear) { sqlite3_clear_bindings(handle) }
    }
}


