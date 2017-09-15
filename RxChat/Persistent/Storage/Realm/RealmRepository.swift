
//
//  RealmRepository.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/12.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

func abstractMethod() -> Never {
    fatalError("RealmRepository abstract method")
}

// MARK: Repository 抽象通用方法
class AbstractRepository<T> {
    func queryAll() -> Observable<[T]> {
        abstractMethod()
    }
    
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        abstractMethod()
    }
    
    func save(entity: T) -> Observable<Void> {
        abstractMethod()
    }
    
    func delete(entity: T) -> Observable<Void> {
        abstractMethod()
    }
}


final class RealmRepository<T: RealmRepresentable>: AbstractRepository<T> where T == T.RealmType.CustomType, T.RealmType: Object {

    private var configuration: Realm.Configuration
    private var scheduler: RealmRunloopScheduler
    private var realm: Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration) {
        self.configuration = configuration
        let name = "com.RxChat.RealmRepository"
        self.scheduler = RealmRunloopScheduler(name: name)
    }
    
    override func queryAll() -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
            
            return Observable.from(optional: objects).mapToCustomObj()
        }.subscribeOn(scheduler)
    }

    override func query(with predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
                               .filter(predicate)
                               .sorted(by: sortDescriptors.map(SortDescriptor.init))
            
            return Observable.from(optional: objects).mapToCustomObj()
        }.subscribeOn(scheduler)
    }
    
    override func save(entity: T) -> Observable<Void> {
        return Observable.deferred {
            let realm = self.realm
            
            return realm.rx.save(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    override func delete(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity)
            }
            .subscribeOn(scheduler)
    }
}






