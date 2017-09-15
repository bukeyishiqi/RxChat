//
//  BasicVCProtocol.swift
//  MallMobile
//
//  Created by 陈琪 on 2017/2/23.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public protocol BaseVCSupport
{
   var disposeBag: DisposeBag {set get}
}

/**
 *   - 项目界面推送统一处理协议
 */
@objc public protocol BasicPushOrPopEnable {
    
    /** 界面推送、返回闭包*/
    @objc var vcCompletionBlock: ((_ targetVC: UIViewController) -> Void)? {set get}

   @objc optional func push(vc: UIViewController, completion:(_ targetVC: UIViewController) ->Void)
   @objc optional func pop(className: AnyClass, completion:(_ targetVC: UIViewController) -> Void)
   @objc optional func popToRoot(animated: Bool)
}

/**
 *  - BasicPushOrPopEnable 默认实现
 */
extension BasicPushOrPopEnable where Self: UIViewController {

    func push(vc: UIViewController, completion:((_ targetVC: UIViewController) ->Void)? = nil) {
        self.vcCompletionBlock = completion

        /** 添加根视图控制器到*/
        if GlobalConstants.shareInstance.arrayVCsCount == 0 {
            let rootNav: UINavigationController = AppDelegate.getAppDelegate().window!.rootViewController as! UINavigationController
            GlobalConstants.shareInstance.append(rootNav.topViewController!)
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        /** 添加当前视图对象到数组*/
        GlobalConstants.shareInstance.append(vc)
        
    }

    func pop(className: AnyClass? = nil, completion:((_ targetVC: UIViewController) ->Void)? = nil) {
        self.vcCompletionBlock = completion

        /** 通过类名取到VC， 如果不存在直接返回上一层*/
        if let `class` = className {
            let vc = GlobalConstants.shareInstance.take(forClass: `class`)
            GlobalConstants.shareInstance.remove(forVc: vc)
            let _ = self.navigationController?.popToViewController(vc!, animated: true)
            
        } else {
            GlobalConstants.shareInstance.remove(last: true)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func popToRoot(animated: Bool) {
        for (index, value) in (self.navigationController?.viewControllers.enumerated())! {
            if index > 0 {
                GlobalConstants.shareInstance.remove(forVc: value)
                break
            }
        }
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
}


/**
 *  - 错误统一处理协议
 */
protocol ErrorPopoverRender {

    func presentError(errorOptions: ErrorOptions)
}

extension ErrorPopoverRender where Self: UIViewController {
    func presentError(errorOptions: ErrorOptions = ErrorOptions()) {
        //在这里加默认实现，并提供ErrorView的默认参数。
        
    }
}


// MARK: - 错误配置
struct ErrorOptions {
    let message: String
    let canDismissByTap: Bool
    
    init(message: String = "Error!", canDismissByTappingAnywhere canDismiss: Bool = true) {
        self.message = message
        self.canDismissByTap = canDismiss
    }
}





