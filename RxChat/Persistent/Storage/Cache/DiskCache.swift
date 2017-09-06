//
//  DiskCache.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/8/12.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation

// MARK: 磁盘数据管理类
public class DiskCache {
    // MARK: 限制参数设置
    fileprivate var _countLimit: UInt = UInt.max
    public var countLimit: UInt { /** 对象数量限制*/
        set {
            _lock()
            _countLimit = newValue
            trimeToCount(count: newValue)
            _unlock()
        }
        get {
            _lock()
            let countLimit = _countLimit
            _unlock()
            return countLimit
        }
    }
    fileprivate var _costLimit: UInt = UInt.max
    public var costLimit: UInt { /** 总开销限制*/
        set {
            _lock()
            _costLimit = newValue
            trimeToCost(cost: newValue)
        }
        get {
            _lock()
            let costLimit = _costLimit
            _unlock()
            return costLimit
        }
    }
    
    fileprivate var _ageLimit: TimeInterval = DBL_MAX
    public var ageLimit: TimeInterval { /** 有效时间限制*/
        set {
            _lock()
            _ageLimit = newValue
            trimeToAge(age: newValue)
        }
        get {
            _lock()
            let ageLimit = _ageLimit
            _unlock()
            return ageLimit
        }
    }
    
    public var _autoTrimInterval:TimeInterval = 60  /** 默认自动检测间隔时间60s*/

    fileprivate let _queue = DispatchQueue.init(label: "com.cache.disk", qos: .userInitiated, attributes: .concurrent)

    fileprivate let _semaphoreLock = DispatchSemaphore.init(value: 1)

    fileprivate let db: Database?
    
    fileprivate let path: String
    fileprivate let fileSavePath: String
    fileprivate let inlineThreshold: UInt
    // MARK: init
    convenience public init(_ path: String) {
        self.init(path, threshold: 1024 * 20)  // 1024 * 20 为默认限制大小
    }
    
    public init(_ path: String, threshold: UInt) {
        self.path = path
        self.fileSavePath = path.appending("/\(self.path)")
        self.inlineThreshold = threshold
        
        do {
            db = try Database.init(filePath: path)
            
            /** 创建缓存数据库表*/
            self.dbCreateTable()
            /** 限制时间内循环检索数据有效性*/
            self .trimRecursively()
            
        } catch let error {
            db = nil
            if let error = error as? DBResult {
                print("缓存数据库创建失败！error: \(error.description)");
            } else {
                print("缓存数据库创建失败！error: \(error)");

            }
            return
        }

    }
}

// MARK:
// MARK: 对外接口
extension DiskCache {
    /**
     *  包含莫对象
     */
    public func containsObject(forKey key: String) -> Bool {
        return false
    }
    
    /** 存储对象*/
    public func setObject(obj: Any, for key: String) {
        let value: Data = converToData(value: obj)
       
        var fileName: String? = nil
        if value.count > Int(self.inlineThreshold) {
            fileName = OYUtils.md5String(str: key)
        }
        
        self._lock()
        save(key: key, value: value, fileName: fileName, extendedData: nil)
        self._unlock()
    }
    
//    /** 存储文件类型数据*/
//    public func setFile(fileName: String, value: NSData, key: String, extendedData: NSData?) {
//        self._lock()
//        save(key: key, value: value as Data, fileName: fileName, extendedData: extendedData as Data?)
//        self._unlock()
//    }
    
    /** 获取数据对象*/
    public func object(forKey key: String) -> Any? {
        self._lock()
        let obj = get(forKey: key)
        self._unlock()
        return obj
        
    }
    
    /** 删除对象*/
    public func removeObject(forKey key: String) {
        self._lock()
        self.remove(forKey: key)
        self._unlock()
        
    }
    
    /** 删除所有数据*/
    public func removeAllObject() {
        
    }
    
    
}


// MARK:
// MARK: Private
extension DiskCache {
    
    /** 循环检测数据有效性*/
    fileprivate func trimRecursively() {
        
        DispatchQueue.global().asyncAfter(deadline:DispatchTime.now() + _autoTrimInterval) {
            self.trimInBackground()
            self.trimRecursively()
        }
    }
    fileprivate func trimInBackground() {
        _queue.async {
            self.trimeToCount(count: self._countLimit)
            self.trimeToCost(cost: self._costLimit)
            self.trimeToAge(age: self._ageLimit)
        }
    }

    // MARK: 缓存设置参数调整
    fileprivate func trimeToCount(count: UInt) { // 调整对象总数
    
    }
    
    fileprivate func trimeToCost(cost: UInt) { // 调整总存储开销
    
    }
    
    fileprivate func trimeToAge(age: TimeInterval) { // 调整数据有效时间限制

    }
    
    fileprivate func _lock() {
        _semaphoreLock.wait()
    }
    
    fileprivate func _unlock() {
        _semaphoreLock.signal()
    }
    
    /** 存储数据接口*/
    @discardableResult
    fileprivate func save(key: String, value: Data, fileName: String? = nil, extendedData: Data? = nil) -> Bool {
        guard key.characters.count > 0 && value.count > 0 else {return false}
        
        if let fileName = fileName { // 写入文件系统
            if self.fileWrite(name: fileName, data: value as NSData) == false {
                return false
            }
            if self.dbSave(key: key, value: value as NSData, fileName: fileName, extendedData: extendedData as NSData?) == false {
                return false
            }
            return true
        } else {
             /** 删除文件系统已存在对应文件*/
            if let existName = dbGetFileName(key: key) {
                fileDelete(name: existName)
            }
            /** 保存文件至数据库*/
           return dbSave(key: key, value: value as NSData, fileName: nil, extendedData: extendedData as NSData?)
        }
    }
    
    /** 获取数据接口*/
    @discardableResult
    fileprivate func get(forKey key: String) ->Any? {
        var obj: Any?
        /** 获取数据库存储记录 如果存在，更新使用时间*/
        guard let result = dbGetRecord(forKey: key) else {return nil}
        
        if let value = result.first?[inline_data] {
            return convertToObj(data: value as! Data)
        }
        /** 如果存在文件名，从文件系统获取文件，如果没有值则删除数据库记录*/
        if let fileNmae = result.first?[fileName] {
            let value = fileRead(name: fileNmae as! String)
            if value == nil {
                dbDelete(forKey: key)
            } else {
                obj = convertToObj(data: value as! Data)
                return obj
            }
        }
        return nil
    }
    
    /** 数据删除*/
    fileprivate func remove(forKey key: String) {
        /** 先取文件名，如果存在则从文件系统删除*/
        if let result = dbGetRecord(forKey: key) {
            if let fileName = result.first?[fileName] {
                fileDelete(name: fileName as! String)
            }
        }
        dbDelete(forKey: key)
    }
    
    /** 删除所有数据*/
    fileprivate func removeAll() {
        /** 文件系统删除所有缓存文件*/
        
        /** 数据库数据重新初始*/
    }
}


/** 创建数据库表字段  */
let tableName = "cacheTable" // 表名

let key = "ley"                     //主键
let fileName = "fileName"           //文件名
let size = "size"                   //文件大小
let inline_data =  "inline_data"    //文件二进制内容
let modify_time = "modify_time"     //修改时间
let extended_data = "extended_data" //扩展数据



// MARK:
// MARK: 数据存储DB、文件系统读写
extension DiskCache {

    
    // MARK: DB
    
    /** 创建数据库表
     key            主键
     fileName       文件名
     size           文件大小
     inline_data    文件二进制内容
     modify_time    修改时间
     extended_data  扩展数据
     */
    fileprivate func dbCreateTable() {
        let sql = "create table if not exists \(tableName) (\(key) text primary key not null, \(fileName) text, \(size) integer default 0, \(modify_time) integer, \(inline_data) blob, \(extended_data) blob); create index if not exists modify_time_idx on \(tableName)(\(modify_time));"
        
        do {
            try db!.executeUpdate(SQL: sql)
        } catch let error {
            print("创建数据库缓存表失败，error：\(error)")
        }
    }
    
    /** 数据写入*/
    fileprivate func dbSave(key: String, value: NSData, fileName: String?, extendedData: NSData?) -> Bool {
        /** 构建插入数据*/
        var insertInfo: [String: Any] = [:]
        insertInfo["key"] = key
        if fileName != nil {
            insertInfo["fileName"] = fileName
        }
        insertInfo["size"] = value.length
        insertInfo["inline_data"] = value
        insertInfo["modify_time"] = OYUtils.getTimestamp()
        if extendedData != nil {
            insertInfo["extended_data"] = extendedData
        }
        
        return db!.insert(tableName: "cacheTable", value: insertInfo)
    }
    
    /** 获取文件名*/
    fileprivate func dbGetFileName(key: String) -> String? {
        let sql = "select fileName from cacheTable where key=\(key)"
        
        do {
          let result = try db?.excuteQuery(SQL: sql)
            if let result = result, result.count > 0 {
                let colmnInfo = result[0]
                return colmnInfo["fileName"] as! String?
            } else {
                return nil
            }
        } catch _ {
            return nil
        }
    }
    
    /** 获取一条插入记录数据*/
    fileprivate func dbGetRecord(forKey key: String) ->[[String: Any?]]? {
        let sql = "select * from \(tableName) where key=\(key)"
        do {
            let result = try db!.excuteQuery(SQL: sql)
            return result
        } catch _ {
            return nil
        }
    }
    
    /** 数据更新*/
    
    /** 数据删除*/
    @discardableResult
    fileprivate func dbDelete(forKey key: String) -> Bool {
       return db!.delete(tableName: tableName, filters: key)
    }
    
    // MARK: 文件系统
    
    /** 文件写入*/
    fileprivate func fileWrite(name: String, data: NSData) -> Bool {
        let filePath = self.fileSavePath.appending("/\(name)")
        return data.write(toFile: filePath, atomically: false)
    }
    
    /** 文件读取*/
    fileprivate func fileRead(name: String) -> NSData? {
        let filePath = self.fileSavePath.appending("/\(name)")
        return NSData.init(contentsOfFile: filePath)
    }
    
    /** 文件删除*/
    @discardableResult
    fileprivate func fileDelete(name: String) -> Bool {
        let filePath = self.fileSavePath.appending("/\(name)")
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch _ {
            return false
        }
    }
}





