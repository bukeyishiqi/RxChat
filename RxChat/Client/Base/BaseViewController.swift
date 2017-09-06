//
//  BaseViewController.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/5.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class BaseViewController: UIViewController, BaseVCSupport, BasicPushOrPopEnable {
    var vcCompletionBlock: ((_ targetVC: UIViewController) -> Void)?
    
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
