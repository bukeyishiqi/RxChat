//
//  ConversationListController.swift
//  RxChat
//
//  Created by 陈琪 on 2017/6/27.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


class ConversationListController: UIViewController, BasicPushOrPopEnable {
    
    var disposeBag: DisposeBag = DisposeBag()

    var vcCompletionBlock: ((_ targetVC: UIViewController) -> Void)?

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = ConversationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.observeViewModel()
    }
    
    private func observeViewModel() {
    
//        let items = viewModel.allConversationModels.asObservable()
        let items = Observable.just((0..<20).map {"\($0)"})
            items.bind(to: tableView.rx.items(cellIdentifier: "ConversationListCell", cellType: ConversationListCell.self)) { (row, element, cell) in
                cell.titleLabel?.text = "\(element) @ row \(row)"
            }
            .addDisposableTo(disposeBag)
        tableView.rx.modelSelected(String.self).subscribe(onNext: { (conversation) in
            let stroyb = UIStoryboard.init(name: "Chat", bundle: nil)
            let chatVC = stroyb.instantiateViewController(withIdentifier: "ChatViewController")
            
            self.navigationController?.pushViewController(chatVC, animated: true)
            
        }).disposed(by: disposeBag)
    }
}







