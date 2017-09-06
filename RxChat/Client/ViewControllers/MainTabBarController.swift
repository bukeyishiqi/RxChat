//
//  MainTabBarController.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/26.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class MainTabBarController: UITabBarController, BaseVCSupport {

    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTabBarItemColor()
        
        self.rx.didSelect.subscribe { (childVC) in
            
        }.addDisposableTo(disposeBag)
    }

    func setTabBarItemColor() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.colorFromHex(hex: "#68BB1E")], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
