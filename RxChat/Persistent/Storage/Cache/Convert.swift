//
//  Convert.swift
//  MallMobile
//
//  Created by 陈琪 on 2016/12/13.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation

/**
 *  data转对象
 */
public protocol DataConvertible {

    associatedtype result
    /** 转换为对应对象*/
    static func convertFromData(data: Data) -> result?
}

/**
 *   数据类型转data
 */
public protocol DataRepresentable {
    
    func asData() -> Data!
}


/**
 *  获取缓存对象data
 */

public func converToData(value: Any) -> Data! {
//    if let string = value as? String {
//        return string.asData()
//    } else if let data = value as? NSData {
//        return data.asData()
//    } else if let json = value as? Json {
//        return json.asData()
//    } else {
//        let cacheObj = CacheObject.init(value: value)
//        return cacheObj.asData()
//    }
    let cacheObj = CacheObject.init(value: value)
    return cacheObj.asData()

}

/**
 *  data转对象
 */
public func convertToObj(data: Data) -> Any? {
    guard let obj = CacheObject.convertFromData(data: data) else {return nil}
    
    return obj.value
}



extension String : DataConvertible, DataRepresentable {
    
    public typealias result = String
    
    public static func convertFromData(data: Data) -> result? {
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string as? result
    }
    
    public func asData() -> Data! {
        return self.data(using: String.Encoding.utf8)
    }
    
}


extension NSData : DataConvertible, DataRepresentable {

    public typealias result = NSData
    
    public class func convertFromData(data: Data) -> result? {
        return data as NSData

    }
    
    public func asData() -> Data! {
        return self as Data
    }
}

public enum Json : DataConvertible, DataRepresentable {

    public typealias result = Json
    
    case Dictionary([String: Any])
    case Array([Any])
    
    public static func convertFromData(data: Data) -> result? {
        do {
           let obj =  try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            switch obj {
            case let dic as [String: Any]:
                
                return Json.Dictionary(dic)
            case let arr as [Any]:
                
                return Json.Array(arr)
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    public func asData() -> Data! {
        switch self {
        case .Dictionary(let dictionary):
            
            return try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        case .Array(let array):
            return try? JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
    }

    public var array : [Any]! {
        switch (self) {
        case .Dictionary(_):
            return nil
        case .Array(let array):
            return array
        }
    }
    
    public var dictionary : [String:Any]! {
        switch (self) {
        case .Dictionary(let dictionary):
            return dictionary
        case .Array(_):
            return nil
        }
    }

}


/**
 *  缓存对象
 */
class CacheObject : NSCoding {
    let value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let val = aDecoder.decodeObject(forKey: "value") else {
                return nil
        }
        
        self.value = val as Any
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }
    
}

extension CacheObject: DataConvertible, DataRepresentable {

    typealias result = CacheObject

    public func asData() -> Data! {
        return NSKeyedArchiver.archivedData(withRootObject: self.value)
    }

    /** 转换为对应对象*/
    public static func convertFromData(data: Data) -> CacheObject? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? CacheObject
    }
}













