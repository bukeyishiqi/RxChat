//
//  MemoryCache.swift
//  FCMallMobile
//
//  Created by 陈琪 on 16/8/10.
//  Copyright © 2016年 carisok. All rights reserved.
//

import Foundation
import UIKit

// MARK: 存储节点类
private class LinkedMapNode {
    weak var preNode: LinkedMapNode?
    weak var nextNode: LinkedMapNode?
    
    var key: String = ""
    var cost: UInt = 0
    var time: TimeInterval = CACurrentMediaTime()
    var value: AnyObject
    
    init(key: String, value: AnyObject, cost: UInt = 0) {
        self.key = key
        self.value = value
        self.cost = cost
    }
}


// MARK: 存储链类
private class LinkedMap {

    var dic: NSMutableDictionary = NSMutableDictionary()
    var totalCost: UInt = 0
    var totalCount: UInt = 0
    var headNode: LinkedMapNode?
    var tailNode: LinkedMapNode?
    
    /** 插入数据到链表中*/
    func insertNodeAtHead(node: LinkedMapNode){
        dic.setObject(node.value, forKey: node.key as NSCopying)
        totalCost += node.cost
        totalCount += 1
        
        if headNode != nil {
            node.nextNode = headNode
            headNode?.preNode = node
            headNode = node
        } else {
            headNode = node
            tailNode = node
        }
    }
    
    /** 移动数据至链表头部*/
    func bringNodeToHead(node: LinkedMapNode) {
        if let headNode = headNode , headNode === node {
            return
        }
        if tailNode === node {
            tailNode = node.preNode
            tailNode?.nextNode = nil
        }
        
        node.nextNode = headNode
        node.preNode = nil
        headNode?.preNode = node
        
        headNode = node
    }
    
    /** 移除节点数据*/
    func removeNode(node: LinkedMapNode) {
        dic.removeObject(forKey: node.key)
        totalCost -= node.cost
        totalCount -= 1
        
        if let next = node.nextNode {
            next.preNode = node.preNode
        }
        if let prev = node.nextNode {
            prev.nextNode = node.nextNode
        }
        if headNode === node {
            headNode = node.nextNode
        }
        if tailNode === node {
            tailNode = node.preNode
        }
    }
    
    /** 移除尾部节点*/
    @discardableResult
    func removeTailNode() -> LinkedMapNode? {
        guard tailNode != nil else {return nil}
        
        dic.removeObject(forKey: (tailNode?.key)!)
        totalCount -= 1
        totalCost -= (tailNode?.cost)!
        
        if headNode === tailNode {
            headNode = nil
            tailNode = nil
        } else {
            tailNode = tailNode?.preNode
            tailNode?.nextNode = nil
        }
        return tailNode
    }
    
    /** 移除所有节点数据*/
    func removeAllNode() {
        totalCost = 0
        totalCount = 0
        headNode = nil
        tailNode = nil
        
        if dic.count > 0 {
            dic = NSMutableDictionary()
        }
    }
}


// MARK: 内存管理类
public class MemoryCache {

    /** 对象总数(只读)*/
    public var totalCount: UInt {
        get {
            _lock()
            let count = linkedMap.totalCount
            _unlock()
            return count
        }
    }
    
    /** 缓存开销总数*/
    public var totalCost: UInt {
        get {
            _lock()
            let cost = linkedMap.totalCost
            _unlock()
            return cost
        }
    }
    
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
    
    public var _autoTrimInterval:TimeInterval = 5  /** 默认自动检测间隔时间5s*/
    
    /** 根据状态释放缓存设置*/
    fileprivate var _autoRemoveAllObjectWhenMemoryWarning: Bool = true
    public var autoRemoveAllObjectWhenMemoryWarning: Bool {
        set {
            _autoRemoveAllObjectWhenMemoryWarning = newValue
        }
        get {
            let autoRemoveAllObjectWhenMemoryWarning = _autoRemoveAllObjectWhenMemoryWarning
            return autoRemoveAllObjectWhenMemoryWarning
        }
    }

    fileprivate var _autoRemoveAllObjectWhenEnterBackground = false
    public var autoRemoveAllObjectWhenEnterBackground: Bool {
        set {
            _autoRemoveAllObjectWhenEnterBackground = newValue
        }
        get {
            let autoRemoveAllObjectWhenEnterBackground = _autoRemoveAllObjectWhenEnterBackground
            return autoRemoveAllObjectWhenEnterBackground
        }
    }
    
    fileprivate var _releaseOnMainThread = true
    public var releaseOnMainThread: Bool { /** 主线程释放所有缓存数据设置*/
        set {
            _releaseOnMainThread = newValue
        }
        get {
            let releaseOnMainThread = _releaseOnMainThread
            return releaseOnMainThread
        }
    }
    
    /** 对应状态处理闭包*/
    public var didReceiveMemoryWarningBlock: ((_ cache: MemoryCache) -> Void)? = nil
    public var didEnterBackgroundBlock: ((_ cache: MemoryCache) -> Void)? = nil
    
    fileprivate let linkedMap: LinkedMap = LinkedMap()
    fileprivate let _queue = DispatchQueue.init(label: "com.cache." + String(describing: MemoryCache()), qos: .userInitiated, attributes: .concurrent)

    
    fileprivate let _semaphoreLock = DispatchSemaphore.init(value: 1)
    
    public init () {
        NotificationCenter.default.addObserver(self, selector: #selector(MemoryCache._didReceiveMemoryWarningNotification), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemoryCache._didEnterBackgroundNotification), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        /** 循环检测数据有效性*/
        self.trimRecursively()
    }
}

// MARK: 对外接口
extension MemoryCache {

    // MARK: Access Methods

    /** 验证对象是否存在*/
    public func containsObject(forKey key: String) -> Bool {
        if key.characters.count == 0 {return false}
        _lock()
        let obj = linkedMap.dic.object(forKey: key)
        _unlock()
        if obj != nil  {
            return true
        } else {return false}
    }
    
    /** 保存对象*/
    public func setObject(object: AnyObject, forKey key: String, cost: UInt = 0) {
        if key.characters.count == 0 {return}
        
        /** 已存在节点移至首位，不存在则插入首位*/
        let time = CACurrentMediaTime()
        
        _lock()
        if let node: LinkedMapNode = linkedMap.dic.object(forKey: key) as? LinkedMapNode {
            linkedMap.totalCost -= node.cost
            linkedMap.totalCost += cost
            node.cost = cost
            node.time = time
            node.value = object
            
            linkedMap.bringNodeToHead(node: node)
        } else {
            let newNode = LinkedMapNode.init(key: key, value: object, cost: cost)
            linkedMap.insertNodeAtHead(node: newNode)
        }
        /** 如果总开销大于限定开销，移除末尾节点达到平衡*/
        if linkedMap.totalCost > _costLimit {
            _queue.async {
                self.trimeToCost(cost: self._costLimit)
            }
        }
        /** 如果总对象大于限定总对象量，移除末尾节点达到平衡*/
        if linkedMap.totalCount > _countLimit {
            linkedMap.removeTailNode()
        }
        _unlock()
    }
    
    /** 获取对象*/
    public func object(forKey key: String) -> AnyObject? {
        if key.characters.count == 0 {return nil}

        _lock()
        if let node: LinkedMapNode = linkedMap.dic.object(forKey: key) as? LinkedMapNode {
            node.time = CACurrentMediaTime()
            linkedMap.bringNodeToHead(node: node)
            _unlock()
             return node.value
        } else {
            _unlock()
            return nil
        }
    }
    
    /** 移除对象*/
    public func removeObject(forKey key: String) {
        if key.characters.count == 0 {return}

        _lock()
        if let node: LinkedMapNode = linkedMap.dic.object(forKey: key) as? LinkedMapNode {
            linkedMap.removeNode(node: node)
        }
        _unlock()
    }
    /** 移除所有对象*/
    public func removeAllObject() {
        _lock()
        linkedMap.removeAllNode()
        _unlock()
    }
    
    // MARK: 修改
    
    /** 修改缓存对象总数量限制*/
    public func trimCountLimit(count: UInt) {
        _lock()
        self.trimeToCount(count: count)
        _unlock()
    }
    /** 修改缓存总共开销限制*/
    public func trimCostLimit(cost: UInt) {
        _lock()
        self.trimeToCost(cost: cost)
        _unlock()
    }
    /** 修改缓存有效时间限制*/
    public func trimAgeLimit(age: TimeInterval) {
        _lock()
        self.trimeToAge(age: age)
        _unlock()
    }
}


// MARK:
//  MARK: Private
extension MemoryCache {
    @objc fileprivate func _didReceiveMemoryWarningNotification() {
        if self.autoRemoveAllObjectWhenMemoryWarning {
            self.removeAllObject()
        }
    }
    
    @objc fileprivate func _didEnterBackgroundNotification() {
        if self.autoRemoveAllObjectWhenEnterBackground {
            self.removeAllObject()
        }
    }
    
    /** 循环检测数据有效性*/
    fileprivate func trimRecursively() {
//        weak var weakSelf = self
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
    
    /** 修改缓存总数限制*/
    fileprivate func trimeToCost(cost: UInt) {
        if linkedMap.totalCost < cost {return}
        if cost == 0 {
            linkedMap.removeAllNode()
            return
        }
        
        while linkedMap.totalCost > cost {
            linkedMap.removeTailNode()
            guard let _: LinkedMapNode = linkedMap.tailNode else { break }
        }

    }
    /** 修改缓存节点总数限制*/
    fileprivate func trimeToCount(count: UInt) {
        if linkedMap.totalCount < count {return}
        if count == 0 {
            linkedMap.removeAllNode()
            return
        }
        
        while linkedMap.totalCount > count {
            linkedMap.removeTailNode()
            guard let _: LinkedMapNode = linkedMap.tailNode else { break }
        }
    }
    /** 修改有效时间限制*/
    fileprivate func trimeToAge(age: TimeInterval) {
        if age <= 0 {
            linkedMap.removeAllNode()
            return
        }
        if var lastNode = linkedMap.tailNode {
            while (CACurrentMediaTime() - lastNode.time > age) {
                linkedMap.removeTailNode()
                guard let newLastNode: LinkedMapNode = linkedMap.tailNode else { break }
                lastNode = newLastNode
            }
        }
        
    }
    
    fileprivate func _lock() {
        _semaphoreLock.wait()
    }
    
    fileprivate func _unlock() {
        _semaphoreLock.signal()
    }
}
