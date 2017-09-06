//
//  Utility.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/5/31.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation

public class OYUtils {
        /** MD5加密*/
    class func md5String(str:String) -> String{
        let cStr = (str as NSString).utf8String
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr,(CC_LONG)(strlen(cStr)), buffer)
        let md5String = NSMutableString()
        for i in 0 ..< 16{
            md5String.appendFormat("%02X", buffer[i])
        }
        
        free(buffer)
        return String(md5String)
    }

    /** 获取时间戳*/
    class func getTimestamp() -> String {
        // 获得当前应用程序默认的时区
        let zone: NSTimeZone = NSTimeZone.default as NSTimeZone
        // 以秒为单位返回当前应用程序与世界标准时间（格林威尼时间）的时差
        let interval: TimeInterval = TimeInterval(zone.secondsFromGMT(for: NSDate() as Date))

        let localeDate = NSDate().addingTimeInterval(interval)
        let timeInterval = localeDate.timeIntervalSince1970
        
        let dateSt:Int = Int(timeInterval)

        return String(dateSt)
    }

    /** 获取随机数*/
    class func getRandom() -> String {
        // 获得当前应用程序默认的时区
        let zone: NSTimeZone = NSTimeZone.default as NSTimeZone
        // 以秒为单位返回当前应用程序与世界标准时间（格林威尼时间）的时差
        let interval: TimeInterval = TimeInterval(zone.secondsFromGMT(for: NSDate() as Date))
        
        let localeDate = NSDate().addingTimeInterval(interval)
        let timeInterval = localeDate.timeIntervalSince1970

        let ts: Double =  Double(timeInterval) * 1000
        
        let rs: Double = Double((10000 + arc4random() % (100000 - 10000 + 1)))

        return String("\(ts)\(rs)")
    }


}











