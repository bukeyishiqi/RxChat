//
//  CustomDBFormatConvertible.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/3.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation

protocol CustomDBFormatConvertible {

    associatedtype T
    
    /** 对象转数据存储格式*/
    func convertToDBformat() -> [String: Any]
    
    /** 数据转对象*/
    static func convertDBdataToObj(dbData: [String: Any?]) -> T
}

