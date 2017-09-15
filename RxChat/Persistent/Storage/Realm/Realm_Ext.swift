//
//  Realm_Ext.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/15.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

extension SortDescriptor {

    /** NSSortDescriptor 转换为SortDescriptor */
    init(sortDescriptor: NSSortDescriptor) {
        self.keyPath = sortDescriptor.key ?? ""
        self.ascending = sortDescriptor.ascending
    }
}

extension Realm: ReactiveCompatible {}

extension Observable where Element: Sequence, Element.Iterator.Element: CustomObjectConvertibleType {
    typealias CustomType = Element.Iterator.Element.CustomType
    
    func mapToCustomObj() -> Observable<[CustomType]> {
        return map { sequence -> [CustomType] in
            
            return sequence.map {
                $0.asCustomObject()
            }
        }
    }
}

extension Reactive where Base: Realm {
    func save<R: RealmRepresentable>(entity: R, update: Bool = true) -> Observable<Void> where R.RealmType: Object  {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(entity.asRealm(), update: update)
                }
                observer.onNext()
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<R: RealmRepresentable>(entity: R) -> Observable<Void> where R.RealmType: Object {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.delete(entity.asRealm())
                }
                observer.onNext()
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
}
