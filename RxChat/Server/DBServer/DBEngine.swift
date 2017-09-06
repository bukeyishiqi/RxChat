//
//  DBManager.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/28.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation


public class DBEngine {

    static let `default`: DBEngine = {
        return DBEngine()
    }()
    
    var database: Database? = nil // 数据库操作对象
    
    /** 连接数据库*/
    func connectToDB(path: String) throws {
        if database == nil {
            /** 初始化数据*/
            do {
                try database = Database.init(filePath: path)
            } catch  {
                print(error)
                throw error
            }
            /** 创建表*/
            createAllTable()
        }
    }
    
    /** 断开数据库连接*/
    func disConnectToDB() {
         database = nil
    }
    
    /** 创建表*/
    func createTable(name: String) -> Bool {
        guard ((try? database?.exsit(tableName: name)) != nil) else {
            return true
        }
        let sql = TableBuild.sqlByTable(name)
        do {
            try database?.create(sql: sql)
            return true
        } catch _ {
            
            return false
        }
    }

    private func createAllTable() {
        let arr = TableBuild.allTables()
        for tableName in arr {
          _ = createTable(name: tableName)
        }
    }
}




















