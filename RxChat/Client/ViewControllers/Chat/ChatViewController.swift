//
//  ChatViewController.swift
//  RxChat
//
//  Created by 陈琪 on 2017/7/31.
//  Copyright © 2017年 Carisok. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class ChatViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chatInputView: OYChatInputView!
    
    @IBOutlet weak var refreshView: UIView!

    @IBOutlet weak var voiceTipView: UIView!

    @IBOutlet weak var chatInputViewBottomConstraint: NSLayoutConstraint!
    
    var viewModel = ChatViewModel.init(provider: ServiceProvider())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.do {
            $0.estimatedRowHeight = 45
            $0.rowHeight = UITableViewAutomaticDimension
        }
        observerViewModel()
        observerInputView()
    }
    
    private func observerViewModel() {
        let refreshEvent = self.tableView.refreshControl?.rx.controlEvent(.allEvents)
        
        let input = ChatViewModel.Input.init(sendText: chatInputView.rx.didSendTextMsg)
        
        let output = viewModel.transform(input)
        
        output.list.asDriver().drive(tableView.rx.items) { (tableView, row, element) in
            let identifier = element.description
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChatBaseCell
            if cell == nil {
                tableView.register(NSClassFromString(identifier), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChatBaseCell
            }
            cell?.viewModel = element
            cell?.updateConstraintsIfNeeded()
            return cell ?? UITableViewCell()
            }.disposed(by: disposeBag)
        
//        output.refreshTrigger.drive(isRefreshBinding).disposed(by: disposeBag)
//        output.scrollOfIndex.drive(self.tableView.rx.scrollIndex).disposed(by: disposeBag)
        
        output.sendMsgTrigger.drive(self.tableView.rx.scrollIndex).disposed(by: disposeBag)
        
    }
    
    private func observerInputView() {

        chatInputView.rx.didUpdateKeyboardShowHideInfo
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.updateKeyboard(keyboardShowHideInfo: info)
        }).addDisposableTo(disposeBag)
        
        chatInputView.rx.didSendTextMsg
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] sendMsg in
                print("dddd:", sendMsg)
        }).addDisposableTo(disposeBag)
        
        chatInputView.rx.didSendGifMsg
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] gifItem in
                print("gif:", gifItem)
            }).addDisposableTo(disposeBag)
        
        chatInputView.rx.ShareTagTap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] tag in
                print("tag:", tag)
            }).addDisposableTo(disposeBag)
        
        chatInputView.rx.addPackageButtonTap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                print("add:")
            }).addDisposableTo(disposeBag)
    }
   
//    var isRefreshBinding: UIBindingObserver<ChatViewController, Bool> {
//        return UIBindingObserver.init(UIElement: self, binding: {(vc, isRefresh) in
//            if isRefresh {
//                vc.refreshControl.endRefreshing()
//            } else {
//                vc.refreshControl.beginRefreshing()
//            }
//        })
//    }
    
}


extension ChatViewController {
   fileprivate  func updateKeyboard(keyboardShowHideInfo: KeyboardShowHideInfo) {
        
        let constant = keyboardShowHideInfo.keyboardHeight
        
//        let needScrollToBottom = ((self.chatInputViewBottomConstraint.constant == 0) && (constant > 0))

        UIView.animate(withDuration: TimeInterval(keyboardShowHideInfo.duration), delay: 0, options: keyboardShowHideInfo.curve, animations: {
            self.chatInputViewBottomConstraint.constant = constant
            self.view.layoutIfNeeded()
            
            self.tableView.contentInset = UIEdgeInsetsMake(constant, 0, 0, 0)
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
            
        }, completion: nil)
    }
}


extension Reactive where Base: UITableView {
    var scrollIndex: UIBindingObserver<Base, Int> {
        return UIBindingObserver.init(UIElement: base, binding: {(tableView, index) in
            let indexPath = IndexPath.init(row: index-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
}



