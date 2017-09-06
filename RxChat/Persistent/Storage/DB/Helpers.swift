//
//  Helpers.swift
//  MallMobile
//
//  Created by 陈琪 on 2016/11/29.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation

/** 验证字符串是否为空*/


/** 拼接where语句
 * return where条件中对应value
 */
public func extractSql(filter: Any, complete: (_ appendStr: String, _ value: [Any]?) -> Void) {
    if filter is String {
       complete(" where \(filter)", nil)
    } else if let condition = filter as? [String: Any], condition.count > 0 {
        /** 拆分filter*/
        parseWhereInfo(info: condition, complete: { (filterString, filterValues) in
            complete("where \(filterString)", filterValues)
        })
    }
}


/** 查询拼接*/
public func sqlAppendRestrain(sql: String, orderBy: String?, offSet: Int?, count: Int?) -> String {
    var newSql = sql
    guard sql.characters.count > 0 else {
        return newSql
    }
    if let orderBy = orderBy {
        newSql.append(" order by \(orderBy)")
    }
    if let offSet = offSet, let count = count {
        newSql.append(" limit \(count) offset \(offSet)")
    }
    return newSql
}


// MARK: private methods

/** 拆分sql条件字典*/
private func parseWhereInfo(info: [String: Any], complete: (_ appendStr: String, _ value: [Any]?) -> Void) {
    
    if info.count > 0 {
       
        var filterString: String = ""
        var filterValues: [Any] = []
        
        for (key, value) in info {
            
            /** 如果value为数组，使用in 进行拼接*/
            if let value = value as? [Any] {
                if value.count == 0 {
                    continue
                }
                
                if filterString.characters.count > 0 { /** 已存在key 用 and 拼接*/
                    filterString.append(" and")
                }
                
                filterString.append("\(key) in(")
                
                var index = 0
                for valueItem in value {
                    
                    filterString.append("?")
                    if index == value.count - 1 {
                        filterString.append(")")
                    } else {
                        filterString.append(",")
                    }
                    
                    filterValues.append(valueItem)
                    index += 1
                }
                
            } else { /** 不是使用 and 进行拼接*/
                if filterString.characters.count > 0 {
                    filterString.append(" and \(key)=?")
                } else {
                    filterString.append(" \(key)=?")
                }
                filterValues.append(value)
            }
        }
        complete(filterString, filterValues)
    }
}









