//
//  Operate.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/9/14.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation


/**
 *  数据库操作调用接口
 */

extension Database {

    public enum TableType: String {
        case table = "Table"
        case virtual = "Virtual Table"
        case view = "View"
    }
    
    // MARK:
    // MARK: 表操作
    /** 验证表是否存在*/
    public func exsit(tableName: String) throws -> Bool {
        let name = tableName.localizedLowercase
        let sql = "select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?;"
        
        let rs =  try self.excuteQuery(statement: sql, name)
        
        if let rs = rs, rs.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    /** 创建表、虚表、视图*/
    public func create(sql: String) throws {
        try self.executeUpdate(SQL: sql)
    }

    /** 删除表*/
    public func drop(tableName: String, tableType: TableType = .table) throws {
        let sql = "drop \(tableType.rawValue) \(tableName) if exists \(tableName)"
        try self.executeUpdate(SQL: sql)
    }
    

    /** 修改表名*/
    public func rename(tableName: String, to newNmae: String) throws {
        let sql = "alter table \(tableName) rename to \(newNmae);"
        try self.executeUpdate(SQL: sql)
    }



// MARK: 
// MARK: 增、删、改、查

    /** Insert*/
    public func insert(tableName: String,value: [String: Any]) -> Bool {
        return insertBase(tableName: tableName, value: value)
    }
    /** Insert (异步)*/
    public func insert(tableName: String, value: [String: Any], callback: @escaping (_ result: Bool) -> Void) {
        DispatchQueue.global().async {
            let success: Bool = self.insertBase(tableName: tableName, value: value)
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }
    
    /** Delete 
     filters: format： "condition1 = value ..." or [string: value]
     */
    public func delete(tableName: String, filters: Any) -> Bool {
        return deleteBase(tableName: tableName, filters: filters)
    }
    public func delete(tableName: String, filters: Any, callback:@escaping (_ result: Bool) -> Void) {
        DispatchQueue.global().async {
            let success: Bool = self.deleteBase(tableName: tableName, filters: filters)
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }
    
    /** Update*/
    public func update(tableName: String, value: [String: Any], filters: Any) -> Bool {
        return updateBase(tableName: tableName, value: value, filters: filters)
    }
    public func update(tableName: String, value: [String: Any], filters: Any, callback:@escaping (_ result: Bool) -> Void) {
        DispatchQueue.global().async {
            let success: Bool = self.updateBase(tableName: tableName, value: value, filters: filters)
            
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }

    /** Query*/
    public func query(tableName: String, filters: Any? = nil, orderBy: String? = nil, offSet: Int? = nil, count: Int? = nil) -> [[String: Any?]]? {
        return queryBase(tableName: tableName,filters: filters, orderBy: orderBy, offSet: offSet, count: count)
    }
    public func query(tableName: String, filters: Any? = nil, orderBy: String? = nil, offSet: Int? = nil, count: Int? = nil, callback:@escaping (_ result: [[String: Any?]]?) -> Void) {
        DispatchQueue.global().async {
            let value = self.queryBase(tableName: tableName,filters: filters, orderBy: orderBy, offSet: offSet, count: count)
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }
    
    
    // MARK: 
    // MARK: Private Methods
    
    /**构建插入SQL语句
     * replace into table (key1, key2, key3...) values (value1, value2, value3...)
     */
    private func insertBase(tableName: String, value: [String: Any]) -> Bool {
        var values: [Any] = []
        var keys: String = ""
        var markStr: String = ""
        
        for (key, insertValue) in value {
            
            keys.append(",")
            markStr.append(",")

            keys.append(key)
            markStr.append("?")
            values.append(insertValue)
        }
        
        /** sql 拼接*/
        let i = keys.index(keys.startIndex, offsetBy: 1)
        let j = markStr.index(markStr.startIndex, offsetBy: 1)
        let sql = "replace into \(tableName)(\(keys.substring(from: i))) values (\(markStr.substring(from: j)))"
       
        do {
            try excuteUpdate(statement: sql, values)
            return true
        } catch _  {
            return false
        }
    }
    
    
    /** 构建更新SQL语句
     * update "table" set key1=? , key2=?..... where condition
     */
    private func updateBase(tableName: String, value: [String: Any], filters: Any) -> Bool {
        var values: [Any] = []
        var keys: String = ""
        
        for (key, updateValue) in value {
            keys.append(",")
            keys.append("\(key)=?")
            
            values.append(updateValue)
        }
        
        let i = keys.index(keys.startIndex, offsetBy: 1)
        var sql = "update \(tableName) set \(keys.substring(from: i))"
        
        /** 条件转换拼接*/
        extractSql(filter: filters, complete:{ (filterString, filterValues) in
            sql.append(filterString)
            
            if let filterValues = filterValues {
                values = values + filterValues
            }
        })
        
        do {
            try excuteUpdate(statement: sql, values)
            return true
        } catch _  {
            return false
        }
    }
    
    
    
    /** 构建删除SQL语句
     * delete from table where condition
     */
    private func deleteBase(tableName: String, filters: Any) -> Bool {
        var values: [Any] = []
        var sql = "delete from \(tableName)"

        /** 条件转换拼接*/
        extractSql(filter: filters, complete:{ (filterString, filterValues) in
            sql.append(filterString)
            
            if let filterValues = filterValues {
                values = values + filterValues
            }
        })
        do {
            try excuteUpdate(statement: sql, values)
            return true
        } catch _  {
            return false
        }
    }
    
    
    /** 构建查询SQL语句
     * Select * from table where conditions...
     */
    private func queryBase(tableName: String, filters: Any?, orderBy: String?, offSet: Int?, count: Int?) -> [[String: Any?]]? {
        guard tableName.characters.count > 0 else {
            return nil
        }
        var values: [Any] = []

        var sql = "select * from \(tableName)"
        
        if let filters = filters {
            extractSql(filter: filters, complete:{ (filterString, filterValues) in
                sql.append(filterString)
                
                if let filterValues = filterValues {
                    values = values + filterValues
                }
            })
        }

        sql = sqlAppendRestrain(sql: sql, orderBy: orderBy, offSet: offSet, count: count)
        
        do {
            return  try excuteQuery(statement: sql, values)
        } catch _ {
            return  nil
        }
    }
    
}
