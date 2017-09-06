//
//  ResultSet.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/9/19.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation

/** 查询结果单行数据处理*/
public struct ResultSet {
    
    /** stmt* 对象 */
    private let handle: OpaquePointer
    
    public init(statemnet: Statement) {
        handle = statemnet.handle!
    }

    /** 查询结果*/
    public var resultInfo: [String:Any]?  {
        get {
        
            let columnCount: Int = Int(sqlite3_column_count(self.handle))
            var columnNames: [String] = (0..<Int32(columnCount)).map {
                String.init(cString: sqlite3_column_name(self.handle, $0))
            }

            var row = [String:Any]()
            
            for index in 0..<columnCount {
                let key = columnNames[Int(index)]
                if let val = getColumnValue(index: index) {
                    row[key] = val
                }
            }
            return row
        }
    }
    
    private func getColumnValue(index: Int) -> Any? {
        
        switch sqlite3_column_type(handle, Int32(index)) {
        case SQLITE_BLOB:
            let data = sqlite3_column_blob(handle, Int32(index))
            let size = sqlite3_column_bytes(handle, Int32(index))
            let val = NSData(bytes:data, length:Int(size))
            return val
        case SQLITE_FLOAT:
            let val = sqlite3_column_double(handle, Int32(index))
            return Double(val)
        case SQLITE_INTEGER:
            let val = sqlite3_column_int(handle, Int32(index))
            return Int(val)
        case SQLITE_NULL:
            return nil
        case SQLITE_TEXT:
            let val = String.init(cString: sqlite3_column_text(handle, Int32(index)))
            return val
        case let type:
            fatalError("unsupported column type: \(type)")
        }

    }
}
