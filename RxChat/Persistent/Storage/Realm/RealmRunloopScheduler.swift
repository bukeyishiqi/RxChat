//
//  RealmRunloopScheduler.swift
//  RxChat
//
//  Created by 陈琪 on 2017/9/14.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import Foundation
import RxSwift

final class RealmRunloopScheduler:  ImmediateSchedulerType {

    private let threadTarget: ThreadTarget
    private var thread: Thread
    
    init(name: String) {
        self.threadTarget = ThreadTarget()
        self.thread = Thread.init(target: threadTarget, selector: #selector(ThreadTarget.threadEntryPoint), object: nil)
        self.thread.name = name
        self.thread.start()
    }
    
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let disposable = SingleAssignmentDisposable()
        
        var action: Action? = Action {
            if disposable.isDisposed {
                return
            }
            
            disposable.setDisposable(action(state))
        }
        
        action?.perform(#selector(Action.performAction), on: thread, with: nil, waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
        
        let actionDisposable = Disposables.create {
            action = nil
        }
        
        return Disposables.create(disposable, actionDisposable)
    }
}


private final class ThreadTarget: NSObject {
    @objc fileprivate func threadEntryPoint() {
        /** 指定runloop*/
        let runLoop = RunLoop.current
        runLoop.add(NSMachPort(), forMode: RunLoopMode.defaultRunLoopMode)
        runLoop.run()
    }
}


private final class Action: NSObject {
    private let action: () -> ()
    
    init(action: @escaping () -> ()) {
        self.action = action
    }
    
    @objc func performAction() {
        action()
    }
}
