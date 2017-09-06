//
//  Table.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/9/14.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation


/**
 *  构建表  （暂无使用）
 */

public protocol BuilderType {
    
    var identifier: String {get}
}

extension BuilderType {

    /** 构建*/
    func create() {
    
    }
    
}



public struct Table: BuilderType {
    public var identifier: String = "Table"
    
}

public struct View: BuilderType {
    public var identifier: String = "View"


}

public struct VirtualTable: BuilderType {
    public var identifier: String = "Virtual Table"
}



enum Constraint {
    case notNull
    case default1(defaultValue: Any)
    case unique
    case primaryKey
    case check(sucess: Bool)
}

extension Constraint: CustomStringConvertible {

    public var description: String {
        switch self {
        case .notNull:
            return "NOT NULL"
        case let .default1(defaultValue: defaultValue):
            return "DEFAULT \(defaultValue)"
        case .primaryKey:
            return "PRIMARY KEY"
        case let .check(sucess: sucess):
            return "CHECK(\(sucess))"
        default:
            return "NOT NULL"
        }
    }
}




